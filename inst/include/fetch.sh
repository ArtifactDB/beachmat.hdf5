#!/bin/bash

set -e
set -u

if [ ! -e source-tatami_hdf5 ]
then 
    git clone https://github.com/tatami-inc/tatami_hdf5 source-tatami_hdf5
else 
    cd source-tatami_hdf5
    git pull
    cd -
fi

cd source-tatami_hdf5
git checkout v2.0.0
rm -rf ../tatami_hdf5
cp -r include/tatami_hdf5/ ../tatami_hdf5
git checkout master
cd -

