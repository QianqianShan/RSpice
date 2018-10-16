#' Load Specified Circui to Ngspice
#'
#' Load specified circuit and send it to Ngspice.
#' @param circarray a list of character strings which are used to define
#' @param listing logical; if TRUE, print a listing of the current circuit after
#'                loading the circuit.
#' @return The outputs from printf, fprintf and fputs of Ngspice simulator. The
#'         listing of the current circuit will be returned if \code{listing = TRUE}.
#' @examples 
#' \dontrun{
#' # Load a simple circtui with name test, the resistor R1 is 5k Ohm and 
#' # connected to node 1 and 2, R2 is 1k Ohm and connected to node 2 and
#' # 0, and a voltage source VDD with 10V between node 0 and 1. A point 
#' # analysis is performed.   
#' circuitload(c('.title test', 'R1 1 2 5k', 'R2 2 0 1k',
#'            'VDD 0 1 DC 10', '.op', '.end'))}
#' @useDynLib RSpice
#' @export
circuitLoad <- function(circarray, listing = TRUE) {
    circarraynull <- c(circarray, "NULL")
    out <- .C("CircuitLoad", as.character(circarraynull), 
        as.integer(length(circarraynull)), as.integer(listing))[[1]]
    invisible(out)
}

