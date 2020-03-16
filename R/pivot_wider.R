#' Pivot data from long to wide
#'
#'
#' \code{dt_pivot_wider()} "widens" data, increasing the number of columns and
#' decreasing the number of rows. The inverse transformation is
#' \code{dt_pivot_longer()}. Syntax based on the \code{tidyr} equivalents.
#'
#' @param dt_ the data table to widen
#' @param id_cols A set of columns that uniquely identifies each observation. Defaults to all columns in the data table except for the columns specified in \code{names_from} and \code{values_from}. Typically used when you have additional variables that is directly related.
#' @param names_from A pair of arguments describing which column (or columns) to get the name of the output column (\code{name_from}), and which column (or columns) to get the cell values from (\code{values_from}).
#' @param names_sep the separator between the names of the columns
#' @param values_from A pair of arguments describing which column (or columns) to get the name of the output column (\code{name_from}), and which column (or columns) to get the cell values from (\code{values_from}).
#'
#' @return A reshaped data.table into wider format
#'
#' @examples
#'
#' library(data.table)
#' example_dt <- data.table(z = rep(c("a", "b", "c"), 2),
#'                          stuff = c(rep("x", 3), rep("y", 3)),
#'                          things = 1:6)
#'
#' dt_pivot_wider(example_dt, names_from = stuff, values_from = things)
#' dt_pivot_wider(example_dt, names_from = stuff, values_from = things, id_cols = z)
#'
#' @importFrom data.table dcast
#' @importFrom stats as.formula
#'
#' @export
dt_pivot_wider <- function(dt_,
                           id_cols = NULL,
                           names_from,
                           names_sep = "_",
                           values_from){
  UseMethod("dt_pivot_wider", dt_)
}

#' @export
dt_pivot_wider.default <- function(dt_,
                                   id_cols = NULL,
                                   names_from,
                                   names_sep = "_",
                                   values_from) {

  if (!is.data.frame(dt_)) stop("dt_ must be a data.frame or data.table")
  if (!is.data.table(dt_)) dt_ <- as.data.table(dt_)

  names_from <- column_selector(dt_, substitute(c(names_from)))
  values_from <- column_selector(dt_, substitute(c(values_from)))


  if (is.null(substitute(id_cols))) {
    id_cols <- colnames(dt_)[!colnames(dt_) %in% c(names_from, values_from)]
  } else {
    id_cols <- column_selector(dt_, substitute(c(id_cols)))
  }

  if (length(id_cols) == 0) {
    dcast_form <- as.formula(paste("...",
                                   paste(names_from, collapse = " + "),
                                   sep = " ~ "))
  } else {
    dcast_form <- as.formula(paste(paste(id_cols, collapse = " + "),
                                   paste(names_from, collapse=" + "),
                                   sep=" ~ "))
  }

  if (length(id_cols) == 0) {
    dcast.data.table(
      dt_,
      formula = dcast_form,
      value.var = values_from,
      fun.aggregate = NULL,
      sep = names_sep,
      drop = TRUE)[, . := NULL][]
  } else {
    dcast.data.table(
      dt_,
      formula = dcast_form,
      value.var = values_from,
      fun.aggregate = NULL,
      sep = names_sep,
      drop = TRUE)
  }
}
