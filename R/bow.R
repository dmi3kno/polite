#' Inroduce yourself to the host
#'
#' @param url url
#' @param user_agent character value passed to user_agent string
#' @param force refresh all memoised functions. Clears up all robotstxt and scrape cache. Default is FALSE.
#' @param verbose TRUE/FALSE
#' @param ... other curl parameters wrapped into httr::config function
#'
#' @return object of class `polite`, `session`
#'
#' @examples
#' \dontrun{
#'  library(polite)
#'
#'  host <- "https://www.cheese.com"
#'  session <- bow(host)
#'  session
#' }
#' @importFrom urltools domain path suffix_extract url_parse
#' @importFrom robotstxt robotstxt
#' @importFrom httr handle config add_headers
#' @importFrom memoise forget
#' @importFrom stats na.omit
#' @export
bow <- function(url,
                user_agent = "polite R package - https://github.com/dmi3kno/polite",
                force = FALSE, verbose=FALSE,
                ...){
  stopifnot(is.character(user_agent), length(user_agent) == 1) # write meaningful error ref Lionel talk
  stopifnot(is.character(url), length(url) == 1) # write meaningful error ref Lionel talk

  if(force) memoise::forget(scrape)

  url_parsed <- urltools::url_parse(url)
  url_parsed[is.na(url_parsed$path), "path"] <- "/"

  url_df <- urltools::suffix_extract(url_parsed$domain)
  url_subdomain <- paste(na.omit(c(url_df$subdomain[1],
                      url_df$domain[1],
                      url_df$suffix[1])), collapse=".")
  rt <- robotstxt::robotstxt(domain = url_subdomain,
                            user_agent = user_agent,
                            warn=verbose, force = force)
  if(!nrow(rt$permissions)){
    url_domain <- paste(stats::na.omit(c(url_df$domain[1],
                                  url_df$suffix[1])), collapse=".")
    rt <- robotstxt::robotstxt(domain = url_domain,
                               user_agent = user_agent)
  }

  self <- structure(
    list(
      handle   = httr::handle(url),
      config   = c(httr::config(autoreferer = 1L),
                   httr::add_headers("user-agent"=user_agent),...),
      url      = url,
      back     = character(),
      forward  = character(),
      response = NULL,
      html     = new.env(parent = emptyenv(), hash = FALSE),
      user_agent = user_agent,
      domain   =  url_subdomain,
      robotstxt= rt
    ),
    class = c("polite", "session")
  )

  if(verbose && !is_scrapable(self))
    warning("Psst!...It's not a good idea to scrape here!", call. = FALSE)

  self
}

