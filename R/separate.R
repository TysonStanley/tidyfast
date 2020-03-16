#' Separate columns with data.table
#'
#' Separates a column of data into others, by splitting based a separator or regular expression
#'
#' @param dt_ the data table (or if not a data.table then it is coerced with as.data.table)
#' @param col the column to separate
#' @param into the names of the new columns created from splitting \code{col}.
#' @param sep the regular expression stating how \code{col} should be separated. Default is \code{.}.
#' @param remove should \code{col} be removed in the returned data table? Default is \code{TRUE}
#' @param fill if empty, fill is inserted. Default is \code{NA}.
#' @param fixed logical. If TRUE match split exactly, otherwise use regular expressions. Has priority over perl.
#' @param immutable If \code{TRUE}, \code{.dt} is treated as immutable (it will not be modified in place). Alternatively, you can set \code{immutable = FALSE} to modify the input object.
#' @param ... arguments passed to \code{data.table::tstrplit()}
#'
#'
#' @return A data.table with a column split into multiple columns.
#'
#' @examples
#'
#' library(data.table)
#' d <- data.table(x = c("A.B", "A", "B", "B.A"),
#'                 y = 1:4)
#'
#' # defaults
#' dt_separate(d, x, c("c1", "c2"))
#'
#' # can keep the original column with `remove = FALSE`
#' dt_separate(d, x, c("c1", "c2"), remove = FALSE)
#'
#' # need to assign when `immutable = TRUE`
#' separated <- dt_separate(d, x, c("c1", "c2"), immutable = TRUE)
#' separated
#'
#' # don't need to assign when `immutable = FALSE` (default)
#' dt_separate(d, x, c("c1", "c2"), immutable = FALSE)
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
                        immutable = TRUE,
                        ...){
  UseMethod("dt_separate", dt_)
}

#' @export
dt_separate.default <- function(dt_, col, into,
                                sep = ".",
                                remove = TRUE,
                                fill = NA,
                                fixed = TRUE,
                                immutable = TRUE,
                                ...){

  # checks and nse
  if (isFALSE(is.data.table(dt_))) dt_ <- data.table::as.data.table(dt_)
  if (isTRUE(remove)) to_remove <- substitute(col)
  if (isTRUE(immutable)) dt_ <- data.table::copy(dt_)
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

  dt_
}



