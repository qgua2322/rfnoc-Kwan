#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Latencytest
# Generated: Tue Jul 10 13:59:02 2018
##################################################

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print "Warning: failed to XInitThreads()"

from PyQt4 import Qt
from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import gr
from gnuradio import uhd
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser
import Kwan
import ettus
import sys
from gnuradio import qtgui


class latencytest(gr.top_block, Qt.QWidget):

    def __init__(self, args=""):
        gr.top_block.__init__(self, "Latencytest")
        Qt.QWidget.__init__(self)
        self.setWindowTitle("Latencytest")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except:
            pass
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "latencytest")
        self.restoreGeometry(self.settings.value("geometry").toByteArray())

        ##################################################
        # Parameters
        ##################################################
        self.args = args

        ##################################################
        # Variables
        ##################################################
        self.device3 = variable_uhd_device3_0 = ettus.device3(uhd.device_addr_t( ",".join(('type=x300', args)) ))
        self.sample_w = sample_w = 16
        self.samp_rate_0 = samp_rate_0 = 784000
        self.samp_rate = samp_rate = 200000
        self.qy = qy = 8
        self.qx = qx = 4
        self.p_offset = p_offset = 1
        self.fft_bins = fft_bins = 32
        self.context_len = context_len = 32
        self.address = address = -(0xffffffff)/2

        ##################################################
        # Blocks
        ##################################################
        self.uhd_rfnoc_streamer_radio_0 = ettus.rfnoc_radio(
            self.device3,
            uhd.stream_args( # Tx Stream Args
                cpu_format="s16",
                otw_format="s16",
                args="", # empty
            ),
            uhd.stream_args( # Rx Stream Args
                cpu_format="s16",
                otw_format="s16",
        	args='spp = 64',
            ),
            0, -1
        )
        self.uhd_rfnoc_streamer_radio_0.set_rate(samp_rate)
        for i in xrange(1):
            self.uhd_rfnoc_streamer_radio_0.set_rx_freq(1.982e9, i)
            self.uhd_rfnoc_streamer_radio_0.set_rx_gain(20, i)
            self.uhd_rfnoc_streamer_radio_0.set_rx_dc_offset(True, i)

        self.uhd_rfnoc_streamer_radio_0.set_rx_bandwidth(56e6, 0)

        self.uhd_rfnoc_streamer_radio_0.set_rx_antenna("TX/RX", 0)

        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_int*2, '/home/phwl/rfnoc/src/rfnoc-Kwan-cross/out.bin', False)
        self.blocks_file_sink_0.set_unbuffered(False)
        self.blocks_copy_0 = blocks.copy(gr.sizeof_int*2)
        self.blocks_copy_0.set_enabled(True)
        self.Kwan_latencytest_0 = Kwan.latencytest(
                  self.device3,
                  uhd.stream_args( # TX Stream Args
                        cpu_format="u8",
                        otw_format="u8",
                        args="gr_vlen={0},{1}".format(8, "" if 8 == 1 else "spp={0}".format(8)),
                  ),
                  uhd.stream_args( # RX Stream Args
                        cpu_format="u8",
                        otw_format="u8",
                        args="gr_vlen={0},{1}".format(8, "" if 8 == 1 else "spp={0}".format(8)),
                  ),
                  -1,
                  -1
          )

        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_copy_0, 0), (self.blocks_file_sink_0, 0))
        self.connect((self.Kwan_latencytest_0, 0), (self.blocks_copy_0, 0))
        self.device3.connect(self.uhd_rfnoc_streamer_radio_0.get_block_id(), 0, self.Kwan_latencytest_0.get_block_id(), 0)

    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "latencytest")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()

    def get_args(self):
        return self.args

    def set_args(self, args):
        self.args = args

    def get_variable_uhd_device3_0(self):
        return self.variable_uhd_device3_0

    def set_variable_uhd_device3_0(self, variable_uhd_device3_0):
        self.variable_uhd_device3_0 = variable_uhd_device3_0

    def get_sample_w(self):
        return self.sample_w

    def set_sample_w(self, sample_w):
        self.sample_w = sample_w

    def get_samp_rate_0(self):
        return self.samp_rate_0

    def set_samp_rate_0(self, samp_rate_0):
        self.samp_rate_0 = samp_rate_0

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.uhd_rfnoc_streamer_radio_0.set_rate(self.samp_rate)

    def get_qy(self):
        return self.qy

    def set_qy(self, qy):
        self.qy = qy

    def get_qx(self):
        return self.qx

    def set_qx(self, qx):
        self.qx = qx

    def get_p_offset(self):
        return self.p_offset

    def set_p_offset(self, p_offset):
        self.p_offset = p_offset

    def get_fft_bins(self):
        return self.fft_bins

    def set_fft_bins(self, fft_bins):
        self.fft_bins = fft_bins

    def get_context_len(self):
        return self.context_len

    def set_context_len(self, context_len):
        self.context_len = context_len

    def get_address(self):
        return self.address

    def set_address(self, address):
        self.address = address


def argument_parser():
    parser = OptionParser(usage="%prog: [options]", option_class=eng_option)
    parser.add_option(
        "", "--args", dest="args", type="string", default="",
        help="Set args [default=%default]")
    return parser


def main(top_block_cls=latencytest, options=None):
    if options is None:
        options, _ = argument_parser().parse_args()

    from distutils.version import StrictVersion
    if StrictVersion(Qt.qVersion()) >= StrictVersion("4.5.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls(args=options.args)
    tb.start()
    tb.show()

    def quitting():
        tb.stop()
        tb.wait()
    qapp.connect(qapp, Qt.SIGNAL("aboutToQuit()"), quitting)
    qapp.exec_()


if __name__ == '__main__':
    main()
