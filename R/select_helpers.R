#' Select helpers
#'
#' @description
#' These functions allow you to select variables based on their names.
#'
#' * `dt_starts_with()`: Starts with a prefix
#' * `dt_starts_with()`: Ends with a suffix
#' * `dt_contains()`: Contains a literal string
#' * `dt_everything()`: Matches all variables
#'
#' @param match
#'
#' @md
#' @return
#' @export
#'
#' @examples
#' library(data.table)
#' library(tidyfast)
#'
#' example_dt <- data.table(x = c(1,2,3), y = c(4,5,6), z = c("a", "b", "c"))
#'
#' example_dt %>%
#'   dt_select(dt_ends_with("z"), dt_everything())
dt_starts_with <- function(match) {
  .names <- names(parent.frame())

  seq_along(.names)[startsWith(.names, match)]
}

#' @export
#' @inherit dt_starts_with
dt_contains <- function(match) {
  .names <- names(parent.frame())

  seq_along(.names)[grepl(match, .names)]
}

#' @export
#' @inherit dt_starts_with
dt_ends_with <- function(match) {
  .names <- names(parent.frame())

  seq_along(.names)[endsWith(.names, match)]
}

#' @export
#' @inherit dt_starts_with
dt_everything <- function() {
  .names <- names(parent.frame())

  seq_along(.names)
}
