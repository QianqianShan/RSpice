#' Send Command to Ngspice to Run the Circuit Simulation 
#' 
#' Send command to ngspice to run the simulation of the circuit.
#' @param bgrun logical; indicator of if the simulation is run in main thread 
#'               or background thread. 
#' @param verbose logical; if TRUE, print the stdout, stderr etc information 
#'                exported from ngspice.
#' @return Simulation status obtained from Ngspice is printed.
#' @examples 
#' \dontrun{
#' 
#' # Run the simulation in main thread
#' runSpice()
#' 
#' # Run the simulation in background thread 
#' runSpice() 
#' } 
#' @useDynLib RSpice
#' @export
runSpice <- function(bgrun = FALSE, verbose = FALSE) {
  #  invisible(res <- .C("RunSpice", as.integer(bgrun)))
   # invisible(res)
  if (!verbose) {
    out <-  utils::capture.output(.C("RunSpice", as.integer(bgrun)))
  } else {
    out <- .C("RunSpice", as.integer(bgrun))
  }
}
