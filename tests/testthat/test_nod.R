context("Nod")
library(polite)

test_that("Nod warns about disallowed url", {
  expect_warning(
    nod(bow("https://www.wikipedia.org/"),
        path="w/", verbose = TRUE), "scrape")
})
