% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/runspice.R
\name{runSpice}
\alias{runSpice}
\title{Send Command to Ngspice to Run the Circuit Simulation}
\usage{
runSpice(bgrun = FALSE, verbose = FALSE)
}
\arguments{
\item{bgrun}{logical; indicator of if the simulation is run in main thread 
or background thread.}

\item{verbose}{logical; if TRUE, print the stdout, stderr etc information 
exported from ngspice.}
}
\value{
Simulation status obtained from Ngspice is printed.
}
\description{
Send command to ngspice to run the simulation of the circuit.
}
\examples{
\dontrun{

# Run the simulation in main thread
runSpice()

# Run the simulation in background thread 
runSpice() 
} 
}
