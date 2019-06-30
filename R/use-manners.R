#' Use manners in your own package or script
#'
#' Creates collection of  `polite` functions for scraping and downloading
#'
#' @param save_as File where function should be created Defaults to "`R/polite-scrape.R`"
#' @param open if `TRUE`, open the resultant files
#' @importFrom usethis use_template
#' @export
use_manners <- function(save_as="R/polite-scrape.R", open = TRUE) {

  usethis::use_template("polite_template.R", save_as = save_as,
                      open = open, package = "polite")
  invisible()
}
