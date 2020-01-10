#' Rename a selection of variables
#'
#' @description
#' These scoped variants of `rename()`` operate on a selection of variables
#'
#' @usage
#' dt_rename_all(dt_, .fun, ...)
#' dt_rename_at(dt_, .vars, .fun, ...)
#' dt_rename_if(dt_, .predicate, .fun, ...)
#'
#'
#' @param dt_ A data.frame or data.table
#' @param .predicate Predicate to specify columns for `dt_rename_if()`
#' @param .vars `list()` of variables for `dt_rename_at()` to use
#' @param .fun Function to pass
#' @param ... Other arguments for the passed function
#'
#' @md
#' @return
#' @export
#'
#' @examples
#' example_dt <- data.table(x = 1, y = 2, double_x = 2, double_y = 4)
#'
#' example_dt %>% dt_rename_all(str_replace, "x", "stuff)
#'
#' example_dt %>% dt_rename_at(list(x, double_x), str_replace, "x", "stuff")
#'
#' example_dt %>% dt_rename_if(is.double, function(x) str_replace(x, "x", "stuff"))
dt_rename_all <- function(dt_, .fun, ...) {

  if (!is.data.frame(dt_)) stop(".data must be a data.frame or data.table")
  if (!is.data.table(dt_)) dt_ <- as.data.table(dt_)

  .cols <- colnames(dt_)

  for (old_name in .cols) {
    new_name <- .fun(old_name, ...)
    setnames(dt_, old_name, new_name)
  }
  dt_
}

#' @export
#' @rdname dt_rename_all
dt_rename_at <- function(dt_, .vars, .fun, ...) {

  if (!is.data.frame(dt_)) stop(".data must be a data.frame or data.table")
  if (!is.data.table(dt_)) dt_ <- as.data.table(dt_)

  .cols <- column_selector(dt_, substitute(c(.vars)))

  if (length(.cols) > 0) {
    for (old_name in .cols) {
      new_name <- .fun(old_name, ...)
      setnames(dt_, old_name, new_name)
    }
    dt_
  } else {
    dt_
  }
}

#' @export
#' @rdname dt_rename_all
dt_rename_if <- function(dt_, .predicate, .fun, ...) {

  if (!is.data.frame(dt_)) stop(".data must be a data.frame or data.table")
  if (!is.data.table(dt_)) dt_ <- as.data.table(dt_)

  .cols <- colnames(dt_)[dt_map_lgl(dt_, .predicate)]

  if (length(.cols) > 0) {
    for (old_name in .cols) {
      new_name <- .fun(old_name, ...)
      setnames(dt_, old_name, new_name)
    }
    dt_
  } else {
    dt_
  }
}
