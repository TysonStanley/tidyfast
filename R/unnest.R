#' Unnest: Fast Unnesting of Data Tables
#'
#' Quickly unnest data tables, particularly those nested by \code{dt_nest()}.
#'
#' @param dt_ the data table to unnest
#' @param col  the column to unnest
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
#' dt_unnest(nested, col = data)
#'
#' @import data.table
#'
#' @export
dt_unnest <- function(dt_, col){
  UseMethod("dt_unnest", dt_)
}

#' @export
dt_unnest.default <- function(dt_, col){
  if (isFALSE(is.data.table(dt_)))
    dt_ <- as.data.table(dt_)

  col <- substitute(col)
  if (length(col) > 1)
    stop("dt_unnest() currently can only unnest a single column at a time", call. = FALSE)

  names <- colnames(dt_)
  if(!paste(col) %in% names)
    stop("Could not find `cols` in data.table", call. = FALSE)
  others <- names[-match(paste(col), names)]

  dt_[, eval(col)[[1L]], by = others]
}


#' Hoist: Fast Unnesting of Vectors
#'
#' Quickly unnest vectors nested in list columns. Still experimental (has some potentially unexpected behavior in some situations)!
#'
#' @param dt_ the data table to unnest
#' @param ... the columns to unnest (must all be the sample length when unnested); use bare names of the variables
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
#' dt_hoist(dt, nested1, nested2)
#'
#' @import data.table
#'
#' @export
dt_hoist <- function(dt_, ...){
  UseMethod("dt_hoist", dt_)
}

#' @export
dt_hoist.default <- function(dt_, ...){
  if (isFALSE(is.data.table(dt_)))
    dt_ <- as.data.table(dt_)

  pasted_dots <- paste(substitute(list(...)))[-1L]
  classes <- sapply(dt_, class)
  typeofs <- sapply(dt_, typeof)
  v.names <- names(classes)
  keep <- v.names[classes != "list" & typeofs != "list"]
  drop <- v.names[classes == "list" | typeofs == "list"]
  drop <- drop[!drop %in% pasted_dots]
  keep <- keep[!keep %in% pasted_dots]
  keep <- paste(keep, collapse = ",")
  cols <- substitute(unlist(list(...), recursive = FALSE))

  if (length(drop) > 1)
    message("The following columns were dropped because ",
            "they are list-columns (but not being hoisted): ",
            paste(drop, collapse = ", "))

  dt_ <- dt_[, eval(cols), by = keep]
  dt_ <- .naming(dt_, substitute(list(...)))
  dt_
}

.naming <- function(dt_, cols){

  new_names <- paste(cols)[-1]
  old_names <- paste0("V", seq_along(new_names))

  setnames(dt_,
           old = old_names,
           new = new_names,
           skip_absent = TRUE)
  dt_
}
