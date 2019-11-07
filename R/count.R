#' Count
#'
#' Count the numbers of observations within groups
#'
#' @param dt the data table to uncount
#' @param ... groups
#' @param na.rm should any rows with missingness be removed before the count? Default is `FALSE`.
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
#' dt_count(dt, grp)
#' dt_count(dt, grp, na.rm = TRUE)
#'
#' @import data.table
#' @importFrom stats complete.cases
#'
#' @export
dt_count <- function(dt, ..., na.rm = FALSE){

  if (isFALSE(is.data.table(dt)))
    dt <- as.data.table(dt)

  dots <- substitute(list(...))

  if (na.rm)
    dt <- dt[complete.cases(dt)]

  dt[, .N, by = eval(dots)]
}

