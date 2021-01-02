library(dtplyr)

test_that("dt_pivot_longer.dtplyr_step", {

  tmp <- data.frame(x = 1:2, 
                    y = 3:4,
                    z = 5:6)
  tmp <- dtplyr::lazy_dt(tmp)

  a <- dt_pivot_longer(tmp, cols=c(y, z))
  b <- dt_pivot_longer(tmp, cols=-x)
  expect_equal(dim(a), c(4, 3))
  expect_equal(dim(b), c(4, 3))
  expect_is(a, "dtplyr_step")
  expect_is(b, "dtplyr_step")

})

test_that("dt_pivot_wider.dtplyr_step", {

  dat <- data.table(z = rep(c("a", "b", "c"), 2),
                    stuff = c(rep("x", 3), rep("y", 3)),
                    things = 1:6)
  dat <- dtplyr::lazy_dt(dat)

  res <- dt_pivot_wider(dat, names_from=stuff, values_from=things)
  expect_equal(dim(res), c(3, 3))
  expect_is(res, "dtplyr_step")

})

test_that("dt_nest.dtplyr_step", {

  dat <- dplyr::starwars
  dat <- dtplyr::lazy_dt(dat)
  res <- dt_nest(dat, species, homeworld)
  expect_is(res, "dtplyr_step")
  expect_equal(dim(res), c(58, 3))
  expect_equal(dim(data.frame(res)$data[[1]]), c(1, 12))

})

test_that("dt_unnest.dtplyr_step", {

  dat <- data.table::data.table(
    id = 1:2,
    data = list(
      data.table(x = 1:5),
      data.table(x = 6:10)
  ))

  dat <- dtplyr::lazy_dt(dat)
  res <- dt_unnest(dat, col = data)
  expect_is(res, "dtplyr_step")
  expect_equal(dim(res), c(10, 3))
  expect_equal(data.frame(res)$x, 1:10)

})

test_that("fill.dtplyr_step", {

  # filled down from last non-missing
  dat <- data.table::data.table(x = c(NA, 1, NA, 2, NA, NA))
  dat <- dtplyr::lazy_dt(dat)
  res <- dt_fill(dat, x)
  expect_is(res, "dtplyr_step")
  expect_equal(data.frame(res)$x, c(NA, 1, 1, 2, 2, 2))

})

test_that("separate.dtplyr_step", {

  dat <- data.table(x = c("A.B", "A", "B", "B.A"),
                    y = 1:4)
  dat <- dtplyr::lazy_dt(dat)
  res <- dt_separate(dat, x, c("c1", "c2"))
  expect_is(res, "dtplyr_step")
  expect_equal(data.frame(res)$c1, c("A", "A", "B", "B")) 
  expect_equal(data.frame(res)$c2, c("B", NA, NA, "A")) 

})
