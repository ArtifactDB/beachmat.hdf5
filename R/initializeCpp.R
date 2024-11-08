#' Initialize HDF5-backed matrices.
#'
#' Initialize C++ representations of HDF5-backed matrices based on their \pkg{HDF5Array} representations.
#'
#' @param x A \pkg{HDF5Array} seed object.
#' @param hdf5.cache.size Integer scalar specifying the size of the cache in bytes during data extraction from a HDF5 matrix.
#' Larger values reduce disk I/O during random access to the matrix, at the cost of increased memory usage.
#' @param hdf5.realize See the \code{realize} option in \code{\link{initializeOptions}}.
#' @param memorize Deprecated, use \code{hdf5.realize} instead.
#' @param hdf5.realize.force.integer See the \code{force.integer} option in \code{\link{initializeOptions}}.
#' @param ... Further arguments, ignored.
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
setMethod("initializeCpp", "H5SparseMatrixSeed", function(
    x,
    ...,
    hdf5.cache.size = getAutoBlockSize(),
    hdf5.realize = initializeOptions("realize"), 
    memorize = hdf5.realize, 
    hdf5.realize.force.integer = initializeOptions("realize.force.integer"))
{
    if (memorize) {
        checkMemoryCache("beachmat.hdf5", paste("sparse", x@filepath, x@group, sep=":"), function() loadIntoMemory(x, force.integer=hdf5.realize.force.integer))
    } else {
        initialize_from_hdf5_sparse(x@filepath, x@group, nrow=nrow(x), ncol=ncol(x), csr=is(x, "CSR_H5SparseMatrixSeed"), cache_size=hdf5.cache.size)
    }
})

#' @export
#' @rdname initializeCpp
#' @importFrom HDF5Array HDF5ArraySeed
#' @importFrom beachmat checkMemoryCache
setMethod("initializeCpp", "HDF5ArraySeed", function(
    x,
    ...,
    hdf5.cache.size = getAutoBlockSize(),
    hdf5.realize = initializeOptions("realize"),
    memorize = hdf5.realize,
    hdf5.realize.force.integer = initializeOptions("realize.force.integer"))
{
    if (memorize) {
        checkMemoryCache("beachmat.hdf5", paste("dense", x@filepath, x@name, sep=":"), function() loadIntoMemory(x, force.integer=hdf5.realize.force.integer))
    } else {
        initialize_from_hdf5_dense(x@filepath, x@name, transpose=TRUE, cache_size=hdf5.cache.size)
    }
})
