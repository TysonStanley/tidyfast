#' Fast Nesting
#'
#' Quickly nest data tables.
#'
#' @param dt_ the data table to nest
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
dt_nest <- function(dt_, ..., .key = "data"){

  # work with grouped_df from dplyr
  by <- work_with_grouped_df(dt_, ...)

  # change to data.table
  if (isFALSE(is.data.table(dt_)))
    dt_ <- as.data.table(dt_)

  # Call to data.table
  dt_ <- dt_[, list(list(.SD)), keyby = eval(by)]
  setnames(dt_, old = "V1", new = .key)
  dt_

}

.is.grouped_df <- function(dt_){
  isTRUE(!is.null(attr(dt_, "groups")) && inherits(dt_, "grouped_df"))
}

.by_using_grouped_df <- function(dt_){
  names(attr(dt_, "groups"))[-ncol(attr(dt_, "groups"))]
}

.dots_length <- function(...){
  length(paste(substitute(list(...))))
}

work_with_grouped_df <- function(dt_, ...){
  if (.is.grouped_df(dt_)){
    by <- .by_using_grouped_df(dt_)

    if (.dots_length(...) > 1)
      warning("  Ignoring names in ... because you are using a grouped_df.\n",
              "  Did you use `dplyr::group_by()` earlier with this data?", call. = FALSE)

  } else {
    by <- substitute(list(...))
  }

  by
}
