#' Fast Nesting
#'
#' Quickly nest data tables.
#'
#' @param dt the data table to nest
#' @param ... the variables to group by
#' @param .key the name of the list column; default is "data"
#'
#' @import data.table
#'
#' @export
nest_dt <- function(dt, ..., .key = "data"){
  stopifnot(is.data.table(dt))

  by <- substitute(list(...))

  dt <- dt[, list(list(.SD)), by = eval(by)]
  setnames(dt, old = "V1", new = .key)
  dt
}


