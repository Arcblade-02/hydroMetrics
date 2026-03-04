\name{ggof}
\alias{ggof}
\title{Tabular Summary of Metric Results}
\usage{
ggof(
  sim,
  obs,
  methods = NULL,
  na_strategy = c("fail", "remove", "pairwise"),
  transform = c("none", "log", "sqrt", "reciprocal"),
  epsilon_mode = c("constant", "auto_min_positive", "obs_mean_factor"),
  epsilon = NULL,
  epsilon_factor = 1,
  include_meta = FALSE,
  ...
)
}
\arguments{
  \item{sim}{Simulated values.}

  \item{obs}{Observed values.}

  \item{methods}{Metric names passed to \code{gof()}.}

  \item{na_strategy}{Missing-value strategy passed to \code{gof()}.}

  \item{transform}{Transform mode passed to \code{gof()}.}

  \item{epsilon_mode}{Epsilon mode passed to \code{gof()}.}

  \item{epsilon}{Optional epsilon passed to \code{gof()}.}

  \item{epsilon_factor}{Epsilon scaling factor passed to \code{gof()}.}

  \item{include_meta}{Whether to append orchestration metadata columns.}

  \item{...}{Additional arguments forwarded to \code{gof()}.}
}
\value{
A data frame with class \code{c("hydro_metrics_batch", "data.frame")} containing
\code{model}, \code{metric}, \code{value}, and \code{n_obs} columns.
}
\description{
Return a tidy tabular compatibility summary of \code{gof()} metric outputs.
}
