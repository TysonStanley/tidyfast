#' Rename variables by name
#'
#' @description
#' Rename variables from a data.table.
#'
#' @param dt_ A data.frame or data.table
#' @param ... Rename expression like dplyr::rename()
#'
#' @return A data.table
#' @export
#'
#' @examples
#' dt <- data.table(x = c(1,2,3), y = c(4,5,6))
#' dt %>%
#'   dt_rename(new_x = x,
#'             new_y = y)
#'
dt_rename <- function(dt_, ...) {

  if (!is.data.frame(dt_)) stop(".data must be a data.frame or data.table")
  if (!is.data.table(dt_)) dt_ <- as.data.table(dt_)

  .dots <- enlist_dots(...)

  for (i in seq_along(.dots)) {
    new_name <- names(.dots)[[i]]
    old_name <- as.character(.dots[[i]])

    setnames(dt_, old_name, new_name)
  }
  dt_
}
