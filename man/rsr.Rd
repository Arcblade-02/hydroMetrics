\name{rsr}
\alias{rsr}
\title{RSR Metric}
\usage{
rsr(sim, obs, ...)
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
Compute RSR defined as RMSE divided by the sample standard deviation of observations.
}
