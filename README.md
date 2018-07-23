
<!-- README.md is generated from README.Rmd. Please edit that file -->

# polite

The goal of `polite` is to promote responsible web etiquette. It’s a
two-function package (`bow` and `scrape`) for defining a web session
(introducing yourself, asking for permission) and performing data
acquisition in corteous and responsible manner (taking slowly and never
asking twice).

The package builds on awesome toolkit for defining and managing http
session (`httr` and `rvest`), declaring useragent string and
investigating site policies (`robotstxt`), rate-limiting and caching
(`ratelimitr` amd `memoise`).

## Installation

You can install the development version of `polite` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dmi3kno/polite")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(polite)
bow()
scrape()
```
