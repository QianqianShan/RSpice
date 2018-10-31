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
  cat("Finding", paste0(dylibname,.Platform$dynlib.ext) ,"now ...\n")
  if (.Platform$OS.type == "unix") {
    cat("The default directory for standard configuration file, spinit, is:\n")
    cat("/usr/local/share/ngspice/scripts \n")
    
    cat("The default directory for the code models for XSPICE is:\n")
    cat("/usr/local/lib/ngspice/ \n")
    cat("Ignore the warning message \"can't find init file\" if XSPICE is not used.\n")
  } else {
    cat("The default directory for standard configuration file, spinit, is:\n")
    cat("C:/Spice/share/ngspice/scripts for 32-bit system \n")
    cat("C:/Spice64/share/ngspice/scripts for 64-bit system \n")
    
    
    cat("The default directory for Ngspice shared library is in:\n")
    cat("C:/Spice/bin for 32-bit system \n")
    cat("C:/Spice64/bin for 64-bit system \n")
    
    cat("The default directory for the code models for XSPICE is:\n")
    cat("C:/Spice/lib/ngspice for 32-bit system \n")
    cat("C:/Spice64/lib/ngspice for 64-bit system \n")
    cat("Ignore the warning message when initializing Ngspice \"can't find init file\" if XSPICE is not used.\n")
    
  }
  
  cat("Check if spinit, *.cm exist and the dylibname is correct before proceeding.\n")
  # update the dlllibpath 
  dylibpath <-  findSpice(dylibpath, dylibname)
  # add the correct extension 
  dylibname = paste0(dylibname, .Platform$dynlib.ext)
  
  if (is.null(dylibpath)) {
    # dllrawpath <- character(0)
    stop("Please specify the Ngspice shared library path.")
  } else {
    # check if the the .so/.dll file exists in the
    # given path
    cat("Initializing ", dylibname, "now...\n")
    
    # make sure there is no path separator at the end
    dylibpath <- gsub(paste0(.Platform$file.sep, "$"), "", dylibpath)
    # add the path separator, and make sure that it only shows up once
    dylibpath <- paste0(dylibpath, .Platform$file.sep)
    
    
    if (.Platform$dynlib.ext == ".dll") {
      dylibpath <- gsub("/","\\\\", dylibpath)
    }
    
    
    if (!file.exists(paste0(dylibpath, .Platform$file.sep, 
                            dylibname))) {
      stop("The specified Ngspice shared object is not found in the specified path.")
    }
    
    dllrawpath <- c(charToRaw(dylibpath), 
                    as.raw(0))
  }
  dllraw <- c(charToRaw(dylibname), as.raw(0))
  initial <- .C("InitializeSpice", dllrawpath, 
                dllraw)
  invisible(initial)
}
