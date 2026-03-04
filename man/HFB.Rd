\name{HFB}
\alias{HFB}
\title{High Flow Bias}
\usage{
HFB(sim, obs, threshold_prob = 0.9, ...)
}
\arguments{
  \item{sim}{Simulated values.}

  \item{obs}{Observed values.}

  \item{threshold_prob}{Quantile probability used to define high-flow observations.}

  \item{...}{Additional arguments passed to \code{preproc()}.}
}
\value{
A numerically coercible scalar with class \code{c("hydro_metric_scalar", "numeric")} and attributes:
\code{metric}, \code{n_obs}, \code{meta}, and \code{call}.
}
\description{
Compute high-flow percent bias over values where observations are at or above the selected quantile threshold.
}
