\name{alpha}
\alias{alpha}
\title{Variability Ratio Component}
\usage{
alpha(sim, obs, ...)
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
Compute the KGE variability-ratio component alpha defined as \code{sd(sim) / sd(obs)}.
}
