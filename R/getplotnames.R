#' Get the all the output names 
#' 
#' \code{getPlotNames} returns the ouput names from Ngspice after running a 
#'         circuit simulation.
#' @return A data fram with two columns: location and Name. The location column
#'         shows the order of output names obtained from Ngspice and the Name 
#'         column shows the corresponding output names returned from Ngspice.
#' @useDynLib RSpice
#' @export
getPlotNames <- function() {
    length <- .C("GetVectorLength", as.integer(0))[[1]]
    res <- unlist(.C("GetPlotNames", as.character(character(length))))
    # Re-write the names into a data frame for
    # easier check of names and their order
    Names <- data.frame(c(1:length(res)), res)
    names(Names) <- c("location", "Name")
    return(Names)
}
