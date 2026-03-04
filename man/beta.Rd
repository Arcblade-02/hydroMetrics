\name{beta}
\alias{beta}
\title{Bias Ratio Component}
\usage{
beta(sim, obs, ...)
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
Compute the KGE bias-ratio component beta defined as \code{mean(sim) / mean(obs)}.
}
