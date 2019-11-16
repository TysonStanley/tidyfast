#' Unnest: Fast Unnesting of Data Tables
#'
#' Quickly unnest data tables, particularly those nested by `dt_nest()`.
#'
#' @param dt_ the data table to unnest
#' @param col  the column to unnest
#' @param by the ID variable to unnest by. Default is `NULL`.
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
#' dt_unnest(nested, col = data, by = grp)
#'
#' @import data.table
#'
#' @export
dt_unnest <- function(dt_, col, by = NULL){
  if (isFALSE(is.data.table(dt_)))
    dt_ <- as.data.table(dt_)

  by <- substitute(by)
  col <- substitute(unlist(col, recursive = FALSE))

  if (.is_null(by)){
    dt_ <- dt_[, eval(col)]
  } else {
    dt_ <- dt_[, eval(col), by = eval(by)]
  }

  if (.length_by_1(by))
    setnames(dt_, old = "by", paste(substitute(by)))

  dt_
}

.length_by_1 <- function(by){
  char <- paste(by)
  char <- char[-grepl("^\\.|^list|^c$", char)]
  length(char) == 1
}


.is_null <- function(id){
  length(paste(id)) == 0
}

#' Hoist: Fast Unnesting of Vectors
#'
#' Quickly unnest vectors nested in list columns. Still experimental (has some potentially unexpected behavior in some situations)!
#'
#' @param dt_ the data table to unnest
#' @param ... the columns to unnest (must all be the sample length when unnested); use bare names of the variables
#' @param by the variable that indicates what to unnest by.
#'
#' @aliases dt_unnest_vec
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
#' dt_hoist(dt,
#'          nested1, nested2,
#'          by = id)
#'
#' @import data.table
#'
#' @export
dt_hoist <- function(dt_, ..., by = NULL){
  if (isFALSE(is.data.table(dt_)))
    dt_ <- as.data.table(dt_)

  by <- substitute(by)
  cols <- substitute(unlist(list(...), recursive = FALSE))

  dt_ <- dt_[, eval(cols), by = eval(by)]
  dt_ <- .naming(dt_, substitute(list(...)), by)
  dt_
}

.naming <- function(dt_, cols, by){

  new_names <- paste(cols)[-1]
  old_names <- paste0("V", seq_along(new_names))

  if (!.is_null(by))
    old_names <- c(old_names, "by")

  setnames(dt_,
           old = old_names,
           new = c(new_names, paste(by)),
           skip_absent = TRUE)
  dt_
}

