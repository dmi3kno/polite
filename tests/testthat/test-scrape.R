context("Scrape")
library(webmockr)
library(testthat)

webmockr::enable(adapter = "httr")

webmockr::httr_mock()

webmockr::stub_registry_clear()

#### stub robotstxt request

rb_txt <- "User-agent: *\nDisallow: /deny\n"

webmockr::stub_request("get", "https://httpbin.org/robots.txt") %>%
  wi_th(
    headers = list('Accept' = 'application/json, text/xml, application/xml, */*',
                   'user-agent' = 'polite R package')) %>%
  webmockr::to_return(body=rb_txt, status=200)

#### stub scraping request
rq_txt <- list()

for (i in 1:2){
 rq_txt[i]<- paste0('{"args": {"q": ',
                  i,'},"headers": {"Accept": "application/json","User-Agent": "polite R package"}',
                  ',"url": "https://httpbin.org/get?q=',i,'"}')

 stub_request("get", paste0("https://httpbin.org/get?q=",i)) %>%
   wi_th(
     headers = list('Accept' = 'application/json',
                    'user-agent' = 'polite R package')) %>%
   webmockr::to_return(body=rq_txt[[i]], status=200)
}
#webmockr::stub_registry()

base_url <- "https://httpbin.org/get"
query_lst <- list(q=1)
session <- polite::bow(base_url)
res <- scrape(session, query = query_lst, accept = "application/json", verbose = TRUE)

test_that("bow type is controlled", {
  expect_error(scrape(base_url), regexp = "bow")
})

test_that("query is controlled", {
  expect_error(scrape(session, query = c(q=1)), regexp = "is.list")
})

test_that("scrape is returning proper result",{
  expect_equal(res, charToRaw(rq_txt[[1]]))
})

session <- polite::bow(base_url, force = TRUE)

test_that("Forced bow is un-memoised", {
  expect_false(memoise::has_cache(polite::scrape)(bow=session))
})

webmockr::disable(adapter = "httr")
