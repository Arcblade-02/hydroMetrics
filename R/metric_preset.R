#' Resolve a documented metric preset to canonical metric ids
#'
#' `metric_preset()` provides a small bridge between discovery and execution.
#' It resolves one or more documented preset-group names to the canonical
#' metric ids accepted by [gof()] `methods = ...`.
#'
#' The helper is intentionally modest for the current Workstream C scope. It
#' returns a plain character vector, does not create a new S3 class, and does
#' not wrap or bypass [gof()].
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
#' @param preset One or more documented preset names.
#' @param exported_only Logical; if `TRUE`, keep only metric ids that also have
#'   an exported wrapper path in the current package surface.
#'
#' @return A character vector of canonical metric ids suitable for
#'   `gof(methods = ...)`.
#' @examples
#' ids <- metric_preset("recommended")
#' ids
#'
#' sim <- c(1.1, 1.9, 3.2, 4.1)
#' obs <- c(1.0, 2.0, 3.0, 4.0)
#' gof(sim, obs, methods = ids)
#' @export
metric_preset <- function(preset, exported_only = FALSE) {
  preset <- .hm_metric_search_validate_presets(preset, "preset")
  exported_only <- .hm_metric_search_validate_flag(exported_only, "exported_only")

  metrics <- .hm_metric_search_table()
  keep <- vapply(metrics$presets, function(group_text) {
    .hm_metric_search_match_preset(group_text, preset)
  }, logical(1))

  out <- metrics[keep, , drop = FALSE]
  if (isTRUE(exported_only)) {
    out <- out[nzchar(out$exported_wrappers), , drop = FALSE]
  }

  unname(out$id)
}
