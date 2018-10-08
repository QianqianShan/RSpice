#' Initialize NgSpice.
#' @param dllpath the path of the dll/so shared library file
#' @param dllname the name of the shared library without extensions 
#' @useDynLib RSpice
#' @export
#'
initializeSpice <- function(dllpath, dllname) {
    if (is.null(dllpath)) {
        dllrawpath <- character(0)
    } else {
      # check if the the .so/.dll file exist in the given path 
      if(!file.exists(paste0(dllpath, .Platform$file.sep,dllname))) {
        stop("The Ngspice shared object is not found in the specified path.")
      }
      
        dllrawpath <- c(charToRaw(dllpath), 
            as.raw(0))
    }
    dllraw <- c(charToRaw(dllname), as.raw(0))
    initial <- .C("InitializeSpice", dllrawpath, 
        dllraw)
}
