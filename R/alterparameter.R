#' Change the device or model parameters of the loaded circuit.
#'
#'#Change the device or model parameters of the loaded circuit. See more
#' details on Chapter 17 and 19 on how to alter the parameters in 
#' \url{http://ngspice.sourceforge.net/docs/ngspice-manual.pdf}
#' @param altercmd a vector of parameters which to be sent to Ngspice for
#'                 one time change.
#' @return 1. 'Alter command sent to ngspice' if the parameters are altered
#'successfully; 2. paramters we sent down.
# #' @examples #'
# alterparameter(2,as.character('alter
# c1=2','alter r1=2'))
#' @useDynLib RSpice
#' @export
alterParameter <- function(altercmd) {
   res<-  .C("AlterParameter", as.integer(length(altercmd)), 
        as.character(altercmd))[[]]
   invisible(res)
}
