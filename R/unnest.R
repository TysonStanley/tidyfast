#' Unnest: Fast Unnesting of Data Tables
#'
#' Quickly unnest data tables, particularly those nested by \code{dt_nest()}.
#'
#' @param dt_ the data table to unnest
#' @param col  the column to unnest
#' @param ... any of the other variables in the nested table that you want to keep in the unnested table. Bare variable names. If none are provided, all variables are kept.
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
dt_unnest <- function(dt_, col, ...){
  UseMethod("dt_unnest", dt_)
}

#' @export
dt_unnest.default <- function(dt_, col, ...){
  if (isFALSE(is.data.table(dt_)))
    dt_ <- as.data.table(dt_)

  col    <- substitute(col)
  keep   <- substitute(alist(...))
  names  <- colnames(dt_)
  others <- names[-match(paste(col), names)]
  rows   <- sapply(dt_[[paste(col)]], nrow)

  if (length(keep) > 1)
    others <- others[others %in% paste(keep)[-1]]

  others_dt <- dt_[, ..others]
  classes   <- sapply(others_dt, typeof)
  keep      <- names(classes)[classes != "list"]
  others_dt <- others_dt[, ..keep]
  others_dt <- lapply(others_dt, rep, times = rows)

  dt_[, list(do.call("cbind", others_dt), rbindlist(eval(col)))]
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
#' dt_hoist(dt,
#'          nested1, nested2,
#'          by = id)
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
  keep <- names(classes)[classes != "list" & typeofs != "list"]
  not_kept <- names(classes)[classes == "list" | typeofs == "list"]
  keep <- keep[!keep %in% pasted_dots]
  keep <- paste(keep, collapse = ",")
  cols <- substitute(unlist(list(...), recursive = FALSE))

  message("The following columns were dropped because ",
          "they are list-columns (but not being hoisted): ",
          paste(not_kept, collapse = ", "))

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
