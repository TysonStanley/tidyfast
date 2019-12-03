# tests from tidyr regarding pivot_longer

test_that("can pivot all cols to long", {
  df <- data.table(x = 1:2, y = 3:4)
  pivot_df <- dt_pivot_longer(df, cols = c(x,y))[order(name, value)]
  tidyr_df <- dplyr::arrange(tidyr::pivot_longer(df, cols = c(x, y)), name, value)

  expect_named(pivot_df, c("name", "value"))
  expect_equal(pivot_df$name, tidyr_df$name)
  expect_equal(pivot_df$value, tidyr_df$value)
})

test_that("preserves original keys", {
  df <- data.table(x = 1:2, y = 2, z = 1:2)
  pivot_df <- dt_pivot_longer(df, cols = c(y, z))[order(name, value)]
  tidyr_df <- dplyr::arrange(tidyr::pivot_longer(df, c(y, z)), name, value)

  expect_named(pivot_df, c("x", "name", "value"))
  expect_equal(pivot_df$x, tidyr_df$x)
})

test_that("can drop missing values", {
  df <- data.table(x = c(1, NA), y = c(NA, 2))
  pivot_df <- dt_pivot_longer(df, c(x,y), values_drop_na = TRUE)[order(name, value)]
  tidyr_df <- dplyr::arrange(tidyr::pivot_longer(df, c(x,y), values_drop_na = TRUE), name, value)

  expect_equal(pivot_df$name, c("x", "y"))
  expect_equal(pivot_df$value, tidyr_df$value)
})
