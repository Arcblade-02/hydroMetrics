\name{mae}
\alias{mae}
\title{Mean Absolute Error}
\usage{
mae(sim, obs, ...)
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
Compute mean absolute error (MAE) between simulated and observed series.
}
