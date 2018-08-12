/* -*- c++ -*- */

#define KWAN_CROSS_API
#define ETTUS_API

%include "gnuradio.i"/*			*/// the common stuff

//load generated python docstrings
%include "kwan_cross_swig_doc.i"
//Header from gr-ettus
%include "ettus/device3.h"
%include "ettus/rfnoc_block.h"
%include "ettus/rfnoc_block_impl.h"

%{
#include "ettus/device3.h"
#include "ettus/rfnoc_block_impl.h"
#include "kwan_cross/Latencytest.h"
%}

%include "kwan_cross/Latencytest.h"
GR_SWIG_BLOCK_MAGIC2(kwan_cross, Latencytest);
