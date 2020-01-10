# Equivalent to rlang::enexprs()
enlist_dots <- function(...) substitute(...())

# "Tidy" column selector
# Works with both list() and c() selections
column_selector <- function(.data, select_vars) {

  data_names <- colnames(.data)
  data_vars <- setNames(as.list(seq_along(.data)), data_names)

  select_index <- unlist(eval(select_vars, data_vars))

  keep_index <- unique(select_index[select_index > 0])
  if (length(keep_index) == 0) keep_index <- seq_along(.data)
  drop_index <- unique(abs(select_index[select_index < 0]))

  select_index <- setdiff(keep_index, drop_index)

  select_vars <- data_names[select_index]

  select_vars
}
