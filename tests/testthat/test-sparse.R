# This tests the functions with respect to dense arrays.
# library(testthat); library(beachmat.hdf5); source("test-sparse.R")

library(Matrix)
library(HDF5Array)
y <- Matrix::rsparsematrix(50, 20, 0.1)
z <- suppressWarnings(writeTENxMatrix(y))

test_that("initialization works correctly for sparse HDF5 arrays", {
    ptr <- initializeCpp(z)
    expect_identical(beachmat:::tatami_dim(ptr), dim(y))
    expect_identical(beachmat:::tatami_row(ptr, 31), y[31,])
    expect_identical(beachmat:::tatami_column(ptr, 12), y[,12])

    expect_identical(beachmat:::tatami_row_sums(ptr, 2), Matrix::rowSums(y))
    expect_identical(beachmat:::tatami_column_sums(ptr, 2), Matrix::colSums(y))
})

test_that("memorization works correctly for sparse HDF5 arrays", {
    ptr1 <- initializeCpp(z, hdf5.realize=TRUE)
    ptr2 <- initializeCpp(z, hdf5.realize=TRUE)
    expect_identical(capture.output(print(ptr1)), capture.output(print(ptr2)))

    expect_identical(beachmat:::tatami_row(ptr1, 35), y[35,])
    expect_identical(beachmat:::tatami_column(ptr1, 16), y[,16])

    expect_identical(beachmat:::tatami_row(ptr2, 45), y[45,])
    expect_identical(beachmat:::tatami_column(ptr2, 6), y[,6])
})

# Manually writing this to get an integer dataset.
library(Matrix)
y2 <- abs(round(y * 1000))

library(rhdf5)
temp <- tempfile(fileext=".h5")
h5createFile(temp)
h5createGroup(temp, "foo")
h5write(as.integer(y2@x), temp, "foo/data")
h5write(y2@i, temp, "foo/indices")
h5write(y2@p, temp, "foo/indptr")
z <- DelayedArray(H5SparseMatrixSeed(temp, "foo", dim=dim(y2), sparse.layout="CSC"))

test_that("memorization works correctly for sparse integer HDF5 arrays", {
    ptr1 <- initializeCpp(z, hdf5.realize=TRUE)
    ptr2 <- initializeCpp(z, hdf5.realize=TRUE)
    expect_identical(capture.output(print(ptr1)), capture.output(print(ptr2)))

    expect_equal(beachmat:::tatami_row(ptr1, 35), y2[35,])
    expect_equal(beachmat:::tatami_column(ptr1, 16), y2[,16])

    expect_equal(beachmat:::tatami_row(ptr2, 35), y2[35,])
    expect_equal(beachmat:::tatami_column(ptr2, 16), y2[,16])
})

library(rhdf5)
temp <- tempfile(fileext=".h5")
h5createFile(temp)
h5createGroup(temp, "foo")
h5createDataset(temp, "foo/data", dims=length(y2@x), H5type="H5T_NATIVE_UINT16")
h5write(as.integer(y2@x), temp, "foo/data")
h5write(y2@i, temp, "foo/indices")
h5write(y2@p, temp, "foo/indptr")
z <- DelayedArray(H5SparseMatrixSeed(temp, "foo", dim=dim(y2), sparse.layout="CSC"))

test_that("memorization works correctly for sparse small integer HDF5 arrays", {
    ptr1 <- initializeCpp(z, hdf5.realize=TRUE)
    ptr2 <- initializeCpp(z, hdf5.realize=TRUE)
    expect_identical(capture.output(print(ptr1)), capture.output(print(ptr2)))

    expect_equal(beachmat:::tatami_row(ptr1, 8), y2[8,])
    expect_equal(beachmat:::tatami_column(ptr1, 19), y2[,19])

    expect_equal(beachmat:::tatami_row(ptr2, 28), y2[28,])
    expect_equal(beachmat:::tatami_column(ptr2, 9), y2[,9])
})
