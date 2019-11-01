#' Fill with data.table
#'
#' Fills in values, similar to `tidyr::fill()`, by within `data.table`. This function relies on the
#' `Rcpp` functions that drive `tidyr::fill()` but applies them within `data.table`.
#'
#' @param dt the data table (or if not a data.table then it is coerced with as.data.table)
#' @param ... the columns to fill
#' @param id the grouping variable(s) to fill within
#' @param order should the table be ordered first? default is NULL (which assumes the table is already in the right order). Other option is to indicate variable(s) to order by.
#' @param .direction either "down" or "up" (down fills values down, up fills values up), or "downup" (down first then up) or "updown" (up first then down)
#'
#' @examples
#'
#' set.seed(84322)
#' library(data.table)
#'
#' x = 1:10
#' dt = data.table(v1 = x,
#'                 v2 = shift(x),
#'                 v3 = shift(x, -1L),
#'                 v4 = sample(c(rep(NA, 10), x), 10),
#'                 grp = sample(1:3, 10, replace = TRUE))
#' dt_fill(dt, v2, v3, v4, id = grp, .direction = "downup")
#' dt_fill(dt, v2, v3, v4, id = grp)
#' dt_fill(dt, .direction = "up")
#'
#' @importFrom data.table as.data.table
#'
#' @export
dt_fill <- function(dt, ..., id = NULL, order = NULL, .direction = c("down", "up", "downup", "updown")){

  if (isFALSE(is.data.table(dt)))
    dt <- data.table::as.data.table(dt)

  .direction <- match.arg(.direction)
  fun <- switch(.direction,
                "down"   = fillDown,
                "up"     = fillUp,
                "downup" = function(x) fillUp(fillDown(x)),
                "updown" = function(x) fillDown(fillUp(x)))

  dots  <- paste_dots(...)
  by    <- substitute(id)
  order <- substitute(order)

  if (isFALSE(is.null(order))){
    dt <- dt[order(eval(order)), lapply(.SD, fun), by = eval(by), .SDcols = dots]
  } else {
    dt <- dt[, lapply(.SD, fun), by = eval(by), .SDcols = dots]
  }

  dt
}

paste_dots <- function(...){
  paste(substitute(c(...)))[-1]
}
