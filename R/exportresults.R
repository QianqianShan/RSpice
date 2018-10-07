#' Export the output from Spice
#'
#' @param location the location of the output we want to export,
#'  i.e. the location-th vector name from the getlength function.
#' @param data a list of double values (0 by default)which has the
#'  same length with the output we want to export, so R can copy
#'  the output to this list.
#' @return the list of the output we specified.
#' @useDynLib RSpice
#' @export
exportResults <- function(location, data) {
    .C("ExportResults", as.integer(location - 
        1), as.double(data))
}

