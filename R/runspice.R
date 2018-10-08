#' Command to run Spice.

#' @useDynLib RSpice
#' @export
runSpice <- function() {
   res<- .C("RunSpice")
   invisible(res)
}
