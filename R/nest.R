#' Fast Nesting
#'
#' Quickly nest data tables.
#'
#' @param dt the data table to nest
#' @param ... the variables to group by
#' @param .key the name of the list column; default is "data"
#'
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
#' @import data.table
#'
#' @export
dt_nest <- function(dt, ..., .key = "data"){
  stopifnot(is.data.table(dt))

  by <- substitute(list(...))

  dt <- dt[, list(list(.SD)), by = eval(by)]
  setnames(dt, old = "V1", new = .key)
  dt
}

thing = function(...){
  length(list(...))
}
thing()
