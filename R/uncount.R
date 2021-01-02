#' Uncount
#'
#' Uncount a counted data table
#'
#' @param dt_ the data table to uncount
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
#' uncount[]      # note that `[]` forces the printing
#'
#'
#' @import data.table
#'
#' @return A data.table with a row for each uncounted column.
#'
#' @export
dt_uncount <- function(dt_, weights, .remove = TRUE, .id = NULL){
  UseMethod("dt_uncount", dt_)
}

#' @export
dt_uncount.default <- function(dt_, weights, .remove = TRUE, .id = NULL){

  if (isFALSE(is.data.table(dt_)))
    dt_ <- as.data.table(dt_)

  w <- substitute(weights)
  dt_ <- dt_[rep(1:.N, eval(w))]

  if (.remove)
    dt_[, `:=`(paste(w), NULL)]

  if (!is.null(.id))
    dt_[, `:=`(.id, 1:.N)]

  dt_
}


#' @export
dt_uncount.dtplyr_step <- function(dt_, weights, .remove = TRUE, .id = NULL){

  # collect data from lazy state
  dt_ <- as.data.table(dt_)

  expr <- substitute(dt_uncount.default(dt_, weights=weights,
                                        .remove=.remove, .id=.id))
  out <- eval(expr)

  # return to lazy state
  dtplyr::lazy_dt(out)
}

