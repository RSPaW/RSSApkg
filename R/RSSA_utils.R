# utility helper functions

#' Renames incorrect image date folders when incorrect due to leap year errors.
#'
#' \code{u_leapR} reads the date of a suncorrected image, checks it against the
#' folder name and if incorrect, renames the folder. This corrects for leap year
#' folder naming errors propogated by batch processing.
#'
#' @param path Character string filepath to the path/row of imagery to check.
#'
#' @return If incorrectly named folders are identified they are renamed a day
#'     earlier, otherwise a message "No leap date folder errors" is printed to
#'     screen.
#'
#' @examples
#' \dontrun{
#' u_leapR("W:/usgs/115078")
#' }

u_leapR <- function(path){
  allfiles <- list.files(path = path, recursive = TRUE)
  result <- allfiles[grepl("*pre.ers", allfiles)]
  result <- result[!grepl("^[a-zA-Z]", result)]
  #date for folder
  fold <- substr(result, 1, 8)
  fdate <- as.character(lubridate::ymd(fold))
  #date for image
  ldate <- as.character(lubridate::dmy(substr(result, 21, 26)))
  #find mismatch
  bad.fold.dates <- setdiff(fdate, ldate)
  if(length(bad.fold.dates) > 0){
    #correct the folder names and path
    corr.fold.dates <- lubridate::ymd(bad.fold.dates) - 1
    corr.fold <- gsub("-", "", as.character(corr.fold.dates))
    new.name <- paste0(path, "\\", corr.fold)
    #old folder names and path to correct
    bad.fold <- gsub("-", "", as.character(bad.fold.dates))
    old.name <- paste0(path, "\\", bad.fold)
    #rename folders
    file.rename(old.name, new.name)
  } else {
    cat("No leap date folder errors")
  }

}

#' Creates a data frame of paths, folder names and dates.
#'
#' \code{u_dateR} creates a data frame of paths, folder names and dates from the
#' contents of a folder.
#'
#' This output of this function will hold paths, folder names and dates that will
#' be used for other functions such as \code{jpegR} and \code{extractR}.
#'
#' @param path Character string filepath to the path/row of satellite imagery to
#'     check. Can also be a folder of jpegs or some other date named files.
#'
#' @param archive A logical scalar. \strong{TRUE}  will assume \strong{path} is
#'     indicating RSSA internal USGS archive. \strong{FALSE} can be used when
#'     querying a QA jpeg folder or the like.
#'
#' @param pat Pattern to search for in a non-USGS imagery archive. Defaults to
#'     ".jpeg".
#'
#' @return For a USGS imagery archive the query will return a data frame with:
#' \itemize{
#'     \item path - a column of character string file paths
#'     \item folds - a column of haracter string folder names
#'     \item dates - a column of date class dates
#'     }
#' For a non-USGS archive the query will return a data frame with:
#' \itemize{
#'     \item path - a column of character string file paths
#'     \item folds - a column of haracter string folder names
#'     }
#' @examples
#' \dontrun{
#' u_dateR(path = "W:/usgs/115078", archive = TRUE)
#' u_dateR(path = "Z:/DEC/working/QA...", archive = FALSE, pat = ".jpeg")
#' }
#'
#' @export
#' @import lubridate

u_dateR <- function(path, archive, pat = ".jpeg"){
  if(archive == TRUE){
    u_leapR(path)
    prefolds <- list.files(path = path, pattern = "*pre.ers$", recursive = TRUE)
    ind <- grepl("^[[:digit:]]", prefolds)
    prefolds <- prefolds[ind]
    datesdf <- data.frame(path = paste0(path, "/", prefolds),
                          folds = substr(prefolds, 1, 8),
                          dates = lubridate::ymd(substr(prefolds, 1, 8)),
                          stringsAsFactors = FALSE)
    return(datesdf)
  } else {
    files <- list.files(path = path, pattern = pat)
    datesdf <- data.frame(folds = gsub("-", "", substr(files, 1, 10)),
                          dates = lubridate::ymd(substr(files, 1, 10)),
                          stringsAsFactors = FALSE)
    return(datesdf)
  }
}