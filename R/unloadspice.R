#' Unload NgSpice
#' 
#' Unload the Ngspice shared library.
#' @useDynLib RSpice
#' @export
unloadSpice <- function() {
    res <- .C("UnloadNgspice")
    invisible(res)
}

