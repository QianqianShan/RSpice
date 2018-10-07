#' Initialize NgSpice.
#' @return A character string saying "ngspice loaded".
#' @useDynLib RSpice
#' @export
#'
initializeSpice <- function(dllpath, dllname) {
  if (is.null(dllpath)) {
    dllrawpath <- character(0)
  } else {
    dllrawpath <- c(charToRaw(dllpath),as.raw(0))
  }
  dllraw <- c(charToRaw(dllname),as.raw(0))
  initial <- .C("InitializeSpice",dllrawpath,dllraw)
}
