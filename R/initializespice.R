#' Initialize Ngspice
#' 
#' Load the Ngspice shared library and initialize Ngspice with the exported
#'  functions. See Chapter 19 of the Ngspice manual for more details.
#' 
#' @param dylibpath the path of the .Ngspice shared library file. 
#' @param dylibname the name of the Ngspice shared library without extensions. 
#' @return NULL.
#' @useDynLib RSpice
#' @examples
#' \dontrun{
#' # Initialize Ngspice.
#' initializeSpice(dylibpath = findSpice(), dylibname = 'libngspice.so')}
#' @export
initializeSpice <- function(dylibpath, dylibname) {
    dylibname = paste0(dylibname, .Platform$dynlib.ext)
    if (is.null(dylibpath)) {
        # dllrawpath <- character(0)
        stop("Please specify the Ngspice shared library path.")
    } else {
        # check if the the .so/.dll file exists in the
        # given path
        cat("Initialize ", dylibname, "now...\n")
        
        dylibpath <- gsub("/$", "", dylibpath)
        if (!file.exists(paste0(dylibpath, .Platform$file.sep, 
            dylibname))) {
            stop("The Ngspice shared object is not found in the specified path.")
        }
        
        dllrawpath <- c(charToRaw(dylibpath), 
            as.raw(0))
    }
    dllraw <- c(charToRaw(dylibname), as.raw(0))
    initial <- .C("InitializeSpice", dllrawpath, 
        dllraw)[[]]
    invisible(initial)
}
