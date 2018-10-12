#' unload NgSpice
#' @useDynLib RSpice
#' @export
unloadSpice <- function() {
    res <- .C("UnloadNgspice")
    invisible(res)
}

