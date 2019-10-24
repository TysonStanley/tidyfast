
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `tidyfast v0.1.0` <img src=".graphics/tidyfast_hex.png" align="right" width="30%" height="30%" />

<!-- badges: start -->

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

**If Else** (similar to `dplyr::nest()` or `dplyr::group_nest()` and
`tidyr::unnest()`):

  - `dt_case_when()` for `dplyr::case_when()` syntax with the speed of
    `data.table::fifelse()`

Package is still in active development.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("TysonStanley/tidyfast")
```

## Example

The nesting and unnesting functions were shown in a [previous
preprint](https://psyarxiv.com/u8ekc/). Herein, I show more simple
applications. The following data table will be used for the examples.

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
#>         grp            x         y         nested1
#>      1:   2 -0.466175094 0.3422832 1,1,1,1,1,1,...
#>      2:   2  0.265780291 0.2455631 3,1,3,3,2,1,...
#>      3:   2 -0.093891857 0.4328516 4,6,1,3,4,3,...
#>      4:   2  0.311893935 0.1344532 1,1,1,1,1,1,...
#>      5:   2  1.319435010 0.2268143 3,1,3,3,2,1,...
#>     ---                                           
#>  99996:   1  0.382158499 0.9283831 3,1,3,3,2,1,...
#>  99997:   1 -0.308199299 0.6770861 1,4,1,3,1,1,...
#>  99998:   1  0.755625357 0.1174685 5,1,7,3,2,6,...
#>  99999:   1 -1.776906123 0.6054173 6,8,4,3,5,7,...
#> 100000:   1  0.009290152 0.5044402 4,6,1,3,4,3,...
#>                                               nested2    id
#>      1: thing1,thing1,thing1,thing1,thing1,thing1,...     1
#>      2: thing1,thing1,thing1,thing1,thing1,thing1,...     3
#>      3: thing1,thing1,thing1,thing1,thing1,thing1,...     9
#>      4: thing1,thing1,thing1,thing1,thing1,thing1,...    11
#>      5: thing1,thing1,thing1,thing1,thing1,thing1,...    13
#>     ---                                                    
#>  99996: thing1,thing1,thing1,thing1,thing1,thing1,... 99993
#>  99997: thing1,thing1,thing1,thing1,thing1,thing1,... 99995
#>  99998: thing1,thing1,thing1,thing1,thing1,thing1,... 99997
#>  99999: thing2,thing2,thing2,thing2,thing2,thing2,... 99998
#> 100000: thing1,thing1,thing1,thing1,thing1,thing1,... 99999
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
#>  999996: 100000       8  thing2
#>  999997: 100000      10  thing2
#>  999998: 100000       9  thing2
#>  999999: 100000       2  thing2
#> 1000000: 100000       5  thing2
```

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

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

    #> # A tibble: 3 x 3
    #>   expression     median mem_alloc
    #>   <chr>        <bch:tm> <bch:byt>
    #> 1 case_when       133ms   148.8MB
    #> 2 dt_case_when   34.9ms    34.3MB
    #> 3 fifelse        34.3ms    34.3MB

## Note

Please note that the `tidyfast` project is released with a [Contributor
Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this
project, you agree to abide by its terms.

Also, `ggplot2`, `ggbeeswarm`, and `tidyr` were used herein for creating
the plot.
