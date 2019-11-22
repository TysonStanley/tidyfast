#' Set Print Method
#'
#' The function allows the user to define options relating to the print method for `data.table`.
#'
#' @param class should the variable class be printed? (`options("datatable.print.class")`)
#' @param topn the number of rows to print (both head and tail) if `nrows(DT) > nrows`. (`options("datatable.print.topn")`)
#' @param rownames should rownames be printed? (`options("datatable.print.rownames")`)`
#' @param nrows total number of rows to print (`options("datatable.print.nrows")``)
#' @param trunc.cols if `TRUE`, only the columns that fit in the console are printed (with a message stating the variables not shown, similar to `tibbles`; `options("datatable.print.trunc.cols")`). This only works on `data.table` versions higher than `1.12.6` (i.e. not currently available but anticipating the eventual release).
#'
#'
#' @examples
#'
#' dt_print_options(
#'   class = TRUE,
#'   topn = 5,
#'   rownames = TRUE,
#'   nrows = 100,
#'   trunc.cols = TRUE)
#'
#' @importFrom utils packageVersion
#'
#' @export
dt_print_options <- function(class = TRUE,
                             topn = 5,
                             rownames = TRUE,
                             nrows = 100,
                             trunc.cols = TRUE){

  if (isTRUE(class)) options("datatable.print.class" = TRUE)
  options("datatable.print.topn" = topn)
  options("datatable.print.nrows" = nrows)
  options("datatable.print.rownames" = rownames)
  if (packageVersion("data.table") > "1.12.6")
    options("datatable.print.trunc.cols" = trunc.cols)

}
