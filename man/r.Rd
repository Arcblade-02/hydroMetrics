\name{r}
\alias{r}
\title{Correlation Component}
\usage{
r(sim, obs, ...)
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
Compute the KGE correlation component \code{r} using Pearson correlation.
}
