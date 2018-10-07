#' Change the parameters in the previously loaded circuit.
#'
#' @param nalter the total number of times we want to alter the parameter(s).
#' @param parameter a list of parameters which will be sent to Spice for
#' one time's change.
#' @return 1. 'Alter command sent to ngspice' if the parameters are altered
#'successfully; 2. the values of nalter and paramters we sent down.
# #' @examples #'
# alterparameter(2,as.character('alter
# c1=2','alter r1=2'))
#' @useDynLib RSpice
#' @export
alterParameter <- function(nalter, parameter) {
    .C("AlterParameter", as.integer(nalter), 
        as.character(parameter))
}
