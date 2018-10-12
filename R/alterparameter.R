#' Change the device or model parameters of the loaded circuit.
#'
#'Change the device or model parameters of the loaded circuit. See more
#' details on Chapter 17 and 19 on how to alter the parameters in 
#' \url{http://ngspice.sourceforge.net/docs/ngspice-manual.pdf}
#' @param altercmd a vector of parameters which to be sent to Ngspice for
#'                 one time change.
#' @examples \dontrun{alterParameter("alter r1=500")}
#' @useDynLib RSpice
#' @export
alterParameter <- function(altercmd) {
    if (altercmd != tolower(altercmd)) {
        cat("altercmd contains upper case letters, use spiceCommand(\"listing\")
 to check the identifier and parameter names. \n altercmd has been converted
         to only include lower cases. \n")
        altercmd <- tolower(altercmd)
    }
    res <- .C("AlterParameter", as.integer(length(altercmd)), 
        as.character(altercmd))[[]]
    invisible(res)
}
