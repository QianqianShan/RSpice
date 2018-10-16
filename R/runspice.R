#' Run Ngspice.

#' @param bgrun logical; indicator of if the simulation is run in main thread 
#'               or background thread. 
#' @return Simulation status obtained from Ngspice is printed.
#' @examples 
#' \dontrun{
#' # Run the simulation in main thread
#' runSpice()
#' 
#' # Run the simulation in background thread 
#' runSpice(bgrun = TRUE) 
#' } 
#' @useDynLib RSpice
#' @export
runSpice <- function(bgrun = TRUE) {
    res <- .C("RunSpice", as.integer(bgrun))
    invisible(res)
}
