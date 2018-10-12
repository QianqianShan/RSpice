#' Command to run Ngspice.

#' @param bgrun logical; indicator of if the simulation is run in main thread 
#'               or background thread. 
#' @useDynLib RSpice
#' @export
runSpice <- function(bgrun = TRUE) {
    res <- .C("RunSpice", as.integer(bgrun))
    invisible(res)
}
