#' Count
#'
#' Count the numbers of observations within groups
#'
#' @param dt_ the data table to uncount
#' @param ... groups
#' @param na.rm should any rows with missingness be removed before the count? Default is \code{FALSE}.
#' @param wt the wt assigned to the counts (same number of rows as the data)
#'
#' @return A data.table with counts for each group (or combination of groups)
#'
#' @examples
#'
#' library(data.table)
#' dt <- data.table(
#'   x = rnorm(1e5),
#'   y = runif(1e5),
#'   grp = sample(1L:3L, 1e5, replace = TRUE),
#'   wt = runif(1e5, 1, 100)
#'   )
#'
#' dt_count(dt, grp)
#' dt_count(dt, grp, na.rm = TRUE)
#' dt_count(dt, grp, na.rm = TRUE, wt = wt)
#'
#' @import data.table
#' @importFrom stats complete.cases
#'
#' @export
dt_count <- function(dt_, ..., na.rm = FALSE, wt = NULL){
  UseMethod("dt_count", dt_)
}

#' @export
dt_count.default <- function(dt_, ..., na.rm = FALSE, wt = NULL){

  if (isFALSE(is.data.table(dt_)))
    .dt <- as.data.table(dt_)

  dots <- substitute(list(...))
  wt <- substitute(wt)

  if (na.rm)
    dt_ <- dt_[complete.cases(dt_)]

  if (!is.null(wt))
    return(dt_[, list(N = sum(eval(wt))), keyby = eval(dots)])

  dt_[, .N, keyby = eval(dots)]
}


#' @export
dt_count.dtplyr_step <- function(dt_, ..., na.rm = FALSE, wt = NULL){
  # collect data from lazy state
  dt_ <- as.data.table(dt_)

  expr <- substitute(dt_count.defaul(dt_, ..., na.rm = na.rm, wt = wt))
  out <- eval(expr)

  # return to lazy state
  dtplyr::lazy_dt(out)
}


