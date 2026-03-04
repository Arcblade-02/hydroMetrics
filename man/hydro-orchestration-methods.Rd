\name{hydro-orchestration-methods}
\alias{as.numeric.hydro_metrics}
\alias{as.double.hydro_metrics}
\alias{print.hydro_metrics}
\alias{print.hydro_metrics_batch}
\alias{print.hydro_preproc}
\title{S3 Methods for hydroMetrics Orchestration Objects}
\usage{
\method{as.double}{hydro_metrics}(x, ...)

\method{as.numeric}{hydro_metrics}(x, ...)

\method{print}{hydro_metrics}(x, ...)

\method{print}{hydro_metrics_batch}(x, ...)

\method{print}{hydro_preproc}(x, ...)
}
\arguments{
  \item{x}{An orchestration object returned by \code{gof()}, \code{ggof()}, or \code{preproc()}.}

  \item{...}{Additional arguments passed to the underlying print helpers.}
}
\value{
\code{as.double.hydro_metrics()} and \code{as.numeric.hydro_metrics()} return the unclassed numeric metric values.
Print methods return \code{x} invisibly.
}
\description{
Minimal S3 methods for compatibility orchestration return types.
}
