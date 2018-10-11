#' Function to find if shared Ngspice library exists and return the path if Yes.
#'
#' @param dylibpath the path of the Ngspice shared library. 
#' @param dylibname the name of the Ngspice shared library.  
#' @return The function will stop if no shared library were found, and the first
#'         available file path containing the shared library will be returned.
#' @export

findSpice <- function(dylibpath, dylibname) {
    if (.Platform$OS.type == "unix") {
        # temp.name <- paste('temp.name',
        # as.character(Sys.Date()), sep = '')
        if (is.null(dylibpath)) {
            # search across all directories to look for
            # the shared object
            file.paths <- system(paste0("find ~/ -name ", 
                dylibname), intern = TRUE)
            
        } else {
            if (dir.exists(dylibpath)) {
                file.paths <- system(paste0("find ", 
                  sub("/$", "", dylibpath), 
                  .Platform$file.sep, " -name ", 
                  dylibname), intern = TRUE)
            } else {
                stop("Dylibpath doesn't exist. Please enter a valid dylibpath.")
            }
        }
        # file.paths <- readLines(con =
        # 'temp.name')
        cat(paste("\n Shared library exists in the following directories, the first directory
          is used. \n"))
        print(file.paths)
        if (length(file.paths) == 0) {
            stop("Shared library of Ngspice not found.  ")
        } else {
            return(dirname(file.paths[1]))
        }
    } else {
        # windows, find the shared object dll file
        if (is.null(dylibpath)) {
            file.paths <- system(paste0("cmd.exe /c dir /b/s", 
                dylibname), intern = TRUE)
        } else {
            if (dir.exists(dylibpath)) {
                file.paths <- system(paste0("find ", 
                  sub("/$", "", dylibpath), 
                  .Platform$file.sep, " -name ", 
                  dylibname), intern = TRUE)
            } else {
                stop("Dylibpath doesn't exist. Please enter a valid dylibpath.")
            }
            # file.paths <- system(paste0('cmd.exe /c
            # dir /b/s ', sub('/$', '' ,dylibpath) ,
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
