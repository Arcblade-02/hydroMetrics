\name{pbias}
\alias{pbias}
\title{Percent Bias}
\usage{
pbias(sim, obs, ...)
}
\arguments{
  \item{sim}{Simulated values.}

  \item{obs}{Observed values.}

  \item{...}{Additional arguments passed to preprocessing via \code{gof()}.}
}
\value{
A numeric scalar for single-series input, or a numeric matrix for multi-series input.
}
\description{
Compute percent bias (PBIAS) between simulated and observed series.
}
