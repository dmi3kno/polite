#' Null coalescing operator
#'
#' See \code{purrr::\link[purrr]{\%||\%}} for details.
#'
#' @name null-coalesce
#' @rdname nullcoalesce
#' @keywords internal
#' @usage lhs \%||\% rhs
`%||%` <- function(lhs, rhs) {
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

#' @importFrom httr parse_url
is_scrapable <- function(bow){
  url_parsed <- httr::parse_url(bow$url)
  bow$robotstxt$check(path=url_parsed$path, bot=bow$user_agent)
}

#' @importFrom httr GET
httr_get <- function(url, config, handle){
  httr::GET(
    url = url,
    config = config,
    handle = handle
  )
}

#' @importFrom ratelimitr limit_rate rate
httr_get_ltd <- ratelimitr::limit_rate(httr_get,
                                       ratelimitr::rate(n = 1, period=5))

#' @importFrom ratelimitr limit_rate rate
#' @importFrom utils download.file
download_file_ltd <- ratelimitr::limit_rate(utils::download.file,
                                       ratelimitr::rate(n = 1, period=5))
