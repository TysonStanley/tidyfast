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
#' @param match a character string to match to variable names
#'
#' @md
#' @examples
#' library(data.table)
#'
#' # example of using it with `dt_pivot_longer()`
#' df <- data.table(row = 1, var = c("x", "y"), a = 1:2, b = 3:4)
#' pv <- dt_pivot_wider(df,
#'                      names_from = var,
#'                      values_from = c(dt_starts_with("a"), dt_ends_with("b")))
#'
#' @export
dt_starts_with <- function(match) {
  .names <- names(parent.frame())

  seq_along(.names)[startsWith(.names, match)]
}

#' @export
#' @rdname dt_starts_with
dt_contains <- function(match) {
  .names <- names(parent.frame())

  seq_along(.names)[grepl(match, .names)]
}

#' @export
#' @rdname dt_starts_with
dt_ends_with <- function(match) {
  .names <- names(parent.frame())

  seq_along(.names)[endsWith(.names, match)]
}

#' @export
#' @rdname dt_starts_with
dt_everything <- function() {
  .names <- names(parent.frame())

  seq_along(.names)
}
