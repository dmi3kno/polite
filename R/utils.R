#' Null coalescing operator
#'
#'
#' @name null-coalesce
#' @rdname nullcoalesce
#' @keywords internal
#' @usage lhs \%otherwise\% rhs
#'
`%otherwise%` <- function(lhs, rhs) {
  if (!is.null(lhs) && length(lhs) > 0) lhs else rhs
}

#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

is_scrapable <- function(bow){
  is_scrapable_rt(bow$robotstxt, bow$url, bow$user_agent)
}

#' @importFrom httr parse_url
is_scrapable_rt <- function(rtxt, url, user_agent){
  url_parsed <- httr::parse_url(url)
  rtxt$check(paths=url_parsed$path, bot=user_agent)
}

#' @importFrom httr GET
httr_get <- function(url, config, handle, times, verbose){
  httr::RETRY(verb="GET",
    url = url,
    config = config,
    handle = handle,
    times = times,
    pause_base = 5,
    quiet=!verbose
  )
}

#' @importFrom ratelimitr limit_rate rate
httr_get_ltd <- ratelimitr::limit_rate(httr_get,
                                       ratelimitr::rate(n = 1, period=5))

#' @importFrom ratelimitr limit_rate rate
#' @importFrom utils download.file
download_file_ltd <- ratelimitr::limit_rate(utils::download.file,
                                       ratelimitr::rate(n = 1, period=5))



#' Guess download file name from the URL
#'
#' @param x url to guess basename from
#'
#' @return guessed file name
#' @export
#'
#' @examples
#' guess_basename("https://bit.ly/polite_sticker")
#'
#' @importFrom tools file_ext
#' @importFrom httr HEAD headers
guess_basename <- function(x) {
  destfile <- basename(x)
  if(tools::file_ext(destfile)==""){
    hh <- httr::HEAD(x)
    destfile <- basename(hh$url)
    if(tools::file_ext(destfile)==""){
    cds <- httr::headers(hh)$`content-disposition`
    destfile <- gsub('.*filename=', '', gsub('\\\"','', cds))
  }}
  destfile %otherwise% basename(x)
}


is_url <- function(x){
  # from Jim Hester's rex vignette https://cran.r-project.org/web/packages/rex/vignettes/url_parsing.html
  re <- "^(?:(?:http(?:s)?|ftp)://)(?:\\S+(?::(?:\\S)*)?@)?(?:(?:[a-z0-9\u00a1-\uffff](?:-)*)*(?:[a-z0-9\u00a1-\uffff])+)(?:\\.(?:[a-z0-9\u00a1-\uffff](?:-)*)*(?:[a-z0-9\u00a1-\uffff])+)*(?:\\.(?:[a-z0-9\u00a1-\uffff]){2,})(?::(?:\\d){2,5})?(?:/(?:\\S)*)?$"
  grepl(re, x)
}
