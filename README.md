
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

This will be added soon.

## Note

Please note that the ‘tidyfast’ project is released with a [Contributor
Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this
project, you agree to abide by its terms.
