#' Export the output from Ngspice
#'
#' @param location a vector of the location(s) of the output we want to export,
#'  i.e. the location-th vector name from the getlength function.
#' @return the list of the output we specified.
#' @examples 
#' \dontrun{exportResults(c(1, 2, 4))}
#' @useDynLib RSpice
#' @export
exportResults <- function(location) {
    if (any(location <= 0)) {
        stop("location argument must be positive integers.")
    }
    len <- getLength()
    if (max(location) > len) {
      stop("location out of range.")
    }
    if (len > 0) {
        # if there are results returned
        result <- matrix(NA, nrow = length(location), 
            ncol = len)
        rownames(result) <- location
        for (i in 1:length(location)) {
            result[i, ] <- .C("ExportResults", 
                as.integer(location[i] - 1), 
                as.double(double(len)))[[2]]
        }
        return(result)
    }
}

