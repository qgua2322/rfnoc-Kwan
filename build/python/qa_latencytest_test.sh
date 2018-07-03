#!/bin/sh
export VOLK_GENERIC=1
export GR_DONT_LOAD_PREFS=1
export srcdir=/home/vivado/rfnoc/src/rfnoc-Kwan/python
export PATH=/home/vivado/rfnoc/src/rfnoc-Kwan/build/python:$PATH
export LD_LIBRARY_PATH=/home/vivado/rfnoc/src/rfnoc-Kwan/build/lib:$LD_LIBRARY_PATH
export PYTHONPATH=/home/vivado/rfnoc/src/rfnoc-Kwan/build/swig:$PYTHONPATH
/usr/bin/python2 /home/vivado/rfnoc/src/rfnoc-Kwan/python/qa_latencytest.py 
