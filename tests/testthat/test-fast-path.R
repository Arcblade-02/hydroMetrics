.hm_fast_path_test_env <- if ("package:hydroMetrics" %in% search()) {
  asNamespace("hydroMetrics")
} else {
  env <- new.env(parent = globalenv())
  root <- if (dir.exists("R")) {
    "."
  } else if (dir.exists(file.path("..", "..", "R"))) {
    file.path("..", "..")
  } else {
    stop("Could not locate package root for standalone fast-path tests.", call. = FALSE)
  }
  r_files <- sort(list.files(file.path(root, "R"), pattern = "[.][Rr]$", full.names = TRUE))
  for (path in r_files) {
    sys.source(path, envir = env)
  }
  env
}

.hm_fast_path_get <- function(name) {
  get(name, envir = .hm_fast_path_test_env, inherits = FALSE)
}

.hm_fast_path_exports <- function() {
  if ("package:hydroMetrics" %in% search()) {
    return(getNamespaceExports("hydroMetrics"))
  }

  ns_path <- if (file.exists("NAMESPACE")) {
    "NAMESPACE"
  } else if (file.exists(file.path("..", "..", "NAMESPACE"))) {
    file.path("..", "..", "NAMESPACE")
  } else {
    stop("Could not locate NAMESPACE for standalone fast-path tests.", call. = FALSE)
  }

  ns_lines <- readLines(ns_path, warn = FALSE)
  sub("^export\\(([^)]+)\\)$", "\\1", grep("^export\\(", ns_lines, value = TRUE))
}

test_that("public compatibility wrapper surface matches the exported contract", {
  exported_expected <- c(
    "gof", "NSeff", "mNSeff", "rNSeff", "wsNSeff",
    "pbias", "mae", "r", "rsr", "alpha", "beta"
  )
  uppercase_absent <- c("NSE", "KGE", "RMSE", "R2", "NRMSE", "PBIAS")

  ns_exports <- .hm_fast_path_exports()

  expect_true(all(exported_expected %in% ns_exports))
  expect_true(all(vapply(
    exported_expected,
    exists,
    logical(1),
    mode = "function",
    envir = .hm_fast_path_test_env,
    inherits = FALSE
  )))
  expect_false(any(uppercase_absent %in% ns_exports))
  expect_true(all(!vapply(
    uppercase_absent,
    exists,
    logical(1),
    mode = "function",
    envir = .hm_fast_path_test_env,
    inherits = FALSE
  )))
})

test_that("public compatibility wrappers produce valid results on simple numeric input", {
  sim <- c(1.1, 2.2, 2.8, 4.1, 5.2)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  wrappers <- c("NSeff", "mNSeff", "rNSeff", "wsNSeff", "pbias", "mae", "r", "rsr", "alpha", "beta")

  for (wrapper_name in wrappers) {
    value <- .hm_fast_path_get(wrapper_name)(sim, obs)
    expect_true(is.numeric(value), info = wrapper_name)
    expect_identical(length(value), 1L, info = wrapper_name)
  }
})

test_that("eligible wrappers match gof() engine results on plain numeric input", {
  sim <- c(1.1, 2.2, 2.8, 4.1, 5.2)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  wrappers <- c(
    NSeff = "nse",
    mNSeff = "mnse",
    rNSeff = "rnse",
    wsNSeff = "wsnse",
    pbias = "pbias",
    mae = "mae",
    r = "r",
    rsr = "rsr",
    alpha = "alpha",
    beta = "beta"
  )

  for (wrapper_name in names(wrappers)) {
    wrapper <- .hm_fast_path_get(wrapper_name)
    metric_id <- wrappers[[wrapper_name]]
    expected <- .hm_fast_path_get("gof")(sim, obs, methods = metric_id)
    expect_equal(
      wrapper(sim, obs),
      as.numeric(expected[[1L]]),
      info = wrapper_name
    )
  }
})

test_that("fast-path predicate is conservative", {
  eligible <- .hm_fast_path_get(".hm_fast_path_eligible")

  expect_true(eligible(c(1, 2, 3), c(1, 2, 3)))
  expect_false(eligible(c(1, NA, 3), c(1, 2, 3)))
  expect_false(eligible(ts(c(1, 2, 3), frequency = 1), ts(c(1, 2, 3), frequency = 1)))
  expect_false(eligible(cbind(a = c(1, 2, 3)), cbind(a = c(1, 2, 3))))
  expect_false(eligible(c(1, 2, 3), c(1, 2, 3), na.rm = TRUE))
  expect_false(eligible(c(1, 2, 3), c(1, 2, 3), dots = list(transform = "log")))
})

test_that("NA input falls back without changing wrapper behavior", {
  sim <- c(1.1, NA, 2.8, 4.1, 5.2)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  expect_false(.hm_fast_path_get(".hm_fast_path_eligible")(sim, obs))
  expect_error(
    .hm_fast_path_get("NSeff")(sim, obs),
    "Missing values found"
  )
  expect_error(
    .hm_fast_path_get("gof")(sim, obs, methods = "nse"),
    "Missing values found"
  )
})

test_that("classed time-series input falls back safely", {
  sim <- ts(c(1.1, 2.2, 2.8, 4.1, 5.2), frequency = 1)
  obs <- ts(c(1.0, 2.0, 3.0, 4.0, 5.0), frequency = 1)

  expect_false(.hm_fast_path_get(".hm_fast_path_eligible")(sim, obs))
  expect_equal(
    .hm_fast_path_get("NSeff")(sim, obs),
    as.numeric(.hm_fast_path_get("gof")(sim, obs, methods = "nse")[[1L]])
  )
})

test_that("multi-series input falls back safely", {
  sim <- cbind(a = c(1.1, 2.2, 2.8, 4.1, 5.2), b = c(1.2, 2.0, 3.1, 3.9, 5.4))
  obs <- cbind(a = c(1.0, 2.0, 3.0, 4.0, 5.0), b = c(1.1, 2.1, 3.0, 4.0, 5.1))

  expect_false(.hm_fast_path_get(".hm_fast_path_eligible")(sim, obs))
  out <- .hm_fast_path_get("NSeff")(sim, obs)
  ref <- .hm_fast_path_get("gof")(sim, obs, methods = "nse")

  expect_true(is.matrix(out))
  expect_equal(as.numeric(out), as.numeric(ref))
  expect_identical(dim(out), dim(ref))
  expect_identical(dimnames(out), dimnames(ref))
  expect_identical(attr(out, "n_obs"), attr(ref, "n_obs"))
  expect_equal(attr(out, "meta"), attr(ref, "meta"))
})

test_that("wrapper API surface stays unchanged on fast-path output", {
  sim <- c(1.1, 2.2, 2.8, 4.1, 5.2)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  expect_true(is.numeric(.hm_fast_path_get("NSeff")(sim, obs)))
  expect_true(is.numeric(.hm_fast_path_get("pbias")(sim, obs)))
  expect_true(is.numeric(.hm_fast_path_get("mae")(sim, obs)))
})
