#' Fast Unnesting of Data Tables
#'
#' Quickly unnest data tables.
#'
#' @param dt the data table to nest
#' @param col  the column to unnest
#' @param id the ID variable to unnest by
#'
#' @import data.table
#'
#' @export
unnest_dt <- function(dt, col, id){
  stopifnot(is.data.table(dt))

  by <- substitute(id)
  col <- substitute(unlist(col, recursive = FALSE))

  dt[, eval(col), by = eval(by)]
}

#' Fast Unnesting of Vectors
#'
#' Quickly nest vectors nested in a list column.
#'
#' @param dt the data table to nest
#' @param cols  the columns to unnest
#' @param id the ID variable to unnest by
#' @param name the names of the unnested vectors
#'
#' @import data.table
#'
#' @export
unnest_vec_dt <- function(dt, cols, id, name){
  stopifnot(is.data.table(dt))

  by <- substitute(id)
  cols <- substitute(unlist(cols,recursive = FALSE))

  dt <- dt[, eval(cols), by = eval(by)]
  setnames(dt, old = paste0("V", 1:length(name)), new = name)
  dt
}
