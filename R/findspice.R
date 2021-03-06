#' Find The Path of The Ngspice Shared Library
#'
#' Find if the specified Ngspice shared library exists and return the first
#'  path if there the shared library exists in multiple paths.
#'
#' @param dylibpath a character string with the general path of the Ngspice shared library. If NULL, the 
#'        function will search across the computer, which is not 
#'        recommended as it may search some directories that requires
#'        root/admin authorization. If a path is specified, the search will be 
#'        conducted under the path recursively with a faster speed.  
#' @param dylibname a character string with the name of the Ngspice shared library. 
#' @return The function will stop if no shared library is found, and the first
#'         available file path containing the shared library will be returned.
#' @examples 
#' \dontrun{
#'  # under windows os
#'   findSpice(dylibpath = 'C:/Users/bin', dylibname = 'ngspice.so')
#'  # under *unix os
#'  findSpice(dylibpath = '/usr/local/lib', dylibname = 'libngspice.so')}
#'  
#' @export

findSpice <- function(dylibpath, dylibname) {
  if ((length(grep(".so$", dylibname)) == 0) | (length(grep(".dll$", dylibname)) == 0)) {
    dylibname = paste0(dylibname,.Platform$dynlib.ext)
  }
  
    if (.Platform$OS.type == "unix") {

        if (is.null(dylibpath)) {
            # search across all directories to look for
            # the shared object
            file.paths <- system(paste0("find ~/ -name ", 
                dylibname), 
                intern = TRUE)
            
        } else {
            if (dir.exists(dylibpath)) {
                file.paths <- system(paste0("find ", 
                  sub("/$", "", dylibpath), .Platform$file.sep, 
                  " -name ", dylibname), 
                  intern = TRUE)
            } else {
                stop("dylibpath doesn not exist. Please enter a valid dylibpath.")
            }
        }
        # file.paths <- readLines(con = 'temp.name')
        cat(paste("\n Shared library exists in the following directories, the first is used. \n"))
        print(file.paths)
        if (length(file.paths) == 0) {
            stop("Shared library of Ngspice not found.  ")
        } else {
            return(dirname(file.paths[1]))
        }
    } else {
        # windows, find the shared object dll file
        if (is.null(dylibpath)) {
            file.paths <- system(paste0("cmd.exe /c dir /b/s ", 
                dylibname), 
                intern = TRUE)
        } else {
            if (dir.exists(dylibpath)) {
                # file.paths <- system(paste0('cmd.exe /c
                # where /r ', dylibpath, ' ', dylibname))
                cat("Search path", dylibpath, 
                  "for the Ngspice shared library.\n")
                if (length(grep("/", dylibpath)) > 0) {
                  # dylibpath <- grep("/", "\\\\", 
                  #   dylibpath)
                  # remove the last / if there is any 
                  dylibpath <- gsub("/$", "", 
                    dylibpath)
                  # replace all other / with \ if there are any 
                  dylibpath <- gsub("/", "\\\\", dylibpath)
                }
                
              # run windows command line to search the accruate directory
                file.paths <- system(paste0("cmd.exe /c dir ", 
                  "\"", dylibpath, "\\", dylibname, 
                   "\"", " /b /s"), intern = TRUE)
            } else {
                stop("Dylibpath doesn't exist. Please enter a valid dylibpath.")
            }
            # file.paths <- system(paste0('cmd.exe /c dir
            # /b/s ', sub('/$', '' ,dylibpath) ,
            # .Platform$file.sep,dylibname), intern =
            # TRUE)
            cat(paste("\n Shared library exists in the following directories, the first directory
                is used. \n"))
            print(file.paths)
        }
        if (length(file.paths) == 0) {
            stop("Shared library of Ngspice not found. ")
        } else {
            return(dirname(file.paths[1]))
        }
    }
}
