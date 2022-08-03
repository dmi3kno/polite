#' Introduce yourself to the host
#'
#' @param url URL
#' @param user_agent character value passed to user agent string
#' @param delay desired delay between scraping attempts. Final value will be the maximum of desired and mandated delay, as stipulated by `robots.txt` for relevant user agent
#' @param times number of times to attempt scraping. Default is 3.
#' @param force refresh all memoised functions. Clears up `robotstxt` and `scrape` caches. Default is `FALSE`
#' @param verbose TRUE/FALSE
#' @param ... other curl parameters wrapped into `httr::config` function
#'
#' @return object of class `polite`, `session`
#'
#' @examples
#' \donttest{
#'  library(polite)
#'
#'  host <- "https://www.cheese.com"
#'  session <- bow(host)
#'  session
#' }
#' @rdname bow
#' @importFrom robotstxt robotstxt
#' @importFrom httr parse_url handle config add_headers GET
#' @importFrom ratelimitr limit_rate rate get_rates
#' @importFrom memoise forget
#' @importFrom stats na.omit
#' @importFrom utils download.file
#' @export
bow <- function(url,
                user_agent = "polite R package",
                delay = 5,
                times = 3,
                force = FALSE, verbose=FALSE,
                ...){

  stopifnot("Character user agent is required"=is.character(user_agent))
  stopifnot("Single user agent is required. Please provide character vector of length 1"=(length(user_agent) == 1)) # write meaningful error ref Lionel talk
  stopifnot("Character URL is required"=is.character(url))
  stopifnot("Single URL should be provided. Please provide character vector of length 1"=(length(url) == 1)) # write meaningful error ref Lionel talk
  stopifnot("Number of times to attempt scraping should be numeric"=is.numeric(times))
  stopifnot("Number of times to attempt scraping should be positive"=(times>0))
  if(force) memoise::forget(scrape)

  url_parsed <- httr::parse_url(url)
  url_subdomain <- paste0(url_parsed$scheme, "://", url_parsed$hostname)
  rt <- robotstxt::robotstxt(domain = url_subdomain,
                            user_agent = user_agent,
                            warn = verbose, force = force)

  delay_df <- rt$crawl_delay
  delay_rt <- as.numeric(delay_df[with(delay_df, useragent==user_agent), "value"]) %otherwise%
    as.numeric(delay_df[with(delay_df, useragent=="*"), "value"]) %otherwise% 0

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
      delay  = max(delay_rt, delay),
      times = times
    ),
    class = c("polite", "session")
  )

  if(verbose && !is_scrapable(self))
    warning("Psst!...It's not a good idea to scrape here!", call. = FALSE)

  if(self$delay<5)
    if(grepl("polite|dmi3kno", self$user_agent)){
      stop("You cannot scrape this fast. Please reconsider delay period.", call. = FALSE)
    warning("This is a little too fast. Are you sure you want to risk being banned?", call. = FALSE)
    }

  # set new rate limits
  if(self$delay != ratelimitr::get_rates(httr_get_ltd)[[1]]["period"]){
    set_scrape_delay(self$delay)
  }

  if(self$delay != ratelimitr::get_rates(download_file_ltd)[[1]]["period"]){
    set_rip_delay(self$delay)
  }

  self
}


#' Reset scraping/ripping rate limit
#'
#' @param delay Delay between subsequent requests. Default for package is 5 sec.
#' It can be set lower only under the condition of specifying a custom user-agent string.
#'
#' @return Updates rate-limit property of `scrape` and `rip` functions, respectively.
#'
#' @examples
#' \donttest{
#'  library(polite)
#'
#'  host <- "https://www.cheese.com"
#'  session <- bow(host)
#'  session
#' }
#' @rdname set_delay
#' @importFrom ratelimitr UPDATE_RATE rate
#' @export
set_scrape_delay <- function(delay){
  ratelimitr::UPDATE_RATE(httr_get_ltd,ratelimitr::rate(n=1, period = delay))
}

#' @rdname set_delay
#' @importFrom ratelimitr UPDATE_RATE rate
#' @export
set_rip_delay <- function(delay){
  ratelimitr::UPDATE_RATE(download_file_ltd,ratelimitr::rate(n=1, period = delay))
}

#' Print host introduction object
#'
#' @param x object of class `polite`, `session`
#' @param ... other parameters passed to methods
#' @export
print.polite <- function(x, ...) {
  cat(paste0("<polite session> ", x$url, "\n",
             "    ", "User-agent: ", x$user_agent, "\n",
             "    ", "robots.txt: ", nrow(x$robotstxt$permissions), " rules are defined for ",length(x$robotstxt$bots), " bots\n",
             "   ", "Crawl delay: ", x$delay," sec\n"))
  if(is_scrapable(x)){
    cat(" ", "The path is scrapable for this user-agent\n")
  } else {
    cat(" ", "The path is not scrapable for this user-agent\n")
  }
}

#' @param x object of class `polite`, `session`
#' @rdname bow
#' @export
is.polite <- function(x) inherits(x, "polite")
