context("Bow")
library(polite)
library(webmockr)

webmockr::enable(adapter = "httr")

webmockr::httr_mock()

webmockr::stub_registry_clear()

rb_txt <- "User-agent: *\nDisallow: /deny\n"

#### mocking robotstxt request

webmockr::stub_request("get", "https://httpbin.org/robots.txt") %>%
  webmockr::wi_th(
    headers = list('Accept' = 'text/html',
                   'user-agent' = 'polite R package')) %>%
  webmockr::to_return(body=rb_txt, status=200)

test_that("Argument assurances in bow work", {
  expect_error(bow("https://httpbin.org/get", user_agent = c("polite", "R", "package")), regexp = "length")
  expect_error(bow("https://httpbin.org/get", user_agent =42L), regexp = "Character")
  expect_error(bow(url=42L, user_agent ="polite R package"), regexp = "Character")
  expect_error(bow(url = c("https://httpbin.org/get", "https://httpbin.org/post")), regexp = "length")
  expect_error(bow("https://httpbin.org/get", times=0), regexp = "times")
  expect_error(bow("https://httpbin.org/get", times="five"), regexp = "times")
  })

webmockr::stub_registry_clear()
webmockr::disable(adapter = "httr")

