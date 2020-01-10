#' Select variables
#'
#' @description
#' Scoped variants of `select()`
#'
#' @param dt_ A data.table
#' @param .predicate Predicate to specify columns for `dt_select_if()`
#'
#' @import data.table
#' @return A data.table
#' @export
#'
#' @examples
#' library(tidyfast)
#' library(data.table)
#'
#' example_dt <- data.table(x = 1, y = 2, z = "a")
#'
#' example_dt %>% dt_select_if(is.double)
dt_select_if <- function(dt_, .predicate) {

  if (!is.data.frame(dt_)) stop(".data must be a data.frame or data.table")
  if (!is.data.table(dt_)) dt_ <- as.data.table(dt_)

  .cols <- colnames(dt_)[dt_map_lgl(dt_, .predicate)]

  dt_[, .SD, .SDcols = .cols]
}
