
#' Extract the length of the output.
#'
#' @return an integer showing the length of the ouput and a list of output names.
#' @useDynLib RSpice
#' @export
getLength <- function() {
    .C("GetLength", as.integer(0))[[1]]
}
