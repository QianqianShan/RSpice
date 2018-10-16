
#' Extract the length of the output.
#'
#' @return An integer showing the length of the ouput after running a 
#'         simulation of a circuit in Ngspice.
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
