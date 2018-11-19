#' Send Command to Ngspice
#'
#' Send a valid command from caller to ngspice. See more control or interactive
#'  commands details in
#' \url{http://ngspice.sourceforge.net/docs/ngspice-manual.pdf}
#' @param cmd a vector of commands which to be sent to ngspice for
#'                 one time change.
#' @examples 
#' \dontrun{
#' 
#' # to print a listing of the current circuit
#' 
#' spiceCommand("listing")
#' }                 
#' @useDynLib RSpice
#' @export
spiceCommand <- function(cmd) {
    if (cmd != tolower(cmd)) {
        cat("cmd contains upper case letters, use spiceCommand(\"listing\") to check the identifier and parameter names. \n altercmd has been converted to only include lower cases. \n")
        cmd <- tolower(cmd)
    }
    res <- .C("SpiceCommand", as.integer(length(cmd)), 
        as.character(cmd))[[2]]
    invisible(res)
}
