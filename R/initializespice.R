#' Initialize NgSpice.
#' @param dllpath the path of the dll/so shared library file
#' @param dllname the name of the shared library without extension 
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
