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


#ifndef INCLUDED_KWAN_LATENCYTEST2_H
#define INCLUDED_KWAN_LATENCYTEST2_H

#include <Kwan/api.h>
#include <ettus/device3.h>
#include <ettus/rfnoc_block.h>
#include <uhd/stream.hpp>

namespace gr {
  namespace Kwan {

    /*!
     * \brief <+description of block+>
     * \ingroup Kwan
     *
     */
    class KWAN_API latencytest2 : virtual public gr::ettus::rfnoc_block
    {
     public:
      typedef boost::shared_ptr<latencytest2> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of Kwan::latencytest2.
       *
       * To avoid accidental use of raw pointers, Kwan::latencytest2's
       * constructor is in a private implementation
       * class. Kwan::latencytest2::make is the public interface for
       * creating new instances.
       */
      static sptr make(
        const gr::ettus::device3::sptr &dev,
        const ::uhd::stream_args_t &tx_stream_args,
        const ::uhd::stream_args_t &rx_stream_args,
        const int block_select=-1,
        const int device_select=-1
        );
    };
  } // namespace Kwan
} // namespace gr

#endif /* INCLUDED_KWAN_LATENCYTEST2_H */

