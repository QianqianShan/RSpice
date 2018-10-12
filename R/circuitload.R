#' Load specified circuit and send it to Ngspice.
#'
#' @param circarray a list of character strings which are used to define
#' @param listing logical; if TRUE, print a listing of the current circuit after
#'                loading.
#' the circuit.
#' @return the same circuit as the one loaded.
#' @examples \dontrun{circuitload(c(".title test", "R1 1 2 5k", "R2 2 0 1k",
#'            "VDD 0 1 DC 10", ".op", ".end"))}
#' @useDynLib RSpice
#' @export
circuitLoad <- function(circarray, listing = TRUE) {
    circarraynull <- c(circarray, "NULL")
    out <- .C("CircuitLoad", as.character(circarraynull), 
        as.integer(length(circarraynull)), 
        as.integer(listing))[[1]]
    invisible(out)
}

