#' Change the device or model parameters of the loaded circuit.
#'
#'#Change the device or model parameters of the loaded circuit. See more
#' details on Chapter 17 and 19 on how to alter the parameters in 
#' \url{http://ngspice.sourceforge.net/docs/ngspice-manual.pdf}
#' @param cmd a vector of commands which to be sent to Ngspice for
#'                 one time change.
#' @examples \dontrun{spiceCommand("listing")}                 
#' @useDynLib RSpice
#' @export
spiceCommand <- function(cmd) {
    res <- .C("SpiceCommand", as.integer(length(cmd)), 
        as.character(cmd))[[]]
    invisible(res)
}
