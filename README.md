
<!-- README.md is generated from README.Rmd. Please edit that file -->

# polite <img src="man/figures/logo.png" align="right" />

The goal of `polite` is to promote responsible web etiquette.

> **“bow and scrape” (verb):**
> 
> 1)  To make a deep bow with the right leg drawn back (thus scraping
>     the floor), left hand pressed across the abdomen, right arm held
>     aside.
> 
> 2)  *(idiomatic, by extension)* To behave in a servile, obsequious, or
>     excessively polite manner. \[1\]  
>     Source: *Wiktionary, The free dictionary*

The package’s two main functions `bow` and `scrape` define and realize
web harvesting session. `bow` is used to introduce the client to the
host and ask for permission to scrape (by inquiring against host’s
robots.txt file), while `scrape` is the main function for retrieving
data from the remote server. Once the connection is established, there’s
no need to `bow` again. Rather, in order to adjust a scraping url the
user can simply `nod` to the new path, which updates the session’s url,
making sure that the new location can be negotiated against robots.txt

The three pillars of `polite session` are **seeking permission, taking
slowly and never asking twice**.

The package builds on awesome toolkit for defining and managing http
session (`httr` and `rvest`), declaring useragent string and
investigating site policies (`robotstxt`), utilizing rate-limiting and
reponse caching (`ratelimitr` amd `memoise`).

## Installation

You can install the development version of `polite` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dmi3kno/polite")
```

## Basic Example

This is a basic example which shows how to retrive the list of semi-soft
cheeses from www.cheese.com. Here, we authenticate a session and then
scrape the page with specified parameters. Behind the scenes `polite`
retrieves `robots.txt`, checks the url and useragent string against it,
caches the call to robots.txt and to the web page and enforces rate
limiting.

``` r
library(polite)
library(rvest)
#> Loading required package: xml2

session <- bow("https://www.cheese.com/by_type", force = TRUE)
#> No encoding supplied: defaulting to UTF-8.
#> No encoding supplied: defaulting to UTF-8.
result <- scrape(session, params="t=semi-soft&per_page=100") %>%
  html_nodes("h3") %>% 
  html_text()
head(result)
#> [1] "3-Cheese Italian Blend"  "Abbaye de Citeaux"      
#> [3] "Abbaye du Mont des Cats" "Adelost"                
#> [5] "ADL Brick Cheese"        "Ailsa Craig"
```

## Extended Example

You can build your own functions that incorporate `bow`, `scrape` (and,
if required, `nod`). Here we will extend our inquiry into cheeses and
will download all cheese names and url’s to their information pages.
Lets retrieve number of pages per letter in the alphabetical list,
keeping the number of results per page to 100 to minimize number of web
requests.

``` r
library(polite)
library(rvest)
library(tidyverse)
#> -- Attaching packages ---------------------------------------------------------------------------------------------------- tidyverse 1.2.1 --
#> v ggplot2 3.0.0     v purrr   0.2.5
#> v tibble  1.4.2     v dplyr   0.7.6
#> v tidyr   0.8.1     v stringr 1.3.1
#> v readr   1.1.1     v forcats 0.3.0
#> -- Conflicts ------------------------------------------------------------------------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter()         masks stats::filter()
#> x readr::guess_encoding() masks rvest::guess_encoding()
#> x dplyr::lag()            masks stats::lag()
#> x purrr::pluck()          masks rvest::pluck()

session <- bow("https://www.cheese.com/alphabetical")
#> No encoding supplied: defaulting to UTF-8.
#> No encoding supplied: defaulting to UTF-8.
responses <- map(letters, ~scrape(session, params = paste0("per_page=100&i=",.x)) )
results <- map(responses, ~html_nodes(.x, "#id_page") %>% 
                          html_text() %>% 
                          strsplit("\\s") %>% 
                          unlist() %>%
                          `%||%`(1) %>% 
                          as.numeric() %>% 
                          max(na.rm = TRUE) )
pages_df <- tibble(letter = rep.int(letters, times=unlist(results)),
                   pages = unlist(map(results, ~seq.int(from=1, to=.x))))
pages_df
#> # A tibble: 33 x 2
#>    letter pages
#>    <chr>  <int>
#>  1 a          1
#>  2 b          1
#>  3 b          2
#>  4 c          1
#>  5 c          2
#>  6 c          3
#>  7 d          1
#>  8 e          1
#>  9 f          1
#> 10 g          1
#> # ... with 23 more rows
```

Now that we know how many pages to retrieve from each letter page, lets
rotate over letter pages and retrieve cheese names and underlying links
to cheese details. We will need to write a helper function. Our session
is still valid and we dont need to `nod` again, because we will not be
modifying a page url, only its parameters (note that the field `url` is
missing from `scrape` function).

``` r
get_cheese_page <- function(letter, pages){
 lnks <- scrape(session, params=paste0("per_page=100&i=",letter,"&page=",pages)) %>% 
    html_nodes("h3 a")
 tibble(name=lnks %>% html_text(),
        link=lnks %>% html_attr("href"))
}

df <- pages_df %>% pmap_df(get_cheese_page)
df
#> # A tibble: 1,830 x 2
#>    name                    link                     
#>    <chr>                   <chr>                    
#>  1 Abbaye de Belloc        /abbaye-de-belloc/       
#>  2 Abbaye de Belval        /abbaye-de-belval/       
#>  3 Abbaye de Citeaux       /abbaye-de-citeaux/      
#>  4 Abbaye de Timadeuc      /abbaye-de-timadeuc/     
#>  5 Abbaye du Mont des Cats /abbaye-du-mont-des-cats/
#>  6 Abbot’s Gold            /abbots-gold/            
#>  7 Abertam                 /abertam/                
#>  8 Abondance               /abondance/              
#>  9 Acapella                /acapella/               
#> 10 "Accasciato "           /accasciato/             
#> # ... with 1,820 more rows
```

Package logo is uses elements of free image by
[pngtree.com](https://pngtree.com) \[1\] Wiktionary (2018), The free
dictionary, retrieved from
<https://en.wiktionary.org/wiki/bow_and_scrape>
