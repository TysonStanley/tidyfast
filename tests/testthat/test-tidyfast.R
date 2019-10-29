test_that("dt_case_when works", {

  x <- rnorm(1e5)

  cased <-
    dt_case_when(
      x < median(x) ~ "low",
      x >= median(x) ~ "high",
      is.na(x) ~ "other"
    )

  expect_equal(names(table(cased)), c("high", "low"))
  expect_error(dt_case_when(x < median(x), 1))

})


test_that("dt_nest works", {

  dt <- data.table(
    x = rnorm(1e5),
    y = runif(1e5),
    grp = sample(1L:3L, 1e5, replace = TRUE)
  )
  d <- as.data.frame(dt)

  dim(dt_nest(dt, grp))

  expect_equal(dim(dt_nest(dt, grp)), c(3,2))
  expect_equal(dim(dt_nest(dt)), c(1,1))
  expect_equal(dim(dt_nest(d, grp)), c(3,2))
  expect_equal(dim(dt_nest(d)), c(1,1))
})

test_that("dt_unnest works", {

  dt <- data.table(
     x = rnorm(1e5),
     y = runif(1e5),
     grp = sample(1L:3L, 1e5, replace = TRUE),
     nested1 = lapply(1:10, sample, 10, replace = TRUE),
     nested2 = lapply(c("thing1", "thing2"), sample, 10, replace = TRUE),
     id = 1:1e5
     )

  nest_dt <- dt_nest(dt, grp)
  unnest_dt <- dt_unnest(nest_dt, col = data, id = grp)
  unnest_vec <-
    dt_unnest_vec(dt,
                  cols = list(nested1, nested2),
                  id = id,
                  name = c("nested1", "nested2"))

  expect_equal(dim(dt_unnest(nest_dt, col = data, id = grp)), c(100000,6))
  expect_equal(dim(dt_unnest_vec(dt,
                                 cols = list(nested1, nested2),
                                 id = id,
                                 name = c("nested1", "nested2"))),
               c(1000000, 3))

  d <- as.data.frame(dt)
  nest_d <- as.data.frame(nest_dt)
  unnest_dt <- dt_unnest(nest_d, col = data, id = grp)
  unnest_vec <-
    dt_unnest_vec(d,
                  cols = list(nested1, nested2),
                  id = id,
                  name = c("nested1", "nested2"))

  expect_equal(dim(dt_unnest(nest_d, col = data, id = grp)), c(100000,6))
  expect_equal(dim(dt_unnest_vec(d,
                                 cols = list(nested1, nested2),
                                 id = id,
                                 name = c("nested1", "nested2"))),
               c(1000000, 3))
})


