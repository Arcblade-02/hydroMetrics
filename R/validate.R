validate_numeric_vector <- function(x, name, allow_na = FALSE) {
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    stop("`name` must be a non-empty character scalar.", call. = FALSE)
  }
  if (!is.atomic(x) || !is.numeric(x)) {
    stop(sprintf("`%s` must be a numeric vector.", name), call. = FALSE)
  }
  if (!allow_na && anyNA(x)) {
    stop(sprintf("`%s` must not contain NA values.", name), call. = FALSE)
  }
  invisible(TRUE)
}

validate_equal_length <- function(sim, obs) {
  if (length(sim) != length(obs)) {
    stop("`sim` and `obs` must have the same length.", call. = FALSE)
  }
  invisible(TRUE)
}

validate_finite <- function(sim, obs, allow_inf = FALSE) {
  if (any(is.nan(sim)) || any(is.nan(obs))) {
    stop("`sim` and `obs` must not contain NaN values.", call. = FALSE)
  }
  if (!allow_inf && (any(is.infinite(sim)) || any(is.infinite(obs)))) {
    stop("`sim` and `obs` must not contain infinite values.", call. = FALSE)
  }
  invisible(TRUE)
}
