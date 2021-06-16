test_that("dt_case_when works", {
  set.seed(843)
  x <- rnorm(1e5)

  cased <-
    dt_case_when(
      x < median(x) ~ "low",
      x >= median(x) ~ "high",
      is.na(x) ~ "other"
    )

  cased2 <-
    dt_case_when(
      x > median(x) ~ 1,
      TRUE ~ x
    )

  expect_named(table(cased), c("high", "low"))
  expect_error(dt_case_when(x < median(x), 1))
  expect_error(dt_case_when(x < median(x), 1,
                            x >= median(x), 2))
  expect_error(dt_case_when(x < median(x) ~ "three",
                            TRUE ~ x))
  expect_equal(head(cased),
               c("low","low","low","low","low","high"))

  # Another
  x <- c(1,2,3,4,5,NA)
  cased3 =
    dt_case_when(x == 1 ~ "a",
                 x < 4 ~ "b",
                 TRUE ~ "c")
  expect_equal(tail(cased3, 1), "c")

  cased4 =
    dt_case_when(x == 1 ~ 1,
                 x < 2 ~ 1,
                 TRUE ~ x)
  expect_equal(tail(cased4, 2), c(5, NA))

  cased5 = dt_case_when(NA ~ 1, TRUE ~ 2)
  expect_equal(cased5, 2)
})


test_that("dt_nest works", {
  dt <- data.table(
    x = rnorm(1e5),
    y = runif(1e5),
    grp = sample(1L:3L, 1e5, replace = TRUE)
  )
  d <- as.data.frame(dt)

  dim(dt_nest(dt, grp))

  expect_equal(dim(dt_nest(dt, grp)), c(3, 2))
  expect_equal(dim(dt_nest(dt)), c(1, 1))
  expect_equal(dim(dt_nest(d, grp)), c(3, 2))
  expect_equal(dim(dt_nest(d)), c(1, 1))
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
  unnest_dt <- dt_unnest(nest_dt, col = data)
  unnest_vec <- dt_hoist(dt, nested1, nested2)

  expect_equal(dim(dt_unnest(nest_dt, col = data)), c(100000, 7))
  expect_equal(
    nrow(dt_hoist(
      dt,
      nested1, nested2
    )),
    1000000
  )

  d <- as.data.frame(dt)
  nest_d <- as.data.frame(nest_dt)
  unnest_dt <- dt_unnest(nest_d, col = data)
  unnest_vec <- dt_hoist(
    d,
    nested1, nested2
  )

  expect_equal(dim(dt_unnest(nest_d, col = data)), c(100000, 7))
  expect_equal(
    nrow(dt_hoist(
      dt,
      nested1, nested2
    )),
    1000000
  )
})


test_that("dt_count works", {
  dt <- data.table(
    x = rnorm(99),
    y = runif(99),
    grp = rep(c(1, 2, NA), times = 33),
    grp2 = rep(1:9, times = 11)
  )

  expect_named(dt_count(dt, grp), c("grp", "N"))
  expect_named(dt_count(dt, grp, grp2), c("grp", "grp2", "N"))
  expect_equal(nrow(dt_count(dt, grp, grp2, na.rm = TRUE)), 6)
  expect_named(dt_count(dt, grp, grp2, wt = x), c("grp", "grp2", "N"))
})

test_that("dt_uncount works", {
  dt <- data.table(
    grp = rep(1:3, times = 33),
    grp2 = rep(1:9, times = 11),
    id = 1:99
  )

  counted <- dt_count(dt, grp)
  counted2 <- dt_count(dt, grp, grp2)

  expect_named(dt_uncount(counted, N)[], c("grp"))
  expect_equal(
    as.data.frame(dt_uncount(counted2, N)[order(grp, grp2)]),
    as.data.frame(dt[order(grp, grp2), .(grp, grp2)])
  )

  expect_named(dt_uncount(counted, N, .remove = FALSE)[], c("grp", "N"))
  expect_named(dt_uncount(counted, N, .id = "id")[], c("grp", ".id"))
})

test_that("dt_separate works", {
  dt <- data.table(
    x = c("A.B", "A", "B", "B.A"),
    y = 1:4
  )

  expect_equal(
    capture.output(dt_separate(dt, x, c("c1", "c2"))[]),
    c(
      "   y c1   c2",
      "1: 1  A    B",
      "2: 2  A <NA>",
      "3: 3  B <NA>",
      "4: 4  B    A"
    )
  )

  # can keep the original column with `remove = FALSE`
  expect_equal(
    capture.output(dt_separate(dt, x, c("c1", "c2"), remove = FALSE)[]),
    c(
      "     x y c1   c2",
      "1: A.B 1  A    B",
      "2:   A 2  A <NA>",
      "3:   B 3  B <NA>",
      "4: B.A 4  B    A"
    )
  )

  # need to assign when `immutable = TRUE`
  expect_equal(
    capture.output(dt_separate(dt, x, c("c1", "c2"), immutable = TRUE)),
    c(
      "   y c1   c2",
      "1: 1  A    B",
      "2: 2  A <NA>",
      "3: 3  B <NA>",
      "4: 4  B    A"
    )
  )
})



test_that("dt_print_options works", {
  dt <- data.table(x = 1)
  dt_print_options()

  expect_equal(
    capture.output(dt),
    c(
      "       x",
      "   <num>",
      "1:     1"
    )
  )
})

test_that("dt_fill works", {

  dt <- data.table(
    x = c(1,2,3,4,NA),
    y = c(NA, 1,2,3,4),
    grp = c(1,2,1,2,1)
  )

  filled1 = dt_fill(dt, x)
  filled2 = dt_fill(dt, y, .direction = "up")
  filled3 = dt_fill(dt, x, y, .direction = "updown")

  expect_equal(sum(is.na(filled1)), 1)
  expect_equal(sum(is.na(filled2)), 1)
  expect_equal(sum(is.na(filled3)), 0)
  expect_equal(dim(filled3), c(5,3))
})

