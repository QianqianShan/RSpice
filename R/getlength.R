
#' Extract the length of the output.
#'
#' @return An integer showing the length of the ouput after running a 
#'         simulation on a circuit in Ngspice.
#' @useDynLib RSpice
#' @export
getLength <- function() {
    .C("GetLength", as.integer(0))[[1]]
}
