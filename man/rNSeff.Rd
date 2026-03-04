\name{rNSeff}
\alias{rNSeff}
\title{Legacy rNSE Alias}
\usage{
rNSeff(sim, obs, ...)
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
Compatibility alias that evaluates \code{rnse} through the existing \code{gof()} pipeline.
}
