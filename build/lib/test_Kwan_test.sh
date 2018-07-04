#!/bin/sh
export VOLK_GENERIC=1
export GR_DONT_LOAD_PREFS=1
export srcdir=/home/phwl/rfnoc/src/rfnoc-Kwan/lib
export PATH=/home/phwl/rfnoc/src/rfnoc-Kwan/build/lib:$PATH
export LD_LIBRARY_PATH=/home/phwl/rfnoc/src/rfnoc-Kwan/build/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$PYTHONPATH
test-Kwan 
