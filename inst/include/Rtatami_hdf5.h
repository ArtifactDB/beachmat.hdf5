#ifndef RTATAMI_HDF5_H
#define RTATAMI_HDF5_H

#include "Rtatami.h"
#include <mutex>
#include <iostream>

// Avoid creating a different mutex for each lock_hdf5 template instantiation,
// which would not be desirable.
extern std::mutex hdf5_lock;

template<class Function_>
void lock_hdf5(Function_ fun) {
    std::cout << &hdf5_lock << std::endl;
    std::lock_guard lck(hdf5_lock);
    fun();
    std::cout << "OKAY" << std::endl;
}

#define TATAMI_HDF5_PARALLEL_LOCK lock_hdf5

#include "tatami_hdf5/tatami_hdf5.hpp"

#endif
