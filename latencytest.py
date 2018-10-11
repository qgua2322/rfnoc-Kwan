#!/usr/bin/env python2
# -*- coding: utf-8 -*-
#
# SPDX-License-Identifier: GPL-3.0
#
##################################################
# GNU Radio Python Flow Graph
# Title: Latencytest
# Generated: Thu Aug 30 11:37:07 2018
# GNU Radio version: 3.7.12.0
##################################################

from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import gr
from gnuradio import uhd
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser
import Kwan
import ettus
import pmt


class latencytest(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Latencytest")

        ##################################################
        # Variables
        ##################################################
        self.spp = spp = 4
        self.vlb = vlb = spp*4
        self.device3 = variable_uhd_device3_0 = ettus.device3(uhd.device_addr_t( ",".join(('type=x300', 'args')) ))
        self.samp_rate = samp_rate = 500000

        ##################################################
        # Blocks
        ##################################################
        self.uhd_rfnoc_streamer_fifo_0 = ettus.rfnoc_generic(
            self.device3,
            uhd.stream_args( # TX Stream Args
                cpu_format="u8",
                otw_format="u8",
                args="gr_vlen={0},{1}".format(vlb, "" if vlb == 1 else "spp={0}".format(vlb)),
            ),
            uhd.stream_args( # RX Stream Args
                cpu_format="u8",
                otw_format="u8",
                args="gr_vlen={0},{1}".format(vlb, "" if vlb == 1 else "spp={0}".format(vlb)),
            ),
            "FIFO", -1, -1,
        )
        self.blocks_throttle_0_0 = blocks.throttle(gr.sizeof_int*spp, samp_rate,True)
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_int*spp, '/home/vivado/rfnoc/src/rfnoc-Kwan/test_in.bin', False)
        self.blocks_file_source_0.set_begin_tag(pmt.PMT_NIL)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_int*spp, '/home/vivado/rfnoc/src/rfnoc-Kwan/out.bin', False)
        self.blocks_file_sink_0.set_unbuffered(False)
        self.blocks_copy_0 = blocks.copy(gr.sizeof_int*spp)
        self.blocks_copy_0.set_enabled(True)
        self.Kwan_latencytest_0 = Kwan.latencytest(
                  self.device3,
                  uhd.stream_args( # TX Stream Args
                        cpu_format="u8",
                        otw_format="u8",
                        args="gr_vlen={0},{1}".format(vlb, "" if vlb == 1 else "spp={0}".format(vlb)),
                  ),
                  uhd.stream_args( # RX Stream Args
                        cpu_format="u8",
                        otw_format="u8",
                        args="gr_vlen={0},{1}".format(vlb, "" if vlb == 1 else "spp={0}".format(vlb)),
                  ),
                  -1,
                  -1
          )



        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_copy_0, 0), (self.blocks_file_sink_0, 0))
        self.connect((self.blocks_file_source_0, 0), (self.blocks_throttle_0_0, 0))
        self.connect((self.blocks_throttle_0_0, 0), (self.uhd_rfnoc_streamer_fifo_0, 0))
        self.connect((self.Kwan_latencytest_0, 0), (self.blocks_copy_0, 0))
        self.device3.connect(self.uhd_rfnoc_streamer_fifo_0.get_block_id(), 0, self.Kwan_latencytest_0.get_block_id(), 0)

    def get_spp(self):
        return self.spp

    def set_spp(self, spp):
        self.spp = spp
        self.set_vlb(self.spp*4)

    def get_vlb(self):
        return self.vlb

    def set_vlb(self, vlb):
        self.vlb = vlb

    def get_variable_uhd_device3_0(self):
        return self.variable_uhd_device3_0

    def set_variable_uhd_device3_0(self, variable_uhd_device3_0):
        self.variable_uhd_device3_0 = variable_uhd_device3_0

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.blocks_throttle_0_0.set_sample_rate(self.samp_rate)


def main(top_block_cls=latencytest, options=None):

    tb = top_block_cls()
    tb.start()
    tb.wait()


if __name__ == '__main__':
    main()
