.onLoad <- function(libname = find.package("furniture"), pkgname = "furniture"){
  if(getRversion() >= "2.15.1") {
    utils::globalVariables(c("..others", "."))
  }
  invisible()
}
