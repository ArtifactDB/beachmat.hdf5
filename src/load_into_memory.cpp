#include "Rtatami_hdf5.h"
#include <string>

template<bool ROW, typename Tx, typename Ti>
SEXP load_into_memory_sparse_base(const std::string& file, const std::string& name, int nrow, int ncol) {
    auto mat = tatami_hdf5::load_hdf5_compressed_sparse_matrix<ROW, double, int, std::vector<Tx>, std::vector<Ti> >(
        nrow, 
        ncol, 
        file, 
        name + "/data", 
        name + "/indices", 
        name + "/indptr"
    );

    auto output = Rtatami::new_BoundNumericMatrix();
    output->ptr = std::make_shared<decltype(mat)>(std::move(mat));
    return output;
}

template<typename Tx, typename Ti>
SEXP load_into_memory_sparse_byrow(const std::string& file, const std::string& name, int nrow, int ncol, bool byrow) {
    if (byrow) {
        return load_into_memory_sparse_base<true, Tx, Ti>(file, name, nrow, ncol);
    } else {
        return load_into_memory_sparse_base<false, Tx, Ti>(file, name, nrow, ncol);
    }
}

template<typename Tx>
SEXP load_into_memory_sparse_i_max(const std::string& file, const std::string& name, int nrow, int ncol, bool byrow) {
    if ((byrow ? ncol : nrow) <= std::numeric_limits<uint16_t>::max()) {
        return load_into_memory_sparse_byrow<Tx, uint16_t>(file, name, nrow, ncol, byrow);
    } else {
        return load_into_memory_sparse_byrow<Tx, int>(file, name, nrow, ncol, byrow);
    }
}

// TODO: migrate internal type choices to tatami_hdf5.
std::pair<bool, bool> check_type(const std::string& file, const std::string& name) {
    H5::H5File handle(file, H5F_ACC_RDONLY);
    auto xhandle = handle.openDataSet(name);
    auto xtype = xhandle.getDataType();

    bool is_ushort = false;
    bool is_float = (xtype.getClass() == H5T_FLOAT);
    if (!is_float) {
        H5::IntType xitype(xhandle);
        is_ushort = (xitype.getSize() <= 2 && xitype.getSign() == H5T_SGN_NONE);
    }

    return std::make_pair(is_float, is_ushort);
}

//[[Rcpp::export(rng=false)]]
SEXP load_into_memory_sparse(std::string file, std::string name, int nrow, int ncol, bool byrow, bool forced_int) {
    auto inspected = check_type(file, name + "/data");
    auto is_float = inspected.first;
    auto is_ushort = inspected.second;

    if (is_float && !forced_int) {
        return load_into_memory_sparse_i_max<double>(file, name, nrow, ncol, byrow);
    } else if (is_ushort) {
        return load_into_memory_sparse_i_max<uint16_t>(file, name, nrow, ncol, byrow);
    } else {
        return load_into_memory_sparse_i_max<int>(file, name, nrow, ncol, byrow);
    }
}

//[[Rcpp::export(rng=false)]]
SEXP load_into_memory_dense(std::string file, std::string name, bool forced_int) {
    auto inspected = check_type(file, name);
    auto is_float = inspected.first;
    auto is_ushort = inspected.second;

    auto output = Rtatami::new_BoundNumericMatrix();
    if (is_float && !forced_int) {
        auto mat = tatami_hdf5::load_hdf5_dense_matrix<double, int, std::vector<double>, true>(file, name);
        output->ptr = std::make_shared<decltype(mat)>(std::move(mat));
    } else if (is_ushort) {
        auto mat = tatami_hdf5::load_hdf5_dense_matrix<double, int, std::vector<uint16_t>, true>(file, name);
        output->ptr = std::make_shared<decltype(mat)>(std::move(mat));
    } else {
        auto mat = tatami_hdf5::load_hdf5_dense_matrix<double, int, std::vector<int>, true>(file, name);
        output->ptr = std::make_shared<decltype(mat)>(std::move(mat));
    }
    return output;
}

template<typename Tx, typename Ti>
auto load_into_memory_dense_to_sparse_i_max(const tatami::NumericMatrix* mat, bool byrow) {
    if (byrow) {
        return tatami::convert_to_sparse<true, double, int, Tx, Ti>(mat);
    } else {
        return tatami::convert_to_sparse<false, double, int, Tx, Ti>(mat);
    }
}

template<typename Tx>
SEXP load_into_memory_dense_to_sparse_base(const std::string& file, const std::string& name, int cache_size, bool byrow) {
    tatami_hdf5::Hdf5Options opt;
    opt.maximum_cache_size = cache_size;
    tatami_hdf5::Hdf5DenseMatrix<double, int, true> mat(file, name, opt);

    auto output = Rtatami::new_BoundNumericMatrix();
    if ((byrow ? mat.ncol() : mat.nrow()) <= std::numeric_limits<uint16_t>::max()) {
        output->ptr = load_into_memory_dense_to_sparse_i_max<Tx, uint16_t>(&mat, byrow);
    } else {
        output->ptr = load_into_memory_dense_to_sparse_i_max<Tx, int>(&mat, byrow);
    }
    return output;
}

//[[Rcpp::export(rng=false)]]
SEXP load_into_memory_dense_as_sparse(std::string file, std::string name, bool forced_int, int cache_size, bool byrow) {
    auto inspected = check_type(file, name);
    auto is_float = inspected.first;
    auto is_ushort = inspected.second;

    if (is_float && !forced_int) {
        return load_into_memory_dense_to_sparse_base<double>(file, name, cache_size, byrow);
    } else if (is_ushort) {
        return load_into_memory_dense_to_sparse_base<uint16_t>(file, name, cache_size, byrow);
    } else {
        return load_into_memory_dense_to_sparse_base<int>(file, name, cache_size, byrow);
    }
}
