#' Inroduce yourself to the host
#'
#' @param url url
#' @param user_agent character value passed to user_agent string
#' @param delay desired delay between scraping attempts. Final value will be the maximum of desired and mandated delay, as stipulated by robots.txt for relevant user agent
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
#' @rdname bow
#' @importFrom urltools domain path suffix_extract url_parse
#' @importFrom robotstxt robotstxt
#' @importFrom httr handle config add_headers
#' @importFrom memoise forget
#' @importFrom stats na.omit
#' @export
bow <- function(url,
                user_agent = "polite R package - https://github.com/dmi3kno/polite",
                delay = 5,
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
  # asking again if sub-domain does not specify permissions
  if(!nrow(rt$permissions)){
    url_domain <- paste(stats::na.omit(
      c(url_df$domain[1], url_df$suffix[1])),
      collapse=".")
    rt <- robotstxt::robotstxt(domain = url_domain,
                               user_agent = user_agent)
  }

  delay_df <- rt$crawl_delay
  delay_rt <- as.numeric(delay_df[with(delay_df, useragent==user_agent), "value"]) %||%
    as.numeric(delay_df[with(delay_df, useragent=="*"), "value"]) %||% 0

  # define object
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
      robotstxt= rt,
      delay  = max(delay_rt, delay)
    ),
    class = c("polite", "session")
  )

  if(verbose && !is_scrapable(self))
    warning("Psst!...It's not a good idea to scrape here!", call. = FALSE)

  if(self$delay<5)
    if(grepl("polite|dmi3kno", self$user_agent)){
      stop(red("You can not scrape this fast. Please, reconsider delay period."), call. = FALSE)
    } else{
      warning("This is a little too fast. Are you sure you want to risk being banned?", call. = FALSE)
    }

  self
}

#' @param x object of class `polite session`
#' @param ... other parameters passed to methods
#' @importFrom crayon yellow bold blue green red
#' @export
print.polite <- function(x, ...) {
  cat(yellow$bold("<polite session> "), x$url, "\n", sep = "")
  cat(blue("    ", "User-agent: "), x$user_agent, "\n", sep = "")
  cat(blue("    ", "robots.txt: "), nrow(x$robotstxt$permissions), " rules are defined for ",length(x$robotstxt$bots), " bots\n", sep = "")
  cat(blue("   ", "Crawl delay: "), x$delay," sec\n", sep = "")
  if(is_scrapable(x)){
    cat(green(" ", "The path is scrapable for this user-agent\n"), sep="")
  } else {
    cat(red(" ", "The path is not scrapable for this user-agent\n"), sep="")
  }
}

#' @param x object of class `polite session`
#' @rdname bow
#' @export
is.polite <- function(x) inherits(x, "polite")
