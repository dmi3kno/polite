#' Polite file download
#'
#' @param bow host introduction object of class polite, session created by bow() or nod
#' @param suffix optional characters added to file name
#' @param sep separator between file name and suffix. Default "__"
#' @param path path where file should be saved. Defults to folder named "downloads" created in the working directory
#' @param overwrite if TRUE will overwrite file on disk
#' @param mode character. The mode with which to write the file. Useful values are "w", "wb" (binary), "a" (append) and "ab". Not used for methods "wget" and "curl".
#' @param ... other parameters passed to download.file
#'
#' @return Full path to file indicated by url saved on disk
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
rip <- function(bow, suffix=NULL, sep="__", path="downloads", overwrite=FALSE, mode="wb", ...){
  url <- bow$url
  if(!dir.exists(here::here(path)))
    dir.create(here::here(path))

  new_file_name <- paste0(tools::file_path_sans_ext(basename(url)), sep, suffix, ".", tools::file_ext(basename(url)), sep="")

  if(file.exists(here::here(path, basename(url))) && !overwrite){
    warning("File already exists", call. = FALSE)
    return(here::here(path, basename(url)))
    }

  bow$download_file_ltd(url, here::here(path, new_file_name), mode=mode, ...)

  return(here::here(path, new_file_name))
}
