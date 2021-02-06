# tests from dplyr regarding group_nest() and tidyr regarding unnest_legacy()
# Have kept all relevant tests (some do not apply to dt_nest() or dt_unnest())

starwars <- dplyr::starwars

test_that("dt_nest() works", {
  res <- dt_nest(starwars, species, homeworld)
  expect_is(dplyr::pull(res), "list")

  dplyr_res <- dplyr::group_nest(starwars, species, homeworld)

  expect_equal(nrow(res), nrow(dplyr_res))
  expect_equal(ncol(res), ncol(dplyr_res))
})

# not currently implemented
# test_that("group_nest() can keep the grouping variables", {
#   grouped <- group_by(starwars, species, homeworld)
#   gdata <- group_data(grouped)
#
#   res <- dplyr::group_nest(starwars, species, homeworld, keep = TRUE)
#   nested <- bind_rows(!!!res$data)
#   expect_equal(names(nested), names(starwars))
# })

# test_that("group_nest() works on grouped data frames", {
#   grouped <- dplyr::group_by(starwars, species, homeworld)
#
#   res <- dt_nest(grouped)
#   dplyr_res <- dplyr::group_nest(grouped)
#
#   expect_is(dplyr::pull(res), "list")
#
#   expect_equal(nrow(res), nrow(dplyr_res))
#   expect_equal(ncol(res), ncol(dplyr_res))
#   expect_equal(names(data.table::rbindlist(res$data)),
#                setdiff(names(starwars), c("species", "homeworld")))
#
# })

# test_that("group_nest.grouped_df() warns about ...", {
#   expect_warning(dt_nest(dplyr::group_by(mtcars, cyl), cyl))
#   expect_silent(dt_nest(dplyr::group_by(mtcars, cyl)))
# })

test_that("group_nest() works if no grouping column", {
  res <- dt_nest(iris)
  dplyr_res <- dplyr::group_nest(iris)
  expect_equal(res$data, list(data.table::as.data.table(iris)))
  expect_equal(names(res), "data")
  expect_equal(nrow(res), nrow(dplyr_res))
  expect_equal(ncol(res), ncol(dplyr_res))
})

test_that("dt_nest() only uses observed factor levels", {
  data <- data.table::data.table(f = factor("b", levels = c("a", "b", "c")), x = 1, y = 2)
  expect_equal(nrow(dt_nest(data, f)), 1L)
})



# unnest and hoist ----------------------------------------------------

test_that("hoist combines atomic vectors", {
  dt <- data.table::data.table(
    x = list(1L, 2:3, 4:10),
    id = 1:3
  )
  expect_equal(dt_hoist(dt, x)$x, 1:10)
})

test_that("dt_hoist combines augmented vectors", {
  df <- data.table::data.table(
    x = as.list(as.factor(letters[1:3])),
    id = 1:3
  )
  expect_equal(dt_hoist(df, x)$x, factor(letters[1:3]))
})

test_that("hoist preserves names", {
  df <- data.table::data.table(x = list(1L, 2:3), y = list("a", c("b", "c")), group = 1:2)
  out <- dt_hoist(df, x, y)
  expect_named(out, c("group", "x", "y"))
})

test_that("unnest row binds data frames", {
  df <- data.table::data.table(
    id = 1:2,
    data = list(
      data.table(x = 1:5),
      data.table(x = 6:10)
    )
  )
  expect_equal(dt_unnest(df, data)$x, 1:10)
})

test_that("can unnest mixture of name and unnamed lists of same length", {
  df <- data.table::data.table(
    x = c("a"),
    y = list(y = 1:2),
    z = list(1:2),
    id = 1
  )
  expect_identical(
    dt_hoist(df, x, y, z),
    data.table::data.table(id = c(1, 1), x = c("a", "a"), y = c(1:2), z = c(1:2))
  )
})

# needs to be implemented in dt_hoist()
# test_that("hoist: elements must all be of same type", {
#   df <- data.table::data.table(x = list(1, "a"),
#                                y = list(2, "b"),
#                                id = 1)
#   expect_error(
#     dt_hoist(df, x, y),
#     "(incompatible type)|(numeric to character)|(character to numeric)"
#   )
# })
# test_that("hoist: can't combine vectors and data frames", {
#   df <- data.table::data.table(x = list(1, data.table::data.table(1)))
#   expect_error(dt_hoist(df, x), "a list of vectors or a list of data frames")
# })
#
# test_that("multiple columns must be same length", {
#   df <- data.table::data.table(x = list(1), y = list(1:2))
#   expect_error(dt_hoist(df, x, y), "same number of elements")
#
#   df <- data.table::data.table(x = list(1), y = list(tibble(x = 1:2)))
#   expect_error(unnest_legacy(df), "same number of elements")
# })
#
# test_that("nested is split as a list (#84)", {
#   df <- tibble(x = 1:3, y = list(1, 2:3, 4), z = list(5, 6:7, 8))
#   expect_warning(out <- unnest_legacy(df, y, z), NA)
#   expect_equal(out$x, c(1, 2, 2, 3))
#   expect_equal(out$y, unlist(df$y))
#   expect_equal(out$z, unlist(df$z))
# })
#
# test_that("unnest has mutate semantics", {
#   df <- tibble(x = 1:3, y = list(1, 2:3, 4))
#   out <- df %>% unnest_legacy(z = map(y, `+`, 1))
#
#   expect_equal(out$z, 2:5)
# })
#
# test_that(".id creates vector of names for vector unnest", {
#   df <- tibble(x = 1:2, y = list(a = 1, b = 1:2))
#   out <- unnest_legacy(df, .id = "name")
#
#   expect_equal(out$name, c("a", "b", "b"))
# })
#
# test_that(".id creates vector of names for grouped vector unnest", {
#   df <- tibble(x = 1:2, y = list(a = 1, b = 1:2)) %>%
#     dplyr::group_by(x)
#   out <- unnest_legacy(df, .id = "name")
#
#   expect_equal(out$name, c("a", "b", "b"))
# })
#
# test_that(".id creates vector of names for data frame unnest", {
#   df <- tibble(x = 1:2, y = list(
#     a = tibble(y = 1),
#     b = tibble(y = 1:2)
#   ))
#   out <- unnest_legacy(df, .id = "name")
#
#   expect_equal(out$name, c("a", "b", "b"))
# })
#
# test_that(".id creates vector of names for grouped data frame unnest", {
#   df <- tibble(x = 1:2, y = list(
#     a = tibble(y = 1),
#     b = tibble(y = 1:2)
#   )) %>%
#     dplyr::group_by(x)
#   out <- unnest_legacy(df, .id = "name")
#
#   expect_equal(out$name, c("a", "b", "b"))
# })
#
# test_that("can use non-syntactic names", {
#   out <- tibble("foo bar" = list(1:2, 3)) %>% unnest_legacy()
#
#   expect_named(out, "foo bar")
# })
#
# test_that("sep combines column names", {
#   ldf <- list(tibble(x = 1))
#   tibble(x = ldf, y = ldf) %>%
#     unnest_legacy(.sep = "_") %>%
#     expect_named(c("x_x", "y_x"))
# })
#
# test_that("can unnest empty data frame", {
#   df <- tibble(x = integer(), y = list())
#   out <- unnest_legacy(df, y)
#   expect_equal(out, tibble(x = integer()))
# })
#
# test_that("empty ... returns df if no list-cols", {
#   df <- tibble(x = integer(), y = integer())
#   expect_equal(unnest_legacy(df), df)
# })
#
# test_that("can optional preserve list cols", {
#   df <- tibble(x = list(3, 4), y = list("a", "b"))
#   rs <- df %>% unnest_legacy(x, .preserve = y)
#   expect_identical(rs, tibble(y = df$y, x = c(3, 4)))
#
#   df <- tibble(x = list(c("d", "e")), y = list(1:2))
#   rs <- df %>% unnest_legacy(.preserve = y)
#   expect_identical(rs, tibble(y = rep(list(1:2), 2), x = c("d", "e")))
# })
#
# test_that("unnest drops list cols if expanding", {
#   df <- tibble(x = 1:2, y = list(3, 4), z = list(5, 6:7))
#   out <- df %>% unnest_legacy(z)
#
#   expect_equal(names(out), c("x", "z"))
# })
#
# test_that("unnest keeps list cols if not expanding", {
#   df <- tibble(x = 1:2, y = list(3, 4), z = list(5, 6:7))
#   out <- df %>% unnest_legacy(y)
#
#   expect_equal(names(out), c("x", "z", "y"))
# })
#
# test_that("unnest respects .drop_lists", {
#   df <- tibble(x = 1:2, y = list(3, 4), z = list(5, 6:7))
#
#   expect_equal(df %>% unnest_legacy(y, .drop = TRUE) %>% names(), c("x", "y"))
#   expect_equal(df %>% unnest_legacy(z, .drop = FALSE) %>% names(), c("x", "y", "z"))
# })
#
# test_that("grouping is preserved", {
#   df <- tibble(g = 1, x = list(1:3)) %>% dplyr::group_by(g)
#   rs <- df %>% unnest_legacy(x)
#
#   expect_equal(rs$x, 1:3)
#   expect_equal(class(df), class(rs))
#   expect_equal(dplyr::groups(df), dplyr::groups(rs))
# })
#
# test_that("unnesting zero row column preserves names", {
#   df <- tibble(a = character(), b = character())
#   expect_equal(df %>% unnest_legacy(b), tibble(b = character(), a = character()))
# })
#
# test_that("unnest_legacy() recognize ptype", {
#   tbl <- tibble(x = integer(), y = structure(list(), ptype = double()))
#   res <- unnest_legacy(tbl)
#   expect_equal(res, tibble(x = integer(), y = double()))
# })
