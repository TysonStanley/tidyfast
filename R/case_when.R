#' Case When with data.table
#'
#' Does what `dplyr::case_when()` does, with the same syntax, but with
#' `data.table::fifelse()` under the hood
#'
#' @param ... statements of the form: `condition ~ label``, where the label is applied if the condition is met
#'
#' @import data.table
#'
#' @examples
#'
#' x <- rnorm(1e5)
#'
#' dt_case_when(
#'   x < median(x) ~ "low",
#'   x >= median(x) ~ "high",
#'   is.na(x) ~ "other"
#'   )
#'
#' @export
dt_case_when <- function(...){
  # grab the dots
  dots <- list(...)
  # checking the dots
  .check_dots(dots)
  # extract info from dots
  n <- length(dots)
  conds <- conditions(dots)
  labels <- assigned_label(dots)
  class <- class(labels)

  # make the right NA based on assigned labels
  na_type <-
    switch(class,
           "character" = NA_character_,
           "integer" = NA_integer_,
           "numeric" = NA_real_,
           "double" = NA_real_,
           "Date" = as.Date(NA_real_, "1970-01-01"))

  # create fifelse() call
  calls <- call("fifelse", conds[[n]], labels[[n]], eval(na_type))
  for (i in rev(seq_len(n))[-1]){
    calls <- call("fifelse", conds[[i]], labels[[i]], calls)
  }

  eval(calls, envir = parent.frame())
}

#' fifelse from data.table
#'
#' See \code{data.table::\link[data.table:fifelse]{fifelse()}} for details.
#'
#' @name fifelse
#' @keywords internal
#' @export
#' @importFrom data.table fifelse
NULL

# Helpers -----------------

conditions <- function(list){
  unlist(lapply(list, function(x) x[[2]]))
}
assigned_label <- function(list){
  unlist(lapply(list, function(x) x[[3]]))
}
is_formula <- function(x){
  class(x) == "formula"
}

# Check functions -------------------

.check_dots <- function(dots){
  forms <- all(unlist(lapply(dots, is_formula)))
  if (!forms)
    stop("Not all arguments are formulas", call. = FALSE)
}
