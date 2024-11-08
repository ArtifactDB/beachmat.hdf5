#' Options for HDF5 matrices
#'
#' Options for initializing HDF5 matrices in \code{\link[beachmat.hdf5]{initializeCpp}}.
#'
#' @param option String specifying the name of the option.
#' @param value Value of the option.
#'
#' @details
#' The following options are supported:
#' \itemize{
#' \item \code{realize}, a logical scalar specifying whether to load the matrix data from HDF5 into memory with \code{\link{loadIntoMemory}},
#' and then cache it for future calls with \code{\link[beachmat]{checkMemoryCache}}. 
#' This avoids time-consuming disk I/O when performing multiple passes through the matrix, at the expense of increased memory usage.
#' \item \code{realize.force.integer}, a logical scalar indicating whether values should be coerced into integers when loading the matrix into memory with \code{\link{loadIntoMemory}}.
#' }
#'
#' @return If \code{value} is missing, the current setting of \code{option} is returned.
#'
#' If \code{value} is supplied, it is used to set the option, and the previous value of the option is invisibly returned.
#'
#' @author Aaron Lun
#' @examples
#' initializeOptions("realize.force.integer")
#' old <- initializeOptions("realize.force.integer", TRUE) # setting to a new value
#' initializeOptions("realize.force.integer") # new option takes affect
#' initializeOptions("realize.force.integer", old) # setting it back
#'
#' @export
#' @name initializeOptions
initializeOptions <- function(option, value) {
    old <- get(option, envir=cached.options, inherits=FALSE)
    if (missing(value)) {
        return(old)
    }
    assign(option, value, envir=cached.options)
    invisible(old)
}

cached.options <- new.env()
cached.options$realize <- FALSE
cached.options$realize.force.integer <- FALSE
