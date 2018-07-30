#' @importFrom httr http_error GET add_headers warn_for_status content
#' @importFrom ratelimitr rate limit_rate
m_scrape <- function(bow, params=NULL, accept="html", verbose=FALSE) { # nolint

  httr_get <- function(bow){
    httr::GET(
      url = bow$url,
      config = bow$config,
      handle = bow$handle
    )
  }

  httr_get_ltd <- ratelimitr::limit_rate(
    httr_get,
    ratelimitr::rate(n = 1, period = bow$delay)
  )

  if(!inherits(bow, "polite"))
    stop("Please, be polite: bow and scrape!")


  if(!is.null(params))
    urltools::parameters(bow$url) <- params

  url_parsed <- urltools::url_parse(bow$url)

    if(!bow$robotstxt$check(path=url_parsed$path[1], bot=bow$user_agent)){
    message("No scraping allowed here!")
    return(NULL)
  }

  if(substr(accept,1,1)=="." || grepl("/", accept)){
    accept_type <- httr::accept(accept)
  } else{
    accept_type <- httr::accept(paste0(".", accept))
  }

  bow$config <- c(bow$config, accept_type)

  response <- httr_get_ltd(bow)
  max_attempts <- 3

  att_msg <- c(rep("",max_attempts-1),
               "This is the last attempt, if it fails will return NULL")

  try_number <- 1
  while (httr::http_error(response) && try_number < max_attempts) {
    try_number <- try_number + 1
    if (verbose)
      message(paste0("Attempt number ", try_number,".", att_msg[[try_number]]))

    Sys.sleep(2^try_number)
    response <- httr_get_ltd(bow)
  }

  status_warn_msg <- paste("fetch data from", bow$url)
  httr::warn_for_status(response, status_warn_msg)


  res <- httr::content(response, type = response$headers$`content-type`)
  res
}


#' Scrape the content of authorized page/API
#'
#' @param bow host introduction object of class `polite`, `session` created by `bow()` or `nod()`
#' @param params character vector of parameters to be appended to url in the format "parameter=value"
#' @param accept character value of expected data type to be returned by host (e.g. "html", "json", "xml", "csv", "txt", etc)
#' @param verbose extra feedback from the function. Defaults to FALSE
#'
#' @return Onbject of class `httr::response` which can be further processed by functions in `rvest` package
#'
#' @examples
#' \dontrun{
#'  library(rvest)
#'  biases <- bow("https://en.wikipedia.org/wiki/List_of_cognitive_biases") %>%
#'    scrape() %>%
#'    html_nodes(".wikitable") %>%
#'    html_table()
#'  biases
#'  }
#'
#'
#' \dontrun{
#'  library(rvest)
#'  library(polite)
#'
#'  host <- "https://www.cheese.com"
#'  session <- bow(host)
#'
#'  # scrape pages by re-authenticating on new page and scraping with parameters
#'  get_cheese <- function(session, path, params){
#'    nod(session, path) %>%
#'      scrape(params)
#'  }
#'
#'  res <- vector("list", 5)
#'  # iterate over first 5 pages
#'  for (i in seq(5)){
#'    res[[i]] <- get_cheese(session,
#'                 path = "alphabetical",
#'                 params = paste0("page=", i)) %>%
#'      html_nodes("h3 a") %>%
#'      html_text()
#'
#'  }
#'  res
#' }
#'
#' @export
scrape <- memoise::memoise(m_scrape)

