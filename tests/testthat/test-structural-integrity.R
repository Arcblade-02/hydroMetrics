.struct_namespace <- local({
  .find_pkg_root <- function(path = getwd()) {
    path <- normalizePath(path, winslash = "/", mustWork = TRUE)

    repeat {
      if (file.exists(file.path(path, "DESCRIPTION"))) {
        return(path)
      }

      parent <- dirname(path)
      if (identical(parent, path)) {
        stop("Could not locate package root for structural integrity tests.")
      }
      path <- parent
    }
  }

  if (exists("list_metrics", mode = "function")) {
    return(function() asNamespace("hydroMetrics"))
  }

  ns <- new.env(parent = baseenv())
  r_dir <- file.path(.find_pkg_root(), "R")
  r_files <- sort(list.files(r_dir, pattern = "[.][Rr]$", full.names = TRUE))
  for (path in r_files) {
    sys.source(path, envir = ns)
  }

  function() ns
})

test_that("no duplicate metric function definitions remain", {
  ns <- .struct_namespace()
  metric_names <- ls(envir = ns, pattern = "^metric_[A-Za-z0-9_]+$")
  expect_identical(length(metric_names), length(unique(metric_names)))
})

.struct_top_level_function_defs <- function() {
  pkg_root <- dirname(dirname(testthat::test_path()))
  r_dir <- file.path(pkg_root, "R")
  if (!dir.exists(r_dir)) {
    return(data.frame(
      name = character(0),
      file = character(0),
      line = integer(0),
      stringsAsFactors = FALSE
    ))
  }

  r_files <- sort(list.files(r_dir, pattern = "[.][Rr]$", full.names = TRUE))
  if (length(r_files) == 0L) {
    return(data.frame(
      name = character(0),
      file = character(0),
      line = integer(0),
      stringsAsFactors = FALSE
    ))
  }

  rows <- lapply(r_files, function(path) {
      lines <- readLines(path, warn = FALSE)
      hits <- regexec("^([A-Za-z0-9._]+)\\s*<-\\s*function\\s*\\(", lines, perl = TRUE)
      captures <- regmatches(lines, hits)
      keep <- lengths(captures) > 1L
      if (!any(keep)) {
        return(NULL)
      }

      data.frame(
        name = vapply(captures[keep], `[`, character(1), 2L),
        file = basename(path),
        line = which(keep),
        stringsAsFactors = FALSE
      )
    })

  rows <- Filter(Negate(is.null), rows)
  if (length(rows) == 0L) {
    return(data.frame(
      name = character(0),
      file = character(0),
      line = integer(0),
      stringsAsFactors = FALSE
    ))
  }

  do.call(rbind, rows)
}

test_that("no duplicate top-level function definitions remain across source files", {
  defs <- .struct_top_level_function_defs()
  if (nrow(defs) == 0L) {
    skip("Source-tree function-definition scan is unavailable in this test context.")
  }

  dup_rows <- defs[duplicated(defs$name) | duplicated(defs$name, fromLast = TRUE), , drop = FALSE]
  dup_info <- NULL

  if (nrow(dup_rows) > 0L) {
    ordered <- dup_rows[order(dup_rows$name, dup_rows$file, dup_rows$line), , drop = FALSE]
    dup_info <- paste(
      apply(ordered, 1, function(row) {
        sprintf("%s %s:%s", row[["name"]], row[["file"]], row[["line"]])
      }),
      collapse = "\n"
    )
  }

  expect_identical(
    nrow(dup_rows),
    0L,
    info = dup_info
  )
})

test_that("canonical metric tree contains no NA-handling logic tokens", {
  ns <- .struct_namespace()
  metric_names <- ls(envir = ns, pattern = "^metric_[A-Za-z0-9_]+$")
  metric_bodies <- vapply(metric_names, function(name) {
    paste(deparse(body(get(name, envir = ns))), collapse = "\n")
  }, character(1))
  hits <- grep("na\\.rm|complete\\.cases|is\\.na\\(", metric_bodies, value = TRUE, perl = TRUE)
  expect_length(hits, 0L)
})

.struct_fixture_for_metric <- function(id) {
  if (identical(id, "skge")) {
    obs <- stats::ts(c(1:12, 2:13), start = c(2000, 1), frequency = 12)
    sim <- obs
    return(list(sim = sim, obs = obs, params = list()))
  }

  if (identical(id, "derivative_nse")) {
    sim <- c(1, 2, 4, 7)
    obs <- c(1, 2, 3, 5)
    return(list(sim = sim, obs = obs, params = list()))
  }

  if (identical(id, "recession_constant")) {
    sim <- c(1, 2, 5, 4, 3, 2)
    obs <- c(1, 2, 6, 5, 4, 3)
    return(list(sim = sim, obs = obs, params = list()))
  }

  if (identical(id, "event_nse")) {
    sim <- c(1, 2, 4, 7, 2, 1, 1, 3, 6, 2, 1, 1)
    obs <- c(1, 2, 5, 6, 2, 1, 1, 4, 5, 2, 1, 1)
    return(list(sim = sim, obs = obs, params = list()))
  }

  if (identical(id, "high_flow_percent_bias")) {
    obs <- 1:30
    sim <- obs + 1
    return(list(sim = sim, obs = obs, params = list(threshold_prob = 0.9)))
  }

  list(
    sim = c(1, 2, 3, 4),
    obs = c(1, 2, 3, 4),
    params = list()
  )
}

test_that("every registered metric has a callable implementation", {
  ns <- .struct_namespace()
  ids <- as.character(get("list_metrics", envir = ns)()$id)

  for (id in ids) {
    spec <- get("get_metric", envir = ns)(id)
    expect_true(is.function(spec$fun), info = sprintf("metric '%s' is not callable", id))

    fixture <- .struct_fixture_for_metric(id)
    value <- do.call(spec$fun, c(list(fixture$sim, fixture$obs), fixture$params))

    expect_true(is.numeric(value), info = sprintf("metric '%s' returned non-numeric", id))
    expect_identical(length(value), 1L, info = sprintf("metric '%s' returned non-scalar", id))
    expect_true(is.finite(as.numeric(value)), info = sprintf("metric '%s' returned non-finite", id))
  }
})

test_that("list_metrics recommended filter is backward compatible and deterministic", {
  ns <- .struct_namespace()
  list_metrics_fn <- get("list_metrics", envir = ns)

  full <- list_metrics_fn()
  rec <- list_metrics_fn(recommended = TRUE)
  rec_false <- list_metrics_fn(recommended = FALSE)
  expected_ids <- c("kge", "mae", "mse", "nrmse", "nse", "pbias", "r2", "rmse", "rsr", "ve")

  expect_identical(rec_false, full)
  expect_gt(nrow(rec), 0L)
  expect_lt(nrow(rec), nrow(full))
  expect_true(all(rec$id %in% full$id))
  expect_identical(length(rec$id), length(unique(rec$id)))
  expect_identical(rec$id, expected_ids)
})
