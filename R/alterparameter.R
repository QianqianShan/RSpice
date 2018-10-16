#' Change a Device or Model Parameter
#'
#' Change the device or model parameter of the loaded circuit. See more
#' details on Chapter 17 and 19 on how to alter the parameters in 
#' \url{http://ngspice.sourceforge.net/docs/ngspice-manual.pdf}.
#' @param altercmd a vector of parameters which to be sent to Ngspice for
#'                 one time change.
#' @examples
#'  \dontrun{
#'  # alter the resistance to 500 Ohm for a resistor device r1.  
#'  alterParameter('alter r1=500')}
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
