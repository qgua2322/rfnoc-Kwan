/* -*- c++ -*- */

#define KWAN_API
#define ETTUS_API

%include "gnuradio.i"/*			*/// the common stuff

//load generated python docstrings
%include "Kwan_swig_doc.i"
//Header from gr-ettus
%include "ettus/device3.h"
%include "ettus/rfnoc_block.h"
%include "ettus/rfnoc_block_impl.h"

%{
#include "ettus/device3.h"
#include "ettus/rfnoc_block_impl.h"
#include "Kwan/latencytest.h"
#include "Kwan/latencytest2.h"
%}

%include "Kwan/latencytest.h"
GR_SWIG_BLOCK_MAGIC2(Kwan, latencytest);
%include "Kwan/latencytest2.h"
GR_SWIG_BLOCK_MAGIC2(Kwan, latencytest2);
