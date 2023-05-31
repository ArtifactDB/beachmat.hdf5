#' Initialize HDF5-backed matrices.
#'
#' Initialize C++ representations of HDF5-backed matrices based on their \pkg{HDF5Array} representations.
#'
#' @param x A \pkg{HDF5Array} seed object.
#' @param ... Further arguments, ignored.
#' @param memorize Logical scalar specifying whether to load the matrix data in \code{x} into memory, if it has not already been loaded.
#' See \code{\link{checkMemoryCache}} for details.
#'
#' @return An external pointer that can be used in any \pkg{tatami}-compatible function.
#'
#' @examples
#' library(HDF5Array)
#' y <- matrix(runif(1000), ncol=20, nrow=50)
#' z <- as(y, "HDF5Array")
#' ptr <- initializeCpp(z)
#'
#' @author Aaron Lun
#'
#' @export
#' @importFrom HDF5Array HDF5ArraySeed
#' @name initializeCpp
NULL

#' @export
#' @rdname initializeCpp
#' @import methods
#' @importFrom beachmat initializeCpp
#' @importFrom beachmat checkMemoryCache
#' @importFrom HDF5Array H5SparseMatrixSeed
setMethod("initializeCpp", "H5SparseMatrixSeed", function(x, ..., memorize = FALSE) {
    if (memorize) {
        checkMemoryCache(paste("hdf5-sparse", x@filepath, x@name, sep=":"), function() loadIntoMemory(x))
    } else {
        initialize_from_hdf5_sparse(x@filepath, x@group, nrow=nrow(x), ncol=ncol(x), byrow=is(x, "CSR_H5SparseMatrixSeed"))
    }
})

#' @export
#' @rdname initializeCpp
#' @importFrom HDF5Array HDF5ArraySeed
#' @importFrom beachmat checkMemoryCache
setMethod("initializeCpp", "HDF5ArraySeed", function(x, ..., memorize = FALSE) {
    if (memorize) {
        checkMemoryCache(paste("hdf5-dense", x@filepath, x@name, sep=":"), function() loadIntoMemory(x))
    } else {
        initialize_from_hdf5_dense(x@filepath, x@name)
    }
})
