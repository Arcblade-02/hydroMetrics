\name{valindex}
\alias{valindex}
\title{Compatibility Wrapper for Selected Metrics}
\usage{
valindex(sim, obs, fun = NULL, ...)
}
\arguments{
  \item{sim}{Simulated values.}

  \item{obs}{Observed values.}

  \item{fun}{Metric names to evaluate; required.}

  \item{...}{Additional arguments forwarded to \code{gof()}.}
}
\value{
The same structured \code{"hydro_metrics"} object returned by \code{gof()}.
}
\description{
Thin compatibility wrapper that dispatches to \code{gof(methods = fun, ...)}.
}
