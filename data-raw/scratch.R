httr_get <- function(url){
  httr::GET(
    url,
    httr::add_headers(
      Accept = "text/html",
      "user-agent" = "an R package"
    )
  )
}

httr_get_rate_ltd <- ratelimitr::limit_rate(
  httr_get,
  ratelimitr::rate(n = 1, period = 1.6)
)

get_data_with_errors <- function(url, verbose) {
  # error handling function

  # api call
  mb_data <- httr_get_rate_ltd(url)

  # status check
  status <- httr::status_code(mb_data)

  if (status > 200) {
    # this is more problematic and we shall try again
    if (verbose) {
      message(paste("http error code:", status))
    }
    res <- NULL
  }
  if (status == 200) res <- httr::content(mb_data, type = "text/html; charset=utf-8")
  res
}

# main re-attempt function
.GET_data <- function(url, verbose=TRUE) { # nolint
  output <- get_data_with_errors(url, verbose)
  max_attempts <- 3

  try_number <- 1
  while (is.null(output) && try_number < max_attempts) {
    try_number <- try_number + 1
    if (verbose) {
      message(paste0("Attempt number ", try_number))
      if (try_number == max_attempts) {
        message("This is the last attempt, if it fails will return NULL") # nolint
      }
    }
    Sys.sleep(2^try_number)
    output <- get_data_with_errors(url, verbose)
  }
  output
}

get_data <- memoise::memoise(.GET_data)

get_html <- function(i=NULL, page=NULL, url=getOption("my.url")) {

  stopifnot(!is.null(url))

  if (!is.null(i) || !is.null(page)) {
    parsed_url <- httr::parse_url(url)
    parsed_url$query <- base::list(per_page = 100, i=i, page=page)
    url <- httr::build_url(parsed_url)
  }

  get_data(url)
}
