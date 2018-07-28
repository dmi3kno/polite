context("Bow")
library(polite)

test_that("Bow warns about disallowed url", {
 expect_warning(bow("https://www.wikipedia.org/w/", verbose = TRUE), "scrape")
})
