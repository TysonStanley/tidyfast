#' Uncount
#'
#' Uncount a counted data table
#'
#' @param dt the data table to uncount
#' @param weights the counts for each
#' @param .remove should the weights variable be removed?
#' @param .id an optional new id variable, providing a unique id for each row
#'
#' @examples
#'
#' library(data.table)
#'
#' dt_count <- data.table(
#'   x = LETTERS[1:3],
#'   w = c(2,1,4)
#' )
#' uncount <- dt_uncount(dt_count, w, .id = "id")
#' uncount   # note that if .remove = TRUE or .id is not null
#'           # this won't print the first time
#'           # due to a printing behavior in data.table
#'
#'
#' @import data.table
#'
#' @export
dt_uncount <- function(dt, weights, .remove = TRUE, .id = NULL){

  if (isFALSE(is.data.table(dt)))
    dt <- as.data.table(dt)

  w <- substitute(weights)
  dt <- dt[rep(1:.N, eval(w))]

  if (.remove)
    dt[, `:=`(paste(w), NULL)]

  if (!is.null(.id))
    dt[, `:=`(.id, 1:.N)]

  dt
}
