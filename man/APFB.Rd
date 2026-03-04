\name{APFB}
\alias{APFB}
\title{Annual Peak Flow Bias}
\usage{
APFB(sim, obs, ...)
}
\arguments{
  \item{sim}{Univariate simulated series as a zoo/xts object with a time index.}

  \item{obs}{Univariate observed series as a zoo/xts object with a time index.}

  \item{...}{Additional arguments passed to \code{preproc()}.}
}
\value{
A numerically coercible scalar with class \code{c("hydro_metric_scalar", "numeric")} and attributes:
\code{metric}, \code{n_obs}, \code{meta}, and \code{call}.
}
\description{
Compute annual peak flow bias as the mean percent bias between annual simulated and observed maxima.
}
