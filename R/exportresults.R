#' Export the Output Values from Ngspice
#'
#'
#'Export the specified output values from Ngspice.
#'
#' @param location a vector of the location(s) of the outputs we want to export,
#'  i.e. the location-th output from the \code{getPlotNames()}.
#' @examples 
#' \dontrun{
#' # obtain the location and Name information by running getPlotNames()
#' getPlotNames()
#' # Export the output values for location 1, 2 and 4. 
#' exportResults(c(1, 2, 4))
#' }
#' @return A matrix containing the output values with the ouputs for each 
#'         location stored in one row. The number of rows of the
#'         matrix equals \code{length(location)} and the number of columns
#'         equals the length of each output value.   
#' @useDynLib RSpice
#' @export
exportResults <- function(location) {
    if (any(location <= 0)) {
        stop("location argument must be positive integers.")
    }
    loclen <- nrow(getPlotNames())
    len <- getLength()
    if (max(location) > loclen) {
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

