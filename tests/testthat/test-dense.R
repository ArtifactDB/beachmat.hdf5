# This tests the functions with respect to dense arrays.
# library(testthat); library(beachmat.hdf5); source("test-dense.R")

library(HDF5Array)
y <- matrix(runif(1000), ncol=20, nrow=50)
z <- as(y, "HDF5Array")

test_that("initialization works correctly for dense HDF5 arrays", {
    ptr <- initializeCpp(z)
    expect_identical(beachmat:::tatami_dim(ptr), dim(y))
    expect_identical(beachmat:::tatami_row(ptr, 1), y[1,])
    expect_identical(beachmat:::tatami_column(ptr, 2), y[,2])

    expect_identical(beachmat:::tatami_row_sums(ptr, 2), rowSums(y))
    expect_identical(beachmat:::tatami_column_sums(ptr, 2), colSums(y))
})

test_that("memorization works correctly for dense HDF5 arrays", {
    ptr1 <- initializeCpp(z, memorize=TRUE)
    ptr2 <- initializeCpp(z, memorize=TRUE)
    expect_identical(capture.output(print(ptr1)), capture.output(print(ptr2)))

    expect_identical(beachmat:::tatami_row(ptr1, 5), y[5,])
    expect_identical(beachmat:::tatami_column(ptr1, 6), y[,6])

    expect_identical(beachmat:::tatami_row(ptr2, 5), y[5,])
    expect_identical(beachmat:::tatami_column(ptr2, 6), y[,6])
})

library(Matrix)
y <- as.matrix(Matrix::rsparsematrix(50, 20, 0.1))
z <- as(y, "HDF5Array")

test_that("memorization works correctly for dense-as-sparse HDF5 arrays", {
    ptr1 <- initializeCpp(z, memorize=TRUE)
    ptr2 <- initializeCpp(z, memorize=TRUE)
    expect_identical(capture.output(print(ptr1)), capture.output(print(ptr2)))

    expect_identical(beachmat:::tatami_row(ptr1, 45), y[45,])
    expect_identical(beachmat:::tatami_column(ptr1, 16), y[,16])

    expect_identical(beachmat:::tatami_row(ptr2, 45), y[45,])
    expect_identical(beachmat:::tatami_column(ptr2, 16), y[,16])
})

library(Matrix)
y <- matrix(sample(1000), 40L, 25L)
z <- as(y, "HDF5Array")

test_that("memorization works correctly for integer HDF5 arrays", {
    ptr1 <- initializeCpp(z, memorize=TRUE)
    ptr2 <- initializeCpp(z, memorize=TRUE)
    expect_identical(capture.output(print(ptr1)), capture.output(print(ptr2)))

    expect_equal(beachmat:::tatami_row(ptr1, 35), y[35,])
    expect_equal(beachmat:::tatami_column(ptr1, 16), y[,16])

    expect_equal(beachmat:::tatami_row(ptr2, 35), y[35,])
    expect_equal(beachmat:::tatami_column(ptr2, 16), y[,16])
})

library(Matrix)
z <- writeHDF5Array(y, H5type="H5T_NATIVE_UINT16")

test_that("memorization works correctly for small integer HDF5 arrays", {
    ptr1 <- initializeCpp(z, memorize=TRUE)
    ptr2 <- initializeCpp(z, memorize=TRUE)
    expect_identical(capture.output(print(ptr1)), capture.output(print(ptr2)))

    expect_equal(beachmat:::tatami_row(ptr1, 8), y[8,])
    expect_equal(beachmat:::tatami_column(ptr1, 19), y[,19])

    expect_equal(beachmat:::tatami_row(ptr2, 8), y[8,])
    expect_equal(beachmat:::tatami_column(ptr2, 19), y[,19])
})
