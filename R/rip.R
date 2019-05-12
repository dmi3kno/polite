#' Polite file download
#'
#' @param bow host introduction object of class `polite`, `session` created by `bow()` or `nod()`
#' @param new_filename optional new file name to use when saving the file
#' @param suffix optional characters added to file name
#' @param sep separator between file name and suffix. Default `__`
#' @param path path where file should be saved. Defaults to folder named `downloads` created in the working directory
#' @param overwrite if `TRUE` will overwrite file on disk
#' @param mode character. The mode with which to write the file. Useful values are `w`, `wb` (binary), `a` (append) and `ab`. Not used for methods `wget` and `curl`.
#' @param ... other parameters passed to `download.file`
#'
#' @return Full path to file indicated by URL saved on disk
#' @export
#'
#' @examples
#' \dontrun{
#' bow("www.mysite.com") %>%
#'   nod("file.txt") %>%
#'   rip()
#' }
#' @importFrom here here
#' @importFrom tools file_path_sans_ext file_ext
rip <- function(bow, new_filename=NULL, suffix=NULL, sep="__", path="downloads", overwrite=FALSE, mode="wb", ...){
  url <- bow$url
  base_name <- basename(url)

  if(!dir.exists(here::here(path)))
    dir.create(here::here(path))

  if(!is.null(suffix))  suffix <- paste0(sep, suffix)

  new_filename <- new_filename %||%
    paste0(tools::file_path_sans_ext(base_name), suffix, ".", tools::file_ext(base_name))

  new_filepath <- here::here(path, new_filename)

  if(file.exists(new_filepath) && !overwrite){
    warning("File already exists", call. = FALSE)
    return(new_filepath)
    }

  download_file_ltd(url, new_filepath, mode=mode, ...)

  return(new_filepath)
}
