#' Separate with data.table
#'
#' Separates a column of data into others, by splitting based a separator or regular expression
#'
#' @param dt_ the data table (or if not a data.table then it is coerced with as.data.table)
#' @param col the column to separate
#' @param into the names of the new columns created from splitting `col`.
#' @param sep the regular expression stating how `col` should be separated. Default is `.`.
#' @param remove should `col` be removed in the returned data table? Default is `TRUE`
#' @param fill if empty, fill is inserted. Default is `NA`.
#' @param fixed logical. If TRUE match split exactly, otherwise use regular expressions. Has priority over perl.
#' @param by_reference should the data table be copied before separating? Default is no (i.e. mutate by reference).
#' @param ... arguments passed to `data.table::tstrplit()`
#'
#' @examples
#'
#' library(data.table)
#' d <- data.table(x = c("A.B", "A", "B", "B.A"),
#'                 y = 1:4)
#' # need to assign when `by_reference = FALSE`
#' separated <- dt_separate(d, x, c("c1", "c2"), by_reference = FALSE)
#' separated
#' # don't need to assign when `by_reference = TRUE` (default)
#' dt_separate(d, x, c("c1", "c2"), remove = FALSE)
#' d
#' dt_separate(d, x, c("c1", "c2"))
#' d
#'
#' @importFrom data.table tstrsplit as.data.table copy
#'
#' @export
dt_separate <- function(dt_, col, into,
                        sep = ".",
                        remove = TRUE,
                        fill = NA,
                        fixed = TRUE,
                        by_reference = TRUE,
                        ...){
  UseMethod("dt_separate", dt_)
}

#' @export
dt_separate.default <- function(dt_, col, into,
                                sep = ".",
                                remove = TRUE,
                                fill = NA,
                                fixed = TRUE,
                                by_reference = TRUE,
                                ...){

  # checks and nse
  if (isFALSE(is.data.table(dt_))) dt_ <- data.table::as.data.table(dt_)
  if (isTRUE(remove)) to_remove <- substitute(col)
  if (isFALSE(by_reference)) dt_ <- data.table::copy(dt_)
  j <- substitute(col)

  # use data.table::tstrsplit() to do the heavy lifting
  split_it <- quote(
    `:=`(eval(into),
         data.table::tstrsplit(
           eval(j),
           split = sep,
           fill = fill,
           fixed = fixed,
           ...)))

  # removing col if remove = TRUE
  if (isTRUE(remove))
    dt_[, eval(split_it)][, `:=`(paste(to_remove), NULL)]
  # keep col if remove = FALSE
  if (isFALSE(remove))
    dt_[, eval(split_it)]
}



