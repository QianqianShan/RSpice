#' Extract the Length of the Output
#'
#'Extract the length of the output from Ngspice.
#' @return An integer showing the length of the ouput after running a 
#'         simulation of a circuit in ngspice.
#' @useDynLib RSpice
#' 
#' @examples 
#' \dontrun{
#' getLength()
#' }
#' 
#' @export
getLength <- function() {
    .C("GetLength", as.integer(0))[[1]]
}
