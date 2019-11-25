#' Pivot data from wide to long
#'
#' `pivot_longer()` "lengthens" data, increasing the number of rows and
#' decreasing the number of columns. The inverse transformation is
#' `pivot_wider()`
#'
#' @param data The data.table
#' @param cols Column selection. If empty uses all columns. Can use -colname to unselect column(s)
#' @param names_to Name of the new "names" column. Must be a string.
#' @param values_to Name of the new "values" column. Must be a string.
#'
#' @export
#'
#' @examples
#' example_df <- data.table(x = c(1,2,3), y = c(4,5,6), z = c("a", "b", "c"))
#'
#' example_df %>%
#'   dt_pivot_longer(cols = c(x, y), names_to = "stuff", values_to = "things")
dt_pivot_longer <- function(data,
                            cols = NULL,
                            names_to = "name",
                            values_to = "value") {

  if (missing(cols)) {
    # All columns if cols = NULL
    cols <- colnames(data)
  } else {
    cols <- characterize(substitute(cols))
  }

  if (cols[1] == "-") {
    # If cols is a single "unselected" column
    drop_cols <- cols[2]
    cols <- colnames(data)[!colnames(data) %in% drop_cols]

  } else if (any(grepl(cols, "-"))) {
    # If cols is a vector of bare column names
    drop_cols <- gsub(cols[grepl(cols, "-")], "-", "")

    cols <- unique(c(cols[!grepl(cols, "-")],
                     colnames(data)[!colnames(data) %in% drop_cols]))
  }

  id_vars <- colnames(data)[!colnames(data) %in% cols]

  data.table::melt(data = data,
                   id.vars = id_vars,
                   measure.vars = cols,
                   variable.name = names_to,
                   value.name = values_to,
                   # ...,
                   na.rm = FALSE,
                   variable.factor = FALSE,
                   value.factor = FALSE)
}

characterize <- function(vec_list_expr) {
  vle_length <- length(vec_list_expr)
  if (vle_length == 1) {
    as.character(vec_list_expr)
  } else if (as.character(vec_list_expr)[1] == "-"){
    as.character(vec_list_expr)
  } else {
    as.character(vec_list_expr)[-1]
  }
}
