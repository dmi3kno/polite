#' Agree modification of session path with the host
#'
#' @param bow object of class `polite`, `session` created by `polite::bow()`
#' @param path string value of path/url to follow. The function accepts both path (string part of url followin domain name) or a full url.
#'
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
#' @export
nod <- function(bow, path){

  if(!inherits(bow, "polite"))
    stop("Please, bow before you nod")

  # if user supplied url instead of path
  if(grepl("://|www\\.", path)){
    if(urltools::domain(path)!=bow$domain)
      nod <- bow(url = url, user_agent = bow$user_agent, bow$config)
    path <- urltools::path(path)
  }
  urltools::path(bow$url) <- path

  nod
}
