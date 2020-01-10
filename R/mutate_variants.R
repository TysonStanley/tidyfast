#' Mutate
#'
#' @description
#'
#' Edit existing columns. There are three variants:
#'
#' * `dt_mutate_if()`
#' * `dt_mutate_at()`
#' * `dt_mutate_all()`
#'
#' @import data.table
#' @md
#' @usage
#'
#' dt_mutate_if(dt_, .predicate, .fun, ...)
#' dt_mutate_at(dt_, .vars, .fun, ...)
#' dt_mutate_all(dt_, .fun, ...)
#'
#' @param dt_ A data.frame or data.table
#' @param .predicate Predicate to specify columns for `dt_mutate_if()`
#' @param .vars `list()` or vector `c()` of bare variables for `dt_mutate_at()` to use
#' @param .fun Function to pass
#' @param ... Other arguments for the passed function
#'
#' @return A data.table
#' @import data.table
#' @export
#'
#' @examples
#' library(tidyfast)
#' library(data.table)
#'
#' example_dt <- data.table(x = c(1,2,3), y = c(4,5,6), z = c("a", "a", "b"))
#'
#' example_dt %>%
#'   dt_mutate_if(is.double, as.character)
#'
#' example_dt %>%
#'   dt_mutate_at(list(x, y), function(.x) .x * 2)
dt_mutate_if <- function(dt_, .predicate, .fun, ...) {

  if (!is.data.frame(dt_)) stop(".data must be a data.frame or data.table")
  if (!is.data.table(dt_)) dt_ <- as.data.table(dt_)

  .cols <- colnames(dt_)[dt_map_lgl(dt_, .predicate)]

  if (length(.cols) > 0) {
    dt_[, (.cols) := lapply(.SD, .fun, ...), .SDcols = .cols][]
  } else {
    dt_
  }
}

#' @export
#' @rdname dt_mutate_if
dt_mutate_at <- function(dt_, .vars, .fun, ...) {

  if (!is.data.frame(dt_)) stop(".data must be a data.frame or data.table")
  if (!is.data.table(dt_)) dt_ <- as.data.table(dt_)

  .cols <- column_selector(dt_, substitute(c(.vars)))

  if (length(.cols) > 0) {
    dt_[, (.cols) := lapply(.SD, .fun, ...), .SDcols = .cols][]
  } else {
    dt_
  }
}

#' @export
#' @rdname dt_mutate_if
dt_mutate_all <- function(dt_, .fun, ...) {

  if (!is.data.frame(dt_)) stop(".data must be a data.frame or data.table")
  if (!is.data.table(dt_)) dt_ <- as.data.table(dt_)

  .cols <- colnames(dt_)

  dt_[, (.cols) := lapply(.SD, .fun, ...), .SDcols = .cols][]
}
