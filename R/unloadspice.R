
#' unload NgSpice
#' @useDynLib RSpice
#' @export
unloadSpice <- function() {
    .C("UnloadNgspice")
}

