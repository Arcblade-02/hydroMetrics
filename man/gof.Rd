\name{gof}
\alias{gof}
\title{Evaluate Hydrological Metrics}
\usage{
gof(
  sim,
  obs,
  methods = NULL,
  na_strategy = c("fail", "remove", "pairwise"),
  transform = c("none", "log", "sqrt", "reciprocal"),
  epsilon_mode = c("constant", "auto_min_positive", "obs_mean_factor"),
  epsilon = NULL,
  epsilon_factor = 1,
  components = FALSE,
  ...
)
}
\arguments{
  \item{sim}{Simulated values (single-series or matrix-like).}

  \item{obs}{Observed values (single-series or matrix-like with matching dimensions).}

  \item{methods}{Metric names to evaluate. Defaults to package core defaults.}

  \item{na_strategy}{Missing-value strategy forwarded to \code{preproc()}.}

  \item{transform}{Transform mode forwarded to \code{preproc()}.}

  \item{epsilon_mode}{Epsilon mode forwarded to \code{preproc()}.}

  \item{epsilon}{Optional epsilon value for \code{epsilon_mode = "constant"}.}

  \item{epsilon_factor}{Epsilon scaling factor for automatic modes.}

  \item{components}{Compatibility flag retained in metadata.}

  \item{...}{Additional compatibility arguments, including \code{metric_params}.}
}
\value{
A structured object with class \code{"hydro_metrics"}:
\code{metrics}, \code{n_obs}, \code{meta}, and \code{call}.
Metric names are also exposed as list elements for \code{$}-access compatibility.
}
\description{
Compatibility metric orchestrator that preprocesses data and dispatches registered
metrics through the hydroMetrics evaluation engine without embedding metric formulas.
}
