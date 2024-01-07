#' Set Print Method
#'
#' The function allows the user to define options relating to the print method for \code{data.table}.
#'
#' @param class should the variable class be printed? (\code{options("datatable.print.class")})
#' @param topn the number of rows to print (both head and tail) if \code{nrows(DT) > nrows}. (\code{options("datatable.print.topn")})
#' @param rownames should rownames be printed? (\code{options("datatable.print.rownames")})
#' @param nrows total number of rows to print (\code{options("datatable.print.nrows")})
#' @param trunc.cols if \code{TRUE}, only the columns that fit in the console are printed (with a message stating the variables not shown, similar to \code{tibbles}; \code{options("datatable.print.trunc.cols")}). This only works on \code{data.table} versions higher than \code{1.12.6} (i.e. not currently available but anticipating the eventual release).
#'
#' @return None. This function is used for its side effect of changing options.
#'
#' @examples
#'
#' dt_print_options(
#'   class = TRUE,
#'   topn = 5,
#'   rownames = TRUE,
#'   nrows = 100,
#'   trunc.cols = TRUE
#' )
#' @importFrom utils packageVersion
#'
#' @export
dt_print_options <- function(class = TRUE,
                             topn = 5,
                             rownames = TRUE,
                             nrows = 100,
                             trunc.cols = TRUE) {
  old <- options()
  if (isTRUE(class)) options("datatable.print.class" = TRUE)
  options("datatable.print.topn" = topn)
  options("datatable.print.nrows" = nrows)
  options("datatable.print.rownames" = rownames)
  if (packageVersion("data.table") >= "1.12.9") {
    options("datatable.print.trunc.cols" = trunc.cols)
  }
  invisible(old)
}
