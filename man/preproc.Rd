\name{preproc}
\alias{preproc}
\title{Preprocess Hydrological Series}
\usage{
preproc(
  sim,
  obs,
  na_strategy = c("fail", "remove", "pairwise"),
  transform = c("none", "log", "sqrt", "reciprocal"),
  epsilon_mode = c("constant", "auto_min_positive", "obs_mean_factor"),
  epsilon = NULL,
  epsilon_factor = 1,
  ...
)
}
\arguments{
  \item{sim}{Simulated values (numeric, ts, zoo, or xts single series).}

  \item{obs}{Observed values (numeric, ts, zoo, or xts single series).}

  \item{na_strategy}{Missing-value strategy used by the preprocessing engine.}

  \item{transform}{Optional transform applied after NA handling.}

  \item{epsilon_mode}{Epsilon policy used when a transform requires adjustment.}

  \item{epsilon}{Constant epsilon value used when \code{epsilon_mode = "constant"}.}

  \item{epsilon_factor}{Scaling factor for automatic epsilon modes.}

  \item{...}{Compatibility arguments (for example \code{na.rm} and \code{keep}).}
}
\value{
A list with class \code{"hydro_preproc"} containing processed vectors and metadata:
\code{sim}, \code{obs}, \code{n_original}, \code{n_aligned}, \code{n_removed_na},
\code{transform_applied}, and \code{epsilon_details}.
}
\description{
Public compatibility wrapper over the internal Phase 2A preprocessing engine.
}
