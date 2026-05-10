#' Polite file download
#'
#' @param bow host introduction object of class `polite`, `session` created by `bow()` or `nod()`
#' @param destfile optional new file name to use when saving the file. If missing, it will be guessed from `basename(url)``
#' @param ... other parameters passed to `download.file`
#' @param mode character. The mode with which to write the file. Useful values are `w`, `wb` (binary), `a` (append) and `ab`. Not used for methods `wget` and `curl`.
#' @param path character. Path where to save the destfile. By default is temporary directory created with `tempdir()`
#' Ignored if `destfile` contains path along with filename.
#' @param overwrite if `TRUE` will overwrite file on disk
#'
#' @return Full path to the locally saved file indicated by the user in `destfile` (and `path`)
#' @export
#'
#' @examples
#' \donttest{
#' bow("https://en.wikipedia.org/") %>%
#'  nod("wiki/Flag_of_the_United_States#/media/File:Flag_of_the_United_States.svg") %>%
#'  rip()
#' }
rip <- function(bow, destfile=NULL, ..., mode="wb", path=tempdir(), overwrite=FALSE){

  url <- bow$url

  if (is.null(destfile)) destfile <- basename(url)

  if(dirname(destfile)!=dirname(".")) path <- dirname(destfile)

  if(!dir.exists(path)) dir.create(path, recursive = TRUE)

  destfilepath <- file.path(path, destfile)

  if(file.exists(destfilepath) && !overwrite){
    warning("File already exists", call. = FALSE)
    return(destfilepath)
    }

  download_file_ltd(url, destfilepath, mode=mode, ...)

  return(destfilepath)
}


