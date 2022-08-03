#' null-coalescing operator. See purr for details.
#'
#' @param lhs legt hand side
#' @param rhs right hand side
#' @examples
#' a %otherwise% b
#'
`%otherwise%` <- function(lhs, rhs) {
  if (!is.null(lhs) && length(lhs) > 0) lhs else rhs
}

#' Function to get robots.txt is structured form. Memoised
#'
#' @param ... arguments passed to `robotstxt::robotstxt()`
#' @param user_agent user agent string
#' @param delay default delay
#' @param verbose logical
#' @examples
polite_fetch_rtxt <- memoise::memoise(function(..., user_agent, delay, verbose){
  rt <- robotstxt::robotstxt(...)
  delay_df <- rt$crawl_delay
  crawldelays <-   as.numeric(delay_df[with(delay_df, useragent==user_agent), "value"]) %otherwise%
    as.numeric(delay_df[with(delay_df, useragent=="*"), "value"]) %otherwise% 0

  rt$delay_rate <- max(crawldelays, delay, 1)

  if(verbose){
    message("Bowing to: ", rt$domain)
    message("There's ", nrow(delay_df), " crawl delay rule(s) defined for this host.")
    message("Your rate will be set to 1 request every ", rt$delay_rate, " second(s).")}

  rt
})

#' Function for checking robots.txt file
#'
#' @param url web address for download
#' @param delay default delay
#' @param user_agent user agent string
#' @param force force re-downloading of robots.xtx
#' @param verbose logical
#'
#' @return
#'
#' @examples
check_rtxt <-function(url, delay, user_agent, force, verbose){
  url_parsed <- httr::parse_url(url)
  host_url <- paste0(url_parsed$scheme, "://", url_parsed$hostname)
  rt <- polite_fetch_rtxt(host_url, force=force, user_agent=user_agent, delay=delay, verbose=verbose)
  is_scrapable <- rt$check(paths=url_parsed$path, bot=user_agent)

  if(is_scrapable)
    Sys.sleep(rt$delay_rate)
  else
    warning("robots.txt says this path is NOT scrapable for your user agent!", call. = FALSE)

  is_scrapable
}

#' function that actually fetches response from the web
#'
#' @param url web address for scraping
#' @param ... arguments passed to `httr::GET()`
#' @param delay scrapting delay. Default 5 sec
#' @param user_agent user agent string. Default value `paste0("polite ", getOption("HTTPUserAgent"), "bot")`
#' @param force force re-download of robots.txt
#' @param verbose default FALSE
#'
#' @return
#'
#' @examples
polite_read_html <- memoise::memoise(
                   function(url, ...,
                   delay = 5,
                   user_agent=paste0("polite ", getOption("HTTPUserAgent"), "bot"),
                   force = FALSE,
                   verbose=FALSE){

  if(!check_rtxt(url, delay, user_agent, force, verbose)){
    return(NULL)
  }
# this is not working yet.
#  old_ua <-  getOption("HTTPUserAgent")
#  options("HTTPUserAgent"= user_agent)
  if(verbose) message("Scraping: ", url)
  res <- httr::GET(url, user_agent(user_agent), ...)
#  options("HTTPUserAgent"= old_ua)
  httr::content(res)
})


#' Guess filename for download from url
#'
#' @param x url to guess filename from
#'
#' @return
#'
#' @examples
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


#' Polite download
#'
#' @param url web address for the file to be downloaded
#' @param destfile name of destination file
#' @param ... additional arguments passed to `download.file`
#' @param quiet default value is inverse of  `verbose`
#' @param mode download mode. Default value is "wb"
#' @param path path to save. Default path `downloads/`
#' @param user_agent default value `paste0("polite ", getOption("HTTPUserAgent"))`
#' @param delay default value equal 5
#' @param force force re-download of robots.txt
#' @param overwrite overwrite downloaded file. Default value FALSE
#' @param verbose default value is FALSE
#'
#' @return
#'
#' @examples
polite_download_file <- memoise::memoise(
                        function(url, destfile=guess_basename(url), ...,
                             quiet=!verbose, mode = "wb", path="downloads/",
                             user_agent=paste0("polite ", getOption("HTTPUserAgent")),
                             delay = 5, force = FALSE, overwrite=FALSE, verbose=FALSE){

  if(!check_rtxt(url, delay, user_agent, force, verbose)) return(NULL)

  if(!dir.exists(path)) dir.create(path)

  destfile <- paste0(path, destfile)

  if(file.exists(destfile) && !overwrite){
    message("File ", destfile, " already exists!")
    return(destfile)
  }

  old_ua <-  getOption("HTTPUserAgent")
  on.exit(options("HTTPUserAgent"= old_ua), add = TRUE)
  options("HTTPUserAgent"= user_agent)
  if(verbose) message("Scraping: ", url)
  utils::download.file(url=url, destfile=destfile, quiet=quiet, mode=mode, ...)
  options("HTTPUserAgent"= old_ua)
  destfile
})

