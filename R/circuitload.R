#' Load specified circuit and send it to Spice.
#'
#' @param circarray a list of character strings which are used to define
#' the circuit.
#' @return the same circuit as the one loaded.
# #' @examples #' circuitload(circarray)
#' @useDynLib RSpice
#' @export
circuitLoad <- function(circarray) {
    circarraynull <- c(circarray, "NULL")
    out <- .C("CircuitLoad", as.character(circarraynull), 
        as.integer(length(circarraynull)))
}

