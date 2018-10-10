#' Function to find if shared Ngspice library exists and return the path if Yes.
#'
#' @return The function will stop if no shared library were found, and the first
#'         available file path containing the shared library will be returned.
#' @export

findSpice <- function() {
    if (.Platform$OS.type == "unix") {
        # temp.name <- paste('temp.name',
        # as.character(Sys.Date()), sep = '')
        system(paste("find ~/ -name libngspice.so 1> temp.name"))
        file.paths <- readLines(con = "temp.name")
        cat(paste("\n Shared library exists in the following directories, the first directory
          is used. \n"))
        print(file.paths)
        system("rm temp.name")
        if (length(file.paths) == 0) {
            stop("Please compile the Ngspice shared library first. ")
        } else {
            return(dirname(file.paths[1]))
        }
    } else {
        # windows case find the dll file in
        # Windows
        system(paste0("cmd.exe /c dir /b/s ngspice.dll 1> temp.name"))
        file.paths <- readLines(con = "temp.name")
        if (length(file.paths) == 0) {
            stop("Shared library not found in the current working directory. ")
        } else {
            return(dirname(file.paths[1]))
        }
    }
}
