#' Read All Output Names from Ngspice
#' 
#' Read the available output names with their corresponding order from 
#' ngspice after the simulation of a circuit.  
#' 
#' \code{getPlotNames} returns the output names from ngspice after running a 
#'         circuit simulation.
#' @return A data frame with two columns: \code{location} and \code{Name}.
#'         The \code{location} column shows the order of output names 
#'         retuned from Ngspice and the \code{Name} 
#'         column shows the corresponding output names returned from ngspice.
#' @examples 
#' \dontrun{
#' getPlotNames() }
#' @useDynLib RSpice
#' @export
getPlotNames <- function() {
    length <- .C("GetVectorLength", as.integer(0))[[1]]
    if (length == 0) 
        stop("No output from Ngspice.")
    res <- unlist(.C("GetPlotNames", as.character(character(length))))
    # Re-write the names into a data frame for
    # easier check of names and their order
    if (length(res) > 0) {
        Names <- data.frame(c(1:length(res)), 
            res)
        names(Names) <- c("location", "Name")
        return(Names)
    } else {
        stop("Error! No output names from Ngspice.")
    }
}
