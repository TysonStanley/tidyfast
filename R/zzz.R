.onLoad <- function(libname = find.package("tidyfast"), pkgname = "tidyfast") {
  if (getRversion() >= "2.15.1") {
    utils::globalVariables(c("..others", ".", "..keep"))
  }
  invisible()
}
