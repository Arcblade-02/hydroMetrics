.onLoad <- function(libname, pkgname) {
  try(.get_registry(), silent = TRUE)
}
