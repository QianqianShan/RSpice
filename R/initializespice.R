#' Initialize Ngspice
#' 
#' Load the ngspice shared library and initialize Ngspice with the exported
#'  functions. See Chapter 19 of the ngspice manual for more details.
#' 
#' @param dylibpath the path of the ngspice shared library file. 
#' @param dylibname the name of the ngspice shared library without extensions
#'                  such as .so or .dll. 
#' @param
#' @return NULL.
#' @useDynLib RSpice
#' @examples
#' \dontrun{
#' # Initialize Ngspice.
#' initializeSpice(dylibpath = "/usr/local/bin", dylibname = 'libngspice')}
#' @export

initializeSpice <- function(dylibpath, dylibname, verbose) {
  # cat("Finding", paste0(dylibname,.Platform$dynlib.ext) ,"now ...\n")
  if (.Platform$OS.type == "unix") {
    # cat("The default path for Ngspice shared library is: \n /usr/local/lib\n")
    if (grep("64", R.Version()$arch)) {
      cat("Your are using 64-bit R version, please make sure your Ngspice shared library is 64-bit too.\n")
    } else {
      cat("Your are using 32-bit R version, please make sure your Ngspice shared library is 32-bit too.\n")
    }
    cat("Searching for standard configuration file, spinit, at /usr/local/share/ngspice/scripts...\n ")
    if (!file.exists("/usr/local/share/ngspice/scripts/spinit")) {
      cat("\"spinit\" is not found in the default path. \n")
      # cat("Ignore the warning message \"can't find init file\" 
      #     if XSPICE is not used within ngspice.\n")
    }
    
    cat("Searching default path for the code models for XSPICE at /usr/local/lib/ngspice...\n")
   if (!file.exists("/usr/local/lib/ngspice/table.cm")) {
     cat("Code models (*.cm files) are not found in the default path.\n")
   }
    
  } else { # operating systems other than *unix 
    if (grep("64", R.Version()$arch)) {
      cat("Your are using 64-bit R version, please make sure your Ngspice shared library is 64-bit too.\n")
      cat("Searching for standard configuration file, spinit at C:/Spice64/share/ngspice/scripts ...\n ")
      if (!file.exists("C:/Spice64/share/ngspice/scripts/spinit")) {
        cat("\"spinit\" is not found in the default path. \n")
        # cat("Ignore the warning message \"can't find init file\" 
        #     if XSPICE is not used within ngspice.\n")
      }
      
      cat("Searching default path for the code models for XSPICE at C:/Spice64/lib/ngspice...\n")
      if (!file.exists("C:/Spice64/share/ngspice/table.cm")) {
        cat("Code models (*.cm files) are not found in the default path.\n")
        # cat("Ignore the warning message \"can't find init file\" 
        #     if XSPICE is not used within ngspice.\n")
      }

        } else {
      cat("Your are using 32-bit R version, please make sure your Ngspice shared library is 32-bit too.\n")
      cat("Searching for standard configuration file, spinit, at C:/Spice/share/ngspice/scripts ...\n ")
          if (!file.exists("C:/Spice/share/ngspice/scripts/spinit")) {
            cat("\"spinit\" is not found in the default path. \n")
            # cat("Ignore the warning message \"can't find init file\" 
            #     if XSPICE is not used within ngspice.\n")
          }
          
          cat("Searching default path for the code models for XSPICE at C:/Spice/lib/ngspice...\n")
          if (!file.exists("C:/Spice64/share/ngspice/table.cm")) {
            cat("Code models (*.cm files) are not found in the default path.\n")
            # cat("Ignore the warning message \"can't find init file\" 
            #     if XSPICE is not used within ngspice.\n")
          }
        }
  }
    
    # search the subdirectories of dylibpath if the shared library is not found
    # in the current dylibpath
  # add the correct file extension to dylibname 
  
# add the corect shared library extension if not added yet   
  if ((length(grep(".so$", dylibname)) == 0) | (length(grep(".dll$", dylibname)) == 0)) {
    dylibname = paste0(dylibname,.Platform$dynlib.ext)
  }
  
  # dylibname = paste0(dylibname,.Platform$dynlib.ext)
    if (!file.exists(paste0(dylibpath, .Platform$file.sep, dylibname))) {
      dylibpath <-  findSpice(dylibpath, dylibname)
    }
  


    cat("Initializing ngspice now...\n")
    
    # make sure there is no path separator at the end
    dylibpath <- gsub(paste0(.Platform$file.sep, "$"), "", dylibpath)
    # add the path separator, and make sure that it only shows up once
    dylibpath <- paste0(dylibpath, .Platform$file.sep)
    
    # replace the possible \\ or separator with / 
    if (.Platform$dynlib.ext == ".dll") {
      dylibpath <- gsub("/","\\\\", dylibpath)
      dylibpath <- gsub("/", "\\", dylibpath)
    }
    
    # make sure the shared object exists in the specified path with specified name
    if (!file.exists(paste0(dylibpath, .Platform$file.sep, 
                            dylibname))) {
      stop(cat("The specified Ngspice shared library", dylibname,
               "is not found in the specified path", dyllibpath,".\n"))
    }
    
    # send the dylibpath and dylibname info to C
    dllrawpath <- c(charToRaw(dylibpath), 
                    as.raw(0))
  
  dllraw <- c(charToRaw(dylibname), as.raw(0))
  if (verbose) {
    initial <- .C("InitializeSpice", dllrawpath, 
                  dllraw)
  } else {
    initial <- .C("InitializeSpice", dllrawpath, 
                  dllraw)
  }

  invisible(initial)
}
