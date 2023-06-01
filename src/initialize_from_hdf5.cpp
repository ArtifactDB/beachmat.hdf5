#include "Rtatami_hdf5.h"
#include <string>

//[[Rcpp::export(rng=false)]]
SEXP initialize_from_hdf5_sparse(std::string file, std::string name, size_t nrow, size_t ncol, bool byrow) {
    auto output = Rtatami::new_BoundNumericMatrix();
    if (byrow) {
        output->ptr.reset(new tatami_hdf5::Hdf5CompressedSparseMatrix<true, double, int>(nrow, ncol, std::move(file), name + "/data", name + "/indices", name + "/indptr"));
    } else {
        output->ptr.reset(new tatami_hdf5::Hdf5CompressedSparseMatrix<false, double, int>(nrow, ncol, std::move(file), name + "/data", name + "/indices", name + "/indptr"));
    }
    return output; 
}

//[[Rcpp::export(rng=false)]]
SEXP initialize_from_hdf5_dense(std::string file, std::string name) {
    auto output = Rtatami::new_BoundNumericMatrix();
    output->ptr.reset(new tatami_hdf5::Hdf5DenseMatrix<double, int, true>(std::move(file), std::move(name)));
    return output; 
}

