#' Fast Unnesting of Data Tables
#'
#' Quickly unnest data tables.
#'
#' @param dt the data table to nest
#' @param col  the column to unnest
#' @param id the ID variable to unnest by
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
#' nested <- dt_nest(dt, grp)
#' dt_unnest(nested, col = data, id = grp)
#'
#' @import data.table
#'
#' @export
dt_unnest <- function(dt, col, id){
  if (isFALSE(is.data.table(dt)))
    dt <- as.data.table(dt)

  by <- substitute(id)
  col <- substitute(unlist(col, recursive = FALSE))

  dt <- dt[, eval(col), by = eval(by)]
  setnames(dt, old = "by", paste(substitute(id)))
  dt
}

#' Fast Unnesting of Vectors
#'
#' Quickly nest vectors nested in a list column.
#'
#' @param dt the data table to nest
#' @param cols a list of the columns to unnest (must all be the sample length within ids); use bare names of the variables
#' @param id the ID variable to unnest by
#' @param name a character vector of the names to give the unnested vectors
#'
#' @examples
#'
#' library(data.table)
#' dt <- data.table(
#'    x = rnorm(1e5),
#'    y = runif(1e5),
#'    nested1 = lapply(1:10, sample, 10, replace = TRUE),
#'    nested2 = lapply(c("thing1", "thing2"), sample, 10, replace = TRUE),
#'    id = 1:1e5
#'    )
#'
#' dt_unnest_vec(dt,
#'               cols = list(nested1, nested2),
#'               id = id,
#'               name = c("nested1", "nested2"))
#'
#' @import data.table
#'
#' @export
dt_unnest_vec <- function(dt, cols, id, name){
  if (isFALSE(is.data.table(dt)))
    dt <- as.data.table(dt)

  by <- substitute(id)
  cols <- substitute(unlist(cols,recursive = FALSE))

  dt <- dt[, eval(cols), by = eval(by)]
  setnames(dt,
           old = c(paste0("V", 1:length(name)), "by"),
           new = c(name, paste(substitute(id))))
  dt
}
