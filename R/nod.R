#' Agree modification of session path with the host
#'
#' @param bow object of class `polite`, `session` created by `polite::bow()`
#' @param path string value of path/URL to follow. The function accepts either a path (string part of URL following domain name) or a full URL
#' @param verbose `TRUE`/`FALSE`
#' @return object of class `polite`, `session` with modified URL
#'
#' @examples
#' \donttest{
#'  library(polite)
#'
#'  host <- "https://www.cheese.com"
#'  session <- bow(host) %>%
#'               nod(path="by_type")
#'  session
#' }
#' @importFrom httr parse_url modify_url
#' @export
nod <- function(bow, path, verbose=FALSE){

  if(!inherits(bow, "polite"))
    stop("Please bow before you nod", call. = FALSE)

  # if user supplied URL instead of path
  if(grepl("://|www\\.", path)){
    url_parsed <- httr::parse_url(path)
    url_subdomain <- paste0(url_parsed$scheme, "://", url_parsed$hostname)
    if(url_subdomain!=bow$domain)
      bow <- bow(url = path, user_agent = bow$user_agent, delay=bow$delay, times=bow$times,
                 force=FALSE, verbose=verbose, bow$config)
    path <- url_parsed$path
  }

  bow$url <- httr::modify_url(bow$url, path=path)

  if(verbose && !is_scrapable(bow))
    warning("Psst!...It's not a good idea to scrape here!", call. = FALSE)

  bow
}
