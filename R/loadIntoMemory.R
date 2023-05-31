#' Load a HDF5 matrix into memory
#'
#' Load a HDF5-backed matrix into memory as an external pointer to a \pkg{tatami}-compatible representation.
#' This differs from the (default) behavior of \code{\link{initializeCpp}}, which only loads slices of the matrix on request.
#'
#' @param x A \pkg{HDF5Array}-derived matrix or seed object.
#' @param force.integer Whether to force floating-point values to be integers to reduce memory consumption.
#' 
#' @return An external pointer that can be used in \pkg{tatami}-based functions.
#'
#' @author Aaron Lun
#' @examples
#' library(HDF5Array)
#' y <- matrix(runif(1000), ncol=20, nrow=50)
#' z <- as(y, "HDF5Array")
#' ptr <- loadIntoMemory(z)
#'
#' @export
#' @import methods
#' @importFrom HDF5Array HDF5ArraySeed
#' @importFrom HDF5Array H5SparseMatrixSeed
#' @importFrom DelayedArray getAutoBlockSize
loadIntoMemory <- function(x, force.integer=FALSE) {
    if (is(x, "DelayedArray")) {
        x <- x@seed
    }

    # Can't be bothered to set up a generic just for this.
    if (is(x, "HDF5ArraySeed")) {
        if (x@sparse) {
            load_into_memory_dense_as_sparse(x@filepath, x@name, forced_int=force.integer, byrow=FALSE, cache_size=getAutoBlockSize())
        } else {
            load_into_memory_dense(x@filepath, x@name, forced_int=force.integer)
        }
    } else if (is(x, "H5SparseMatrixSeed")) {
        load_into_memory_sparse(x@filepath, x@name, nrow=nrow(x), ncol=ncol(x), byrow=is(x, "CSR_H5SparseMatrixSeed"), forced_int=force.integer)
    } else {
        stop("unsupported seed type '", class(x)[1], "'")
    }
}
