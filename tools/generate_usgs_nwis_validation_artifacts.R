#!/usr/bin/env Rscript

.require_devtools <- function() {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    stop("The artifact generator requires devtools to load the package from the repo root.", call. = FALSE)
  }
}

.read_rdb_url <- function(url) {
  lines <- readLines(url(url), warn = FALSE, encoding = "UTF-8")
  lines <- lines[!grepl("^#", lines)]
  lines <- lines[nzchar(lines)]
  if (length(lines) < 3L) {
    stop(sprintf("No tab-delimited data payload returned from %s", url), call. = FALSE)
  }
  out <- utils::read.delim(
    text = paste(lines, collapse = "\n"),
    sep = "\t",
    header = TRUE,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  if (nrow(out) == 0L) {
    stop(sprintf("No records returned from %s", url), call. = FALSE)
  }
  out[-1L, , drop = FALSE]
}

.safe_numeric <- function(x) {
  as.numeric(x)
}

.site_url <- function(site_ids) {
  paste0(
    "https://waterservices.usgs.gov/nwis/site/?format=rdb&sites=",
    paste(site_ids, collapse = ","),
    "&siteOutput=expanded"
  )
}

.dv_url <- function(site_id, start_date, end_date) {
  paste0(
    "https://waterservices.usgs.gov/nwis/dv/?format=rdb&sites=", site_id,
    "&startDT=", start_date,
    "&endDT=", end_date,
    "&parameterCd=00060&statCd=00003&siteStatus=all"
  )
}

.scenario_identity <- function(obs, dates) {
  obs
}

.scenario_bias_plus10 <- function(obs, dates) {
  obs * 1.10
}

.scenario_smooth_cycle <- function(obs, dates) {
  amplitude <- 0.10 * stats::sd(obs)
  perturb <- amplitude * sin(2 * pi * seq_along(obs) / 365.25)
  pmax(obs + perturb, 0)
}

.scenario_seasonal_scale <- function(obs, dates) {
  month <- as.integer(format(dates, "%m"))
  scale <- ifelse(month %in% 4:9, 1.15, 0.90)
  pmax(obs * scale, 0)
}

.compute_metrics <- function(sim, obs) {
  out <- gof(sim, obs, methods = c("nse", "kge", "rmse", "pbias", "mae", "ve"))
  data.frame(
    nse = unname(as.numeric(out[["nse"]])),
    kge = unname(as.numeric(out[["kge"]])),
    rmse = unname(as.numeric(out[["rmse"]])),
    pbias = unname(as.numeric(out[["pbias"]])),
    mae = unname(as.numeric(out[["mae"]])),
    ve = unname(as.numeric(out[["ve"]])),
    stringsAsFactors = FALSE
  )
}

.write_csv <- function(x, path) {
  utils::write.csv(x, path, row.names = FALSE, na = "")
}

main <- function() {
  repo_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
  .require_devtools()
  devtools::load_all(repo_root, quiet = TRUE)

  retrieval_time <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
  retrieval_date <- format(Sys.Date(), "%Y-%m-%d")
  start_date <- "2016-01-01"
  end_date <- "2020-12-31"
  parameter_cd <- "00060"
  stat_cd <- "00003"
  units <- "cubic feet per second"
  stations <- data.frame(
    site_no = c("01491000", "01646500", "05584500"),
    stringsAsFactors = FALSE
  )

  validation_dir <- file.path(repo_root, "inst", "validation")
  if (!dir.exists(validation_dir)) {
    dir.create(validation_dir, recursive = TRUE, showWarnings = FALSE)
  }

  site_df <- .read_rdb_url(.site_url(stations$site_no))
  keep_site_cols <- c("site_no", "station_nm", "state_cd", "dec_lat_va", "dec_long_va", "drain_area_va")
  site_df <- site_df[, intersect(keep_site_cols, names(site_df)), drop = FALSE]
  names(site_df)[names(site_df) == "state_cd"] <- "state_fips"
  names(site_df)[names(site_df) == "dec_lat_va"] <- "latitude"
  names(site_df)[names(site_df) == "dec_long_va"] <- "longitude"
  names(site_df)[names(site_df) == "drain_area_va"] <- "drainage_area_sqmi"
  site_df$latitude <- .safe_numeric(site_df$latitude)
  site_df$longitude <- .safe_numeric(site_df$longitude)
  site_df$drainage_area_sqmi <- .safe_numeric(site_df$drainage_area_sqmi)
  site_df$parameter_cd <- parameter_cd
  site_df$stat_cd <- stat_cd
  site_df$units <- units
  site_df$start_date <- start_date
  site_df$end_date <- end_date
  site_df$site_service_url <- .site_url(stations$site_no)
  site_df$daily_value_url <- vapply(site_df$site_no, .dv_url, character(1), start_date = start_date, end_date = end_date)

  expected_days <- as.integer(as.Date(end_date) - as.Date(start_date)) + 1L
  observed_summary <- list()
  metric_rows <- list()

  scenarios <- list(
    identity = .scenario_identity,
    bias_plus10 = .scenario_bias_plus10,
    smooth_cycle = .scenario_smooth_cycle,
    seasonal_scale = .scenario_seasonal_scale
  )

  for (i in seq_len(nrow(site_df))) {
    site_no <- site_df$site_no[[i]]
    station_nm <- site_df$station_nm[[i]]
    dv_df <- .read_rdb_url(.dv_url(site_no, start_date, end_date))
    value_col <- names(dv_df)[grepl("_00060_00003$", names(dv_df))]
    code_col <- names(dv_df)[grepl("_00060_00003_cd$", names(dv_df))]
    if (length(value_col) != 1L || length(code_col) != 1L) {
      stop(sprintf("Could not identify the daily discharge columns for site %s.", site_no), call. = FALSE)
    }

    dates <- as.Date(dv_df$datetime)
    obs <- .safe_numeric(dv_df[[value_col]])
    codes <- dv_df[[code_col]]
    keep <- is.finite(obs) & !is.na(dates)
    dates <- dates[keep]
    obs <- obs[keep]
    codes <- codes[keep]

    observed_summary[[length(observed_summary) + 1L]] <- data.frame(
      site_no = site_no,
      station_nm = station_nm,
      start_date = min(dates),
      end_date = max(dates),
      n_obs = length(obs),
      expected_days = expected_days,
      completeness_pct = round(100 * length(obs) / expected_days, 3),
      approved_days = sum(grepl("A", codes, fixed = TRUE)),
      estimated_days = sum(grepl("e", codes, fixed = TRUE)),
      mean_cfs = round(mean(obs), 6),
      median_cfs = round(stats::median(obs), 6),
      sd_cfs = round(stats::sd(obs), 6),
      min_cfs = round(min(obs), 6),
      max_cfs = round(max(obs), 6),
      stringsAsFactors = FALSE
    )

    for (scenario_name in names(scenarios)) {
      sim <- scenarios[[scenario_name]](obs, dates)
      metrics <- .compute_metrics(sim, obs)
      metric_rows[[length(metric_rows) + 1L]] <- cbind(
        data.frame(
          site_no = site_no,
          station_nm = station_nm,
          scenario = scenario_name,
          n_obs = length(obs),
          stringsAsFactors = FALSE
        ),
        metrics
      )
    }
  }

  manifest_path <- file.path(validation_dir, "usgs_nwis_manifest.csv")
  observed_path <- file.path(validation_dir, "usgs_nwis_observed_subset_summary.csv")
  metrics_path <- file.path(validation_dir, "usgs_nwis_metric_validation_summary.csv")
  provenance_path <- file.path(validation_dir, "usgs_nwis_provenance.md")

  .write_csv(site_df, manifest_path)
  .write_csv(do.call(rbind, observed_summary), observed_path)
  .write_csv(do.call(rbind, metric_rows), metrics_path)

  provenance_lines <- c(
    "# USGS NWIS Validation Provenance",
    "",
    sprintf("- Retrieval timestamp: `%s`", retrieval_time),
    sprintf("- Source service: `%s`", "USGS NWIS Water Services"),
    sprintf("- Site service endpoint: `%s`", .site_url(stations$site_no)),
    sprintf("- Parameter code: `%s` (discharge)", parameter_cd),
    sprintf("- Statistic code: `%s` (daily mean)", stat_cd),
    sprintf("- Units retained from NWIS: `%s`", units),
    sprintf("- Date window: `%s` to `%s`", start_date, end_date),
    "",
    "## Fixed Station Set",
    "",
    sprintf("- `%s`: %s", site_df$site_no[[1]], site_df$station_nm[[1]]),
    sprintf("- `%s`: %s", site_df$site_no[[2]], site_df$station_nm[[2]]),
    sprintf("- `%s`: %s", site_df$site_no[[3]], site_df$station_nm[[3]]),
    "",
    "## Retrieval Logic",
    "",
    "- One site-service request is used to resolve station metadata.",
    "- One daily-values request is issued per station using NWIS `dv` output in `rdb` format.",
    "- The query requests parameter `00060` and statistic `00003` only.",
    "- No raw NWIS response files are committed; only derived manifest and summary artifacts are written.",
    "",
    "## Processing",
    "",
    "- Daily mean discharge values are kept in the original NWIS units (cfs).",
    "- Qualification codes are retained only as summary counts of approved and estimated days.",
    "- Missing or non-numeric daily values are dropped before the observed-series summaries and benchmark scenarios are computed.",
    "",
    "## Benchmark Comparison Scenarios",
    "",
    "- `identity`: simulated series equals observed series.",
    "- `bias_plus10`: simulated series equals `1.10 * obs`.",
    "- `smooth_cycle`: simulated series adds a deterministic sinusoidal perturbation with amplitude `0.10 * sd(obs)` and is truncated at zero.",
    "- `seasonal_scale`: simulated series applies a fixed seasonal multiplier of `1.15` for April-September and `0.90` otherwise, truncated at zero.",
    "",
    "These are benchmark scenarios derived from real observed NWIS series. They are not external model outputs.",
    "",
    "## Metric Scope",
    "",
    "- `nse`",
    "- `kge`",
    "- `rmse`",
    "- `pbias`",
    "- `mae`",
    "- `ve`"
  )
  writeLines(provenance_lines, provenance_path, useBytes = TRUE)

  message("Wrote: ", manifest_path)
  message("Wrote: ", observed_path)
  message("Wrote: ", metrics_path)
  message("Wrote: ", provenance_path)
}

main()
