
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `tidyfast v0.1.2` <img src=".graphics/tidyfast_hex.png" align="right" width="30%" height="30%" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of `tidyfast` is to provide fast and efficient alternatives to
some `tidyr` and `dplyr` functions using `data.table` under the hood.
Each have the prefix of `dt_` to allow for autocomplete in IDEs such as
RStudio. These should compliment some of the current functionality in
`dtplyr` (but notably does not use the `lazy_dt()` framework of
`dtplyr`).

The current functions include:

**Nesting and unnesting** (similar to `tidyr::nest()` or
`dplyr::group_nest()` and `tidyr::unnest()`):

  - `dt_nest()` for nesting data tables
  - `dt_unnest()` for unnesting data tables
  - `dt_unnest_vec()` for unnesting vectors in a list-column in a data
    table

**If Else** (similar to `dplyr::case_when()`):

  - `dt_case_when()` for `dplyr::case_when()` syntax with the speed of
    `data.table::fifelse()`

**Fill** (similar to `tidyr::fill()`)

  - `dt_fill()` for filling `NA` values with values before it, after it,
    or both. This can be done by a grouping variable (e.g. fill in `NA`
    values with values within an individual).

**Separate** (similar to `tidyr::separate()`)

  - `dt_separate()` for splitting a single column into multiple based on
    a match within the column (e.g., column with “A.B” could be split
    into two columns by using the period as the separator). It is built
    on `data.table::tstrsplit()`. This is not well tested yet and lacks
    some functionality of `tidyr::separate()`.

Package is still in active development.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("TysonStanley/tidyfast")
```

## Examples

### Nesting and Unnesting

The nesting and unnesting functions were shown in a [previous
preprint](https://psyarxiv.com/u8ekc/) while `dt_case_when()` is really
new. Herein, I show more simple applications.

The following data table will be used for the nesting/unnesting
examples.

``` r
library(tidyfast)
library(data.table)
library(dplyr)       # to compare with case_when()

dt <- data.table(
   x = rnorm(1e5),
   y = runif(1e5),
   grp = sample(1L:3L, 1e5, replace = TRUE),
   nested1 = lapply(1:10, sample, 10, replace = TRUE),
   nested2 = lapply(c("thing1", "thing2"), sample, 10, replace = TRUE),
   id = 1:1e5)
```

We can nest this data using `dt_nest()`:

``` r
nested <- dt_nest(dt, grp)
nested
#>    grp         data
#> 1:   2 <data.table>
#> 2:   3 <data.table>
#> 3:   1 <data.table>
```

We can also unnest this with `dt_unnest()`:

``` r
dt_unnest(nested, col = data, id = grp)
#>         grp           x         y         nested1
#>      1:   2 -1.71490559 0.1391240 1,1,1,1,1,1,...
#>      2:   2 -1.63648042 0.5707004 2,2,1,1,1,1,...
#>      3:   2 -0.35679806 0.7870723 2,4,2,2,3,4,...
#>      4:   2 -2.28244999 0.9440325 6,2,4,8,7,6,...
#>      5:   2  0.43548629 0.8904694 1,1,1,1,1,1,...
#>     ---                                          
#>  99996:   1 -0.62731313 0.7978934 6,2,4,8,7,6,...
#>  99997:   1  0.05632578 0.6222600 2,8,2,4,6,6,...
#>  99998:   1  0.69281606 0.4868225 2,2,1,1,1,1,...
#>  99999:   1 -1.14218533 0.1367110 6,1,3,5,3,1,...
#> 100000:   1  0.57943399 0.1675201 2,3,5,9,1,3,...
#>                                               nested2     id
#>      1: thing1,thing1,thing1,thing1,thing1,thing1,...      1
#>      2: thing2,thing2,thing2,thing2,thing2,thing2,...      2
#>      3: thing2,thing2,thing2,thing2,thing2,thing2,...      4
#>      4: thing2,thing2,thing2,thing2,thing2,thing2,...      8
#>      5: thing1,thing1,thing1,thing1,thing1,thing1,...     11
#>     ---                                                     
#>  99996: thing2,thing2,thing2,thing2,thing2,thing2,...  99988
#>  99997: thing1,thing1,thing1,thing1,thing1,thing1,...  99989
#>  99998: thing2,thing2,thing2,thing2,thing2,thing2,...  99992
#>  99999: thing2,thing2,thing2,thing2,thing2,thing2,...  99996
#> 100000: thing2,thing2,thing2,thing2,thing2,thing2,... 100000
```

When our list columns don’t have data tables (as output from
`dt_nest()`) we can use the `dt_unnest_vec()` function, that will unnest
vectors.

``` r
dt_unnest_vec(dt, 
              cols = list(nested1, nested2), 
              id = id, 
              name = c("nested1", "nested2"))
#>              id nested1 nested2
#>       1:      1       1  thing1
#>       2:      1       1  thing1
#>       3:      1       1  thing1
#>       4:      1       1  thing1
#>       5:      1       1  thing1
#>      ---                       
#>  999996: 100000       3  thing2
#>  999997: 100000       5  thing2
#>  999998: 100000       8  thing2
#>  999999: 100000       7  thing2
#> 1000000: 100000       6  thing2
```

### If Else

Also, the new `dt_case_when()` function is built on the very fast
`data.table::fiflese()` but has syntax like unto `dplyr::case_when()`.
That is, it looks like:

``` r
dt_case_when(condition1 ~ label1,
             condition2 ~ label2,
             ...)
```

To show that each method, `dt_case_when()`, `dplyr::case_when()`, and
`data.table::fifelse()` produce the same result, consider the following
example.

``` r
x <- rnorm(1e6)

medianx <- median(x)
x_cat <-
  dt_case_when(x < medianx ~ "low",
               x >= medianx ~ "high",
               is.na(x) ~ "unknown")
x_cat_dplyr <-
  case_when(x < medianx ~ "low",
            x >= medianx ~ "high",
            is.na(x) ~ "unknown")
x_cat_fif <-
  fifelse(x < medianx, "low",
  fifelse(x >= medianx, "high",
  fifelse(is.na(x), "unknown", NA_character_)))

identical(x_cat, x_cat_dplyr)
#> [1] TRUE
identical(x_cat, x_cat_fif)
#> [1] TRUE
```

Notably, `dt_case_when()` is very fast and memory efficient, given it is
built on `data.table::fifelse()`.

<img src="man/figures/README-unnamed-chunk-8-1.png" width="70%" />

    #> # A tibble: 3 x 3
    #>   expression     median mem_alloc
    #>   <chr>        <bch:tm> <bch:byt>
    #> 1 case_when     125.4ms   148.8MB
    #> 2 dt_case_when   34.8ms    34.3MB
    #> 3 fifelse        32.8ms    34.3MB

## Fill

A new function is `dt_fill()`, which fulfills the role of
`tidyr::fill()` to fill in `NA` values with values around it (either the
value above, below, or trying both). This currently relies on the
efficient `C++` code from `tidyr` (`fillUp()` and `fillDown()`).

``` r
x = 1:10
dt_with_nas <- data.table(
  x = x,
  y = shift(x),
  z = shift(x, -1L),
  a = sample(c(rep(NA, 10), x), 10),
  grp = sample(1:3, 10, replace = TRUE))

# All defaults
dt_fill(dt_with_nas)
#>      x  y  z  a grp
#>  1:  1 NA  2 NA   2
#>  2:  2  1  3  2   1
#>  3:  3  2  4  7   3
#>  4:  4  3  5  4   3
#>  5:  5  4  6  3   3
#>  6:  6  5  7  5   2
#>  7:  7  6  8  9   1
#>  8:  8  7  9  9   1
#>  9:  9  8 10  9   2
#> 10: 10  9 10  9   3

# by id variable called `grp`
dt_fill(dt_with_nas, id = grp)
#>     grp  x  y  z  a
#>  1:   1  2  1  3  2
#>  2:   1  7  6  8  9
#>  3:   1  8  7  9  9
#>  4:   2  1 NA  2 NA
#>  5:   2  6  5  7  5
#>  6:   2  9  8 10  5
#>  7:   3  3  2  4  7
#>  8:   3  4  3  5  4
#>  9:   3  5  4  6  3
#> 10:   3 10  9  6  3

# both down and then up filling by group
dt_fill(dt_with_nas, id = grp, .direction = "downup")
#>     grp  x y  z a
#>  1:   1  2 1  3 2
#>  2:   1  7 6  8 9
#>  3:   1  8 7  9 9
#>  4:   2  1 5  2 5
#>  5:   2  6 5  7 5
#>  6:   2  9 8 10 5
#>  7:   3  3 2  4 7
#>  8:   3  4 3  5 4
#>  9:   3  5 4  6 3
#> 10:   3 10 9  6 3
```

## Note

Please note that the `tidyfast` project is released with a [Contributor
Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this
project, you agree to abide by its terms.

Also, `ggplot2`, `ggbeeswarm`, and `tidyr` were used herein for creating
the plot.
