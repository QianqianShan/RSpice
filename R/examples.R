#' @examples  
#' dllpath <- findSpice(); dllpath
#' initializeSpice(dllpath, dllname = paste('libngspice',.Platform$dynlib.ext, sep = '')) 
#' circuitLoad(toyexample)
#' PlotNames<-getPlotNames(); PlotNames
#' data.length<-getLength(); data.length
#' results <- exportResults(4, double(data.length))[[2]];results
#' alterresis <- paste0('alter ', c('r4='), 30, sep = '');alterParameter(alterresis) 
#' runSpice()  
#' unloadSpice()






