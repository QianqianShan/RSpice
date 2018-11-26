#' Load Specified Circuit to Ngspice
#'
#' Initialize ngspice by linking to its shared library, load the specified
#'  circuit and send the circuit netlist to ngspice. If the ngspice shared
#'  library has been linked, only the function will only load the 
#'  specified circuit.  
#' @param circarray a list of character strings which are used to define
#' @param dylibpath the path of the ngspice shared library file. If 
#'                  \code{dylibpath = NULL}, the program will 
#'                  search the default path for the shared library.
#' @param dylibname the name of the ngspice shared library without extensions.
#'                  If \code{dylibpath = NULL}, the program will search the 
#'                  shared library with its default name. 
#' @param listing logical; if TRUE, print a listing of the current circuit after
#'                loading the circuit.
#' @param verbose logical; if TRUE, print the stdout, stderr etc information 
#'                exported from ngspice.
#' @return The outputs from printf, fprintf and fputs of ngspice simulator if 
#'          \code{verbose = TRUE}. The listing of the current circuit will be
#'           returned if \code{listing = TRUE}.
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
                        dylibname = NULL, listing = TRUE, verbose = TRUE) {
  
  # test if the Ngspice shared library has been loaded 
   load.ind <- .C("TestLibLinkage", as.integer(0))[[1]]
   if (!load.ind) { # if Ngspice is not initialized 
   #  cat("Initialize Ngspice now. \n")
     
     # if either the dylibpath or dylibname is NULL, use the default path/name
     if (is.null(dylibpath)) {
       # add default search path 
       if ((.Machine$sizeof.pointer == 8) & (.Platform$dynlib.ext == ".so")) {
         # if 64-bit system with *unix system 
         dylibpath <- "/usr/local/lib"
       } else if ((.Machine$sizeof.pointer == 4) & (.Platform$dynlib.ext == ".so")) {
         dylibpath <- "/usr/local/lib"
       } else if ((.Machine$sizeof.pointer == 8) & (.Platform$dynlib.ext == ".dll")) {
         dylibpath <- "C:/Spice64/bin"
       } else if ((.Machine$sizeof.pointer == 4) & (.Platform$dynlib.ext == ".dll")) {
         dylibpath <- "C:/Spice/bin"
       }
       cat("The default path for Ngspice shared library:",dylibpath,"is searched.\n")
     } 
     
     # the case when dylibname is NULL 
     if (is.null(dylibname)) {
       if ((.Machine$sizeof.pointer == 8) & (.Platform$dynlib.ext == ".so")) {
         # if 64-bit system with *unix system 
         dylibname <- "libngspice"
       } else if ((.Machine$sizeof.pointer == 4) & (.Platform$dynlib.ext == ".so")) {
         dylibname <- "libngspice"
       } else if ((.Machine$sizeof.pointer == 8) & (.Platform$dynlib.ext == ".dll")) {
         dylibname <- "libngspice-0"
       } else if ((.Machine$sizeof.pointer == 4) & (.Platform$dynlib.ext == ".dll")) {
         dylibname <- "libngspice-0"
       } 
       cat("The default dylibname for ngspice shared library",dylibname,"is searched.\n")
       
     }
    res <- initializeSpice(dylibpath, dylibname, verbose)
   }
   cat("Ngspice has already been initialized, load circuit now. \n")
    circarraynull <- c(circarray, "NULL")
    if(verbose) {
      invisible(out <- .C("CircuitLoad", as.character(circarraynull), 
                          as.integer(length(circarraynull)), as.integer(listing))[[1]])
    } else {
      out <- utils::capture.output(.C("CircuitLoad", as.character(circarraynull), 
                          as.integer(length(circarraynull)), as.integer(listing))[[1]])
      if (listing == TRUE) {
        spiceCommand("listing")
      }
    }
  #  cat("Circuit is loaded successfully.\n")

  #  invisible(out)
}

