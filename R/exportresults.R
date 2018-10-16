#' Export the Output Values from Ngspice
#'
#' @param location a vector of the location(s) of the output we want to export,
#'  i.e. the location-th output from the \code{getPlotNames()}.
#' @examples 
#' \dontrun{
#' # Export the output values at location 1, 2 and 4. 
#' exportResults(c(1, 2, 4))
#' }
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
                as.integer(location[i] - 1), as.double(double(len)))[[2]]
        }
        return(result)
    }
}

