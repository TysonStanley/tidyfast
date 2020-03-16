#' Fast Nesting
#'
#' Quickly nest data tables (similar to \code{dplyr::group_nest()}).
#'
#' @param dt_ the data table to nest
#' @param ... the variables to group by
#' @param .key the name of the list column; default is "data"
#'
#' @examples
#'
#' library(data.table)
#' dt <- data.table(
#'   x = rnorm(1e5),
#'   y = runif(1e5),
#'   grp = sample(1L:3L, 1e5, replace = TRUE)
#'   )
#'
#' dt_nest(dt, grp)
#'
#' @return A data.table with a list column containing data.tables
#'
#' @import data.table
#'
#' @export
dt_nest <- function(dt_, ..., .key = "data"){
  UseMethod("dt_nest", dt_)
}

#' @export
dt_nest.default <- function(dt_, ..., .key = "data"){

  # change to data.table
  if (isFALSE(is.data.table(dt_)))
    dt_ <- as.data.table(dt_)

  # groups
  by <- substitute(list(...))

  # call to data.table
  dt_ <- dt_[, list(list(.SD)), keyby = eval(by)]
  setnames(dt_, old = "V1", new = .key)
  dt_

}

