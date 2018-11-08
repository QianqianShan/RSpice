#' Load Specified Circuit to Ngspice
#'
#' Initialize Ngspice by linking to its shared library, load the specified
#'  circuit and send the circuit netlist to Ngspice. If the Ngspice shared
#'  library has been linked, only the function will only load the 
#'  specified circuit.  
#' @param circarray a list of character strings which are used to define
#' @param dylibpath the path of the .Ngspice shared library file. 
#' @param dylibname the name of the Ngspice shared library without extensions.
#' @param listing logical; if TRUE, print a listing of the current circuit after
#'                loading the circuit.
#' @return The outputs from printf, fprintf and fputs of Ngspice simulator. The
#'         listing of the current circuit will be returned if \code{listing = TRUE}.
#' @examples 
#' \dontrun{
#' # Load a simple circtui with name test, the resistor R1 is 5k Ohm and 
#' # connected to node 1 and 2, R2 is 1k Ohm and connected to node 2 and
#' # 0, and a voltage source VDD with 10V between node 0 and 1. A point 
#' # analysis is performed.   
#' circuitload(c('.title test', 'R1 1 2 5k', 'R2 2 0 1k',
#'            'VDD 0 1 DC 10', '.op', '.end'))}
#' @useDynLib RSpice
#' @export
circuitLoad <- function(circarray, dylibpath = NULL,
                        dylibname = NULL, listing = TRUE) {
  
  # test if the Ngspice shared library has been loaded 
   load.ind <- .C("TestLibLinkage", as.integer(0))[[1]]
   if (!load.ind) { # if Ngspice is not initialized 
   #  cat("Initialize Ngspice now. \n")
    res <- initializeSpice(dylibpath, dylibname)
   }
  
   
   cat("Ngspice has already been initialized, load circuit now. \n")
    circarraynull <- c(circarray, "NULL")
    out <- .C("CircuitLoad", as.character(circarraynull), 
        as.integer(length(circarraynull)), as.integer(listing))[[1]]
    invisible(out)
}

