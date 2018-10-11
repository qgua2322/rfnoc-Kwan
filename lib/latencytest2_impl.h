/* -*- c++ -*- */
/* MIT License
 * 
 * Copyright (c) 2018 qgua2322
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef INCLUDED_KWAN_LATENCYTEST2_IMPL_H
#define INCLUDED_KWAN_LATENCYTEST2_IMPL_H

#include <Kwan/latencytest2.h>
#include <Kwan/latencytest2_block_ctrl.hpp>
#include <ettus/rfnoc_block_impl.h>

namespace gr {
  namespace Kwan {

    class latencytest2_impl : public latencytest2, public gr::ettus::rfnoc_block_impl
    {
     private:
      // Nothing to declare in this block.

     public:
      latencytest2_impl(
        const gr::ettus::device3::sptr &dev,
        const ::uhd::stream_args_t &tx_stream_args,
        const ::uhd::stream_args_t &rx_stream_args,
        const int block_select,
        const int device_select
      );
      ~latencytest2_impl();

      // Where all the action really happens
    };

  } // namespace Kwan
} // namespace gr

#endif /* INCLUDED_KWAN_LATENCYTEST2_IMPL_H */

