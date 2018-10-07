#' Get the all the plot names after running spice
#' @useDynLib RSpice
#' @export
getPlotNames <- function() {
    length <- .C("GetVectorLength", as.integer(0))[[1]]
    .C("GetPlotNames", as.character(character(length)))
}
