#' null-coalescing operator. See purr for details.
`%||%` <- function(lhs, rhs) {
  if (!is.null(lhs) && length(lhs) > 0) lhs else rhs
}

#' function to get robots.txt is structured form. Memoised
polite_fetch_rtxt <- memoise::memoise(function(..., user_agent, delay, verbose){
  rt <- robotstxt::robotstxt(...)
  delay_df <- rt$crawl_delay
  crawldelays <-   as.numeric(delay_df[with(delay_df, useragent==user_agent), "value"]) %||%
    as.numeric(delay_df[with(delay_df, useragent=="*"), "value"]) %||% 0

  rt$delay_rate <- max(crawldelays, delay, 1)

  if(verbose){
    message("Bowing to: ", rt$domain)
    message("There's ", nrow(delay_df), " crawl delay rule(s) defined for this host.")
    message("Your rate will be set to 1 request every ", rt$delay_rate, " second(s).")}

  rt
})

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
polite_read_html <- memoise::memoise(
                   function(url, ...,
                   delay = 5,
                   user_agent=paste0("polite ", getOption("HTTPUserAgent"), "bot"),
                   force = FALSE,
                   verbose=FALSE){

  if(!check_rtxt(url, delay, user_agent, force, verbose)){
    return(NULL)
  }

  old_ua <-  getOption("HTTPUserAgent")
  options("HTTPUserAgent"= user_agent)
  if(verbose) message("Scraping: ", url)
  res <- httr::GET(url, ...)
  options("HTTPUserAgent"= old_ua)
  httr::content(res)
})


guess_basename <- function(x) {
  destfile <- basename(x)
  if(tools::file_ext(destfile)==""){
    hh <- httr::HEAD(x)
    cds <- httr::headers(hh)$`content-disposition`
    destfile <- gsub('.*filename=', '', gsub('\\\"','', cds))
  }
  destfile %||% basename(x)
}

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
  options("HTTPUserAgent"= user_agent)
  if(verbose) message("Scraping: ", url)
  utils::download.file(url=url, destfile=destfile, quiet=quiet, mode=mode, ...)
  options("HTTPUserAgent"= old_ua)
  destfile
})

