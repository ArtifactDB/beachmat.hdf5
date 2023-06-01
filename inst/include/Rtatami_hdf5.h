#ifndef RTATAMI_HDF5_H
#define RTATAMI_HDF5_H

#include "Rtatami.h"
#include <mutex>
#include <iostream>

// Avoid creating a different mutex for each lock_hdf5 template instantiation, which would not be desirable. 
// Setting it to a local static variable should give a single global mutex across all TU's, see discussion at
// https://stackoverflow.com/questions/52851239/local-static-variable-linkage-in-a-template-class-static-member-function
static auto& fetch_hdf5_mutex() {
    static std::mutex hdf5_mut;
    return hdf5_mut;
}

template<class Function_>
void lock_hdf5(Function_ fun) {
    std::lock_guard lck(fetch_hdf5_mutex());
    fun();
}

#define TATAMI_HDF5_PARALLEL_LOCK lock_hdf5

#include "tatami_hdf5/tatami_hdf5.hpp"

#endif
