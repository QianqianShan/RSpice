#' Command to run Spice.

#' @useDynLib RSpice
#' @export
runSpice<-function(){
  .C("RunSpice")
}
