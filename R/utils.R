#' Null coalescing operator
#'
#' See \code{purrr::\link[purrr]{\%||\%}} for details.
#'
#' @name null-coalesce
#' @rdname nullcoalesce
#' @keywords internal
#' @export
#' @usage lhs \%||\% rhs
"%||%" <- function(lhs, rhs) {
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

#' @importFrom urltools path
is_scrapable <- function(bow){
  bow$robotstxt$check(path=urltools::path(bow$url), bot=bow$user_agent)
}

