#' Initialize Ngspice.
#' 
#' @param dylibpath the path of the .dll/.so Ngspice shared library file
#' @param dylibname the name of the shared library without extensions 
#' @useDynLib RSpice
#' @examples
#' \dontrun{initializeSpice(findSpice(), 'libngspice.so')}
#' @export
#'
initializeSpice <- function(dylibpath, dylibname) {
    if (is.null(dylibpath)) {
        dllrawpath <- character(0)
    } else {
        # check if the the .so/.dll file exists in
        # the given path
        if (!file.exists(paste0(dylibpath, 
            .Platform$file.sep, dylibname))) {
            stop("The Ngspice shared object is not found in the specified path.")
        }
        
        dllrawpath <- c(charToRaw(dylibpath), 
            as.raw(0))
    }
    dllraw <- c(charToRaw(dylibname), as.raw(0))
    initial <- .C("InitializeSpice", dllrawpath, 
        dllraw)
}
