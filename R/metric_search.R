.hm_metric_search_validate_char_filter <- function(x, name) {
  if (is.null(x)) {
    return(NULL)
  }
  if (!is.character(x) || length(x) < 1L || anyNA(x) || any(!nzchar(x))) {
    stop(sprintf("`%s` must be NULL or a character vector of non-empty strings.", name), call. = FALSE)
  }
  unique(tolower(x))
}

.hm_metric_search_validate_flag <- function(x, name) {
  if (is.null(x)) {
    return(NULL)
  }
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop(sprintf("`%s` must be TRUE, FALSE, or NULL.", name), call. = FALSE)
  }
  x
}

.hm_metric_search_available_presets <- function() {
  c(
    "recommended",
    "compatibility_core",
    "deterministic_error",
    "correlation_agreement",
    "flow_duration_distribution",
    "probabilistic_uncertainty",
    "seasonal_regime"
  )
}

.hm_metric_search_validate_presets <- function(preset, name = "preset") {
  preset <- .hm_metric_search_validate_char_filter(preset, name)
  unknown <- setdiff(preset, .hm_metric_search_available_presets())
  if (length(unknown) > 0L) {
    stop(
      sprintf(
        "Unknown `%s` value(s): %s. Available presets: %s.",
        name,
        paste(unknown, collapse = ", "),
        paste(.hm_metric_search_available_presets(), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  preset
}

.hm_metric_search_export_map <- function(metric_ids) {
  ns_exports <- getNamespaceExports("hydroMetrics")
  direct_ids <- intersect(metric_ids, ns_exports)

  alias_map <- data.frame(
    wrapper = c(
      "HFB",
      "NSeff",
      "mNSeff",
      "rNSeff",
      "wsNSeff",
      "mutual_information_score"
    ),
    id = c(
      "hfb",
      "nse",
      "mnse",
      "rnse",
      "wsnse",
      "mutual_information"
    ),
    stringsAsFactors = FALSE
  )

  direct_map <- data.frame(
    wrapper = direct_ids,
    id = direct_ids,
    stringsAsFactors = FALSE
  )

  map <- rbind(direct_map, alias_map)
  map <- map[map$id %in% metric_ids & map$wrapper %in% ns_exports, , drop = FALSE]
  map[order(map$id, map$wrapper), , drop = FALSE]
}

.hm_metric_search_presets <- function(metric_ids, metrics) {
  ids <- metric_ids
  tags_lower <- tolower(metrics$tags)

  distribution_ids <- ids[
    grepl(
      "^(cdf_|fdc_|quantile_deviation$|quantile_shift_index$|distribution_overlap$|ks_statistic$|anderson_darling_stat$|wasserstein_distance$|entropy_diff$|mutual_information|normalised_mi$)",
      ids
    )
  ]

  probabilistic_ids <- ids[
    grepl("probabilistic", tags_lower, fixed = TRUE) |
      ids %in% c(
        "quantile_loss",
        "quantile_kge",
        "quantile_deviation",
        "quantile_shift_index",
        "cdf_rmse",
        "distribution_overlap",
        "ks_statistic",
        "anderson_darling_stat",
        "wasserstein_distance"
      )
  ]

  seasonal_regime_ids <- ids[
    ids %in% c(
      "event_nse",
      "extreme_event_ratio",
      "peak_timing_error",
      "rising_limb_error",
      "recession_constant",
      "baseflow_index_error",
      "derivative_nse",
      "low_flow_bias",
      "fdc_lowflow_bias",
      "hfb",
      "tail_dependence_score"
    )
  ]

  list(
    recommended = intersect(ids, .hm_recommended_metric_ids()),
    compatibility_core = intersect(
      ids,
      c(
        .hm_recommended_metric_ids(),
        "alpha",
        "beta",
        "r",
        "mnse",
        "rnse",
        "wsnse",
        "hfb"
      )
    ),
    deterministic_error = ids[metrics$category == "error" & !grepl("probabilistic", tags_lower, fixed = TRUE)],
    correlation_agreement = ids[metrics$category %in% c("correlation", "agreement")],
    flow_duration_distribution = distribution_ids,
    probabilistic_uncertainty = probabilistic_ids,
    seasonal_regime = seasonal_regime_ids
  )
}

.hm_metric_search_table <- function() {
  metrics <- .get_registry()$list()
  export_map <- .hm_metric_search_export_map(metrics$id)
  compatibility_wrappers <- c(
    "HFB",
    "NSeff",
    "mNSeff",
    "rNSeff",
    "wsNSeff",
    "mutual_information_score"
  )
  presets <- .hm_metric_search_presets(metrics$id, metrics)

  metrics$exported_wrappers <- vapply(metrics$id, function(id) {
    wrappers <- export_map$wrapper[export_map$id == id]
    if (length(wrappers) == 0L) "" else paste(wrappers, collapse = "; ")
  }, character(1))

  metrics$compatibility_export <- vapply(metrics$id, function(id) {
    any(export_map$id == id & export_map$wrapper %in% compatibility_wrappers)
  }, logical(1))

  metrics$presets <- vapply(metrics$id, function(id) {
    groups <- names(presets)[vapply(presets, function(group_ids) id %in% group_ids, logical(1))]
    if (length(groups) == 0L) "" else paste(groups, collapse = "; ")
  }, character(1))

  metrics <- metrics[, c(
    "id",
    "name",
    "category",
    "exported_wrappers",
    "compatibility_export",
    "presets",
    "description",
    "perfect",
    "range",
    "references",
    "version_added",
    "tags"
  )]

  metrics[order(metrics$id), , drop = FALSE]
}

.hm_metric_search_match_preset <- function(group_text, preset) {
  if (!nzchar(group_text)) {
    return(FALSE)
  }
  groups <- trimws(strsplit(tolower(group_text), ";", fixed = TRUE)[[1L]])
  any(groups %in% preset)
}

#' Search registered metrics by simple discovery metadata
#'
#' `metric_search()` provides a small discovery-oriented view over the current
#' metric registry. It reuses existing registry metadata and adds a few
#' user-facing annotations that are already supportable from the current package
#' surface:
#'
#' - `exported_wrappers`: exported wrapper names that route to the metric id
#' - `compatibility_export`: whether a documented compatibility export reaches
#'   that metric id
#' - `presets`: curated baseline preset groups for Workstream C discovery
#'
#' This first baseline is intentionally modest. It can filter by text,
#' category, tags, preset group, and exported/compatibility status, but it does
#' not search formulas, inspect applicability conditions, or replace the metric
#' reference vignette.
#'
#' Available preset groups:
#'
#' - `recommended`
#' - `compatibility_core`
#' - `deterministic_error`
#' - `correlation_agreement`
#' - `flow_duration_distribution`
#' - `probabilistic_uncertainty`
#' - `seasonal_regime`
#'
#' `tags` and `preset` filters use case-insensitive any-match logic across the
#' supplied values.
#'
#' @param text Optional case-insensitive text query matched against metric id,
#'   name, description, exported wrapper names, and preset labels.
#' @param category Optional category filter matched against registry
#'   `category`.
#' @param tags Optional registry-tag filter matched against the semicolon-joined
#'   `tags` field.
#' @param preset Optional preset-group filter. Must be one or more of the
#'   documented preset names.
#' @param exported Optional logical filter. `TRUE` keeps only metrics that have
#'   at least one exported wrapper path; `FALSE` keeps only metrics that are not
#'   directly exposed by an exported wrapper.
#' @param compatibility Optional logical filter. `TRUE` keeps only metrics that
#'   are reached by at least one documented compatibility export.
#'
#' @return A `data.frame` of registry metrics with discovery annotations.
#' @examples
#' metric_search(text = "bias")
#' metric_search(category = "correlation")
#' metric_search(tags = "kge-component")
#' metric_search(preset = "compatibility_core")
#' @export
metric_search <- function(text = NULL,
                          category = NULL,
                          tags = NULL,
                          preset = NULL,
                          exported = NULL,
                          compatibility = NULL) {
  text <- .hm_metric_search_validate_char_filter(text, "text")
  category <- .hm_metric_search_validate_char_filter(category, "category")
  tags <- .hm_metric_search_validate_char_filter(tags, "tags")
  if (!is.null(preset)) {
    preset <- .hm_metric_search_validate_presets(preset, "preset")
  }
  exported <- .hm_metric_search_validate_flag(exported, "exported")
  compatibility <- .hm_metric_search_validate_flag(compatibility, "compatibility")

  metrics <- .hm_metric_search_table()
  out <- metrics

  if (!is.null(text)) {
    haystack <- tolower(paste(
      out$id,
      out$name,
      out$description,
      out$exported_wrappers,
      out$presets
    ))
    text_match <- vapply(haystack, function(value) {
      any(vapply(text, function(token) grepl(token, value, fixed = TRUE), logical(1)))
    }, logical(1))
    out <- out[text_match, , drop = FALSE]
  }

  if (!is.null(category)) {
    out <- out[tolower(out$category) %in% category, , drop = FALSE]
  }

  if (!is.null(tags)) {
    tag_match <- vapply(out$tags, function(tag_text) {
      if (!nzchar(tag_text)) {
        return(FALSE)
      }
      any(vapply(tags, function(tag) grepl(tag, tolower(tag_text), fixed = TRUE), logical(1)))
    }, logical(1))
    out <- out[tag_match, , drop = FALSE]
  }

  if (!is.null(preset)) {
    preset_match <- vapply(out$presets, function(group_text) {
      .hm_metric_search_match_preset(group_text, preset)
    }, logical(1))
    out <- out[preset_match, , drop = FALSE]
  }

  if (!is.null(exported)) {
    out <- out[(nzchar(out$exported_wrappers)) == exported, , drop = FALSE]
  }

  if (!is.null(compatibility)) {
    out <- out[out$compatibility_export == compatibility, , drop = FALSE]
  }

  rownames(out) <- NULL
  out
}
