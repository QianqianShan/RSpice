#' Unload NgSpice
#' 
#' Unload the Ngspice shared library.
#' @return A message "Ngspice shared library unloaded." or "Ngspice shared 
#' library already unloaded." dependening on if the \code{unloadSpice()} 
#' function is run for the first time or not.
#' @useDynLib RSpice
#' @export
unloadSpice <- function() {
    res <- .C("UnloadNgspice")
    invisible(res)
}

