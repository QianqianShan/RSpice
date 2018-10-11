#' Export the output from Spice
#'
#' @param location a vector of the location(s) of the output we want to export,
#'  i.e. the location-th vector name from the getlength function.
#' @return the list of the output we specified.
#' @useDynLib RSpice
#' @export
exportResults <- function(location) {
  if (any(location <= 0)) {
    stop("location argument must be positive integers.")
  }
   len <- getLength()
   result <- matrix(NA, nrow = length(location), ncol = len)
   rownames(result) <- location
   for (i in 1:length(location)) {
     result[i, ] <- .C("ExportResults", as.integer(location[i] - 1), as.double(double(len)))[[2]]
   } 
 return(result)
}

