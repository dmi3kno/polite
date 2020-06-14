
extract_domain <- function(url){
  url_parsed <- httr::parse_url(url)
  paste0(url_parsed$scheme, "://", url_parsed$hostname)
}


fetch_rtxt <-function(domain, user_agent, delay, force, verbose){
  rt_txt <- robotstxt::get_robotstxt(domain=domain, force=force, user_agent = user_agent, verbose = verbose)
  rq <- attr(rt_txt, "request")
  rt <- robotstxt::robotstxt(text=rt_txt)
  rt_delay_df <- rt$crawl_delay
  crawldelay <-   as.numeric(with(rt_delay_df, value[useragent==user_agent])) %otherwise%
    as.numeric(with(rt_delay_df, value[useragent=="*"])) %otherwise% 0

  rt$delay_rate <- max(crawldelay, delay, 1)
  rt$received_from <- rq$url
  rt$cached <- attr(rt_txt, "cached")

  if(verbose){
    message("\nSuccess! robots.txt was found at: ", rt$received_from)
    message("Total of ", nrow(rt_delay_df), " crawl delay rule(s) defined for this host.")
    message("Your rate will be set to 1 request every ", rt$delay_rate, " second(s).")}

  rt
}


#' Give your web-scraping function good manners polite
#'
#' @param fun function to be turned "polite". Must contain an argument named `url`, which contains url to be queried.
#' @param user_agent optional, user agent string to be used. Defaults to `paste("polite", getOption("HTTPUserAgent"), "bot")`
#' @param robots optional, should robots.txt be consulted for permissions. Default is TRUE
#' @param force whether or not tp force fresh download of robots.txt
#' @param delay minimum delay in seconds, not less than 1. Default is 5.
#' @param verbose output more information about querying process
#' @param cache memoise cache function for storing results. Default `memoise::cache_memory()`
#'
#' @return polite function
#' @export
#'
#' @examples
#'
#' polite_GET <- politely(httr::GET)
#'
politely <- function(fun, user_agent=paste0("polite ", getOption("HTTPUserAgent"), "bot"),
                     robots=TRUE, force=FALSE, delay=5, verbose=FALSE, cache=memoise::cache_memory()){
  f_formals <- formals(args(fun))
  mem_fun <- memoise::memoise(fun, cache=cache)

  if(!"url" %in% names(f_formals) && verbose)
    message("It does not look like there's an argument with the name 'url' in this function. polite::politely() will assume that first argument is a url.")

  function(...){
    arg_lst <- list(...)
    af <- match_to_formals(arg_lst, f_formals)
    if("url" %in% names(af) && is_url(af[["url"]])){
      url <- af[["url"]]
    } else {
      if(is_url(af[[1]])){
        url <- af[[1]]
      } else {
        stop("I can't find an argument containing url. Aborting", call. = FALSE)
        return(NULL)
      }
    }


    if(robots){

      if(verbose) message("Fetching robots.txt")
            hst <- extract_domain(url)
      rtxt <- fetch_rtxt(domain=hst, user_agent = user_agent, delay=delay, force=force, verbose = verbose)
      delay <- rtxt$delay_rate

      if(!is_scrapable_rt(rtxt, url, user_agent)){
        warning("Unfortunately, robots.txt indicates that this path is NOT scrapable for your user agent", call. = FALSE)
        return(NULL)
      }
    }
    if(verbose) message("Pausing... ")
    Sys.sleep(delay)

    if(verbose) message("Scraping: ", url)
    old_ua <-  getOption("HTTPUserAgent")
    options("HTTPUserAgent"= user_agent)
    res <- mem_fun(...)
    options("HTTPUserAgent"= old_ua)
    res
  }
}
