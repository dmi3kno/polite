#' Agree modification of session path with the host
#'
#' @param bow object of class `polite`, `session` created by `polite::bow()`
#' @param path string value of path/url to follow. The function accepts both path (string part of url followin domain name) or a full url.
#' @param verbose TRUE/FALSE
#' @return object of class `polite`, `session` with modified url
#'
#' @examples
#' \dontrun{
#'  library(polite)
#'
#'  host <- "https://www.cheese.com"
#'  session <- bow(host) %>%
#'               nod(path="by_type")
#'  session
#' }
#' @importFrom urltools domain path url_parse url_compose
#' @export
nod <- function(bow, path, verbose=FALSE){

  if(!inherits(bow, "polite"))
    stop("Please, bow before you nod")

  # if user supplied url instead of path
  if(grepl("://|www\\.", path)){
    if(urltools::domain(path)!=bow$domain)
      bow <- bow(url = url, user_agent = bow$user_agent, delay=bow$delay, bow$config)
    path <- urltools::path(path)
  }
  parsed_url <- urltools::url_parse(bow$url)
  parsed_url$path <- path
  bow$url <- urltools::url_compose(parsed_url)

  if(verbose && !is_scrapable(bow))
    warning("Psst!...It's not a good idea to scrape here!", call. = FALSE)

  bow
}
