\name{NSeff}
\alias{NSeff}
\title{Legacy NSE Alias}
\usage{
NSeff(sim, obs, ...)
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
Compatibility alias that evaluates \code{nse} through the existing \code{gof()} pipeline.
}
