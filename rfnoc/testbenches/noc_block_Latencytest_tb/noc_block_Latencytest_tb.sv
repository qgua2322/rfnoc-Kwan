/* 
 * Copyright 2018 <+YOU OR YOUR COMPANY+>.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

`timescale 1ns/1ps
`define NS_PER_TICK 1
`define NUM_TEST_CASES 5

`include "sim_exec_report.vh"
`include "sim_clks_rsts.vh"
`include "sim_rfnoc_lib.svh"

module noc_block_Latencytest_tb();
  `TEST_BENCH_INIT("noc_block_Latencytest",`NUM_TEST_CASES,`NS_PER_TICK);
  localparam BUS_CLK_PERIOD = $ceil(1e9/166.67e6);
  localparam CE_CLK_PERIOD  = $ceil(1e9/200e6);
  localparam NUM_CE         = 2;  // Number of Computation Engines / User RFNoC blocks to simulate
  localparam NUM_STREAMS    = 1;  // Number of test bench streams
  `RFNOC_SIM_INIT(NUM_CE, NUM_STREAMS, BUS_CLK_PERIOD, CE_CLK_PERIOD);
  `RFNOC_ADD_BLOCK(noc_block_radio_core_modified, 0);
  `RFNOC_ADD_BLOCK(noc_block_Latencytest, 1);

  localparam SPP = 64; // Samples per packet

  /********************************************************
  ** Verification
  ********************************************************/
  initial begin : tb_main
    string s;
    logic [31:0] random_word;
    logic [63:0] readback;
    logic [63:0] readback2;

    /********************************************************
    ** Test 1 -- Reset
    ********************************************************/
    `TEST_CASE_START("Wait for Reset");
    while (bus_rst) @(posedge bus_clk);
    while (ce_rst) @(posedge ce_clk);
    `TEST_CASE_DONE(~bus_rst & ~ce_rst);

    /********************************************************
    ** Test 2 -- Check for correct NoC IDs
    ********************************************************/
    `TEST_CASE_START("Check NoC ID");
    // Read NOC IDs
    tb_streamer.read_reg(sid_noc_block_Latencytest, RB_NOC_ID, readback);
    $display("Read Latencytest NOC ID: %16x", readback);
    $display("Correct Latencytest NOC ID: %16x", noc_block_Latencytest.NOC_ID);

    tb_streamer.read_reg(sid_noc_block_radio_core_modified, RB_NOC_ID, readback2);
    $display("Read Radio_Core NOC ID: %16x", readback2);
    $display("Correct Radio_Core NOC ID: %16x", noc_block_radio_core_modified.NOC_ID);

    `ASSERT_ERROR(readback == noc_block_Latencytest.NOC_ID, "Incorrect Latencytest NOC ID");
    `ASSERT_ERROR(readback2 == noc_block_radio_core_modified.NOC_ID, "Incorrect Radio core_modified NOC ID");

    `TEST_CASE_DONE(1);

    /********************************************************
    ** Test 3 -- Connect RFNoC blocks
    ********************************************************/
    `TEST_CASE_START("Connect RFNoC blocks");
    `RFNOC_CONNECT(noc_block_tb,noc_block_radio_core_modified,SC16,SPP);
    `RFNOC_CONNECT(noc_block_radio_core_modified,noc_block_Latencytest,SC16,SPP);
    `RFNOC_CONNECT(noc_block_Latencytest,noc_block_tb,SC16,SPP);
    `TEST_CASE_DONE(1);

    /********************************************************
    ** Test 4 -- Write / readback user registers
    ********************************************************/
    `TEST_CASE_START("Write / readback user registers");
    random_word = $random();
    tb_streamer.write_user_reg(sid_noc_block_Latencytest, noc_block_Latencytest.SR_SPP_SHIFT, random_word);
    tb_streamer.read_user_reg(sid_noc_block_Latencytest, 0, readback);
    $sformat(s, "User SPP_SHIFT_REG incorrect readback! Expected: %0d, Actual %0d", readback[31:0], random_word);
    `ASSERT_ERROR(readback[31:0] == random_word, s);
    random_word = $random();
    tb_streamer.write_user_reg(sid_noc_block_Latencytest, noc_block_Latencytest.SR_PACKET_LIMIT, random_word);
    tb_streamer.read_user_reg(sid_noc_block_Latencytest, 1, readback);
    $sformat(s, "User PACKET_LIMIT_REG incorrect readback! Expected: %0d, Actual %0d", readback[31:0], random_word);
    `ASSERT_ERROR(readback[31:0] == random_word, s);
    
    `TEST_CASE_DONE(1);

    /********************************************************
    ** Test 5 -- Test sequence
    ********************************************************/
    // Latencytest's user code is a loopback, so we should receive
    // back exactly what we send
    `TEST_CASE_START("Test sequence");
    tb_streamer.write_user_reg(sid_noc_block_Latencytest, noc_block_Latencytest.SR_SPP_SHIFT, 6);
    tb_streamer.write_user_reg(sid_noc_block_Latencytest, noc_block_Latencytest.SR_PACKET_LIMIT, 100);
    tb_streamer.write_user_reg(sid_noc_block_Latencytest, noc_block_Latencytest.SR_PACKET_AVG_SIZE, 64);
    tb_streamer.write_user_reg(sid_noc_block_Latencytest, noc_block_Latencytest.SR_PACKET_SHIFT, 6);
    tb_streamer.write_user_reg(sid_noc_block_radio_core_modified, noc_block_radio_core_modified.SR_RX_CTRL_MAXLEN, 32'(SPP),0);
    tb_streamer.write_user_reg(sid_noc_block_radio_core_modified, noc_block_radio_core_modified.SR_RX_CTRL_COMMAND, 32'he0000001,0);
    tb_streamer.write_user_reg(sid_noc_block_radio_core_modified, noc_block_radio_core_modified.SR_RX_CTRL_TIME_HI, 32'h0,0);
    tb_streamer.write_user_reg(sid_noc_block_radio_core_modified, noc_block_radio_core_modified.SR_RX_CTRL_TIME_LO, 32'h0,0);

    $display("Start simulation");
    
    #5000000;
    
    `TEST_CASE_DONE(1);
    `TEST_BENCH_DONE;

  end
endmodule
