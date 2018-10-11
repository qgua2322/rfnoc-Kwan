
//
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

//
module noc_block_latencytest2 #(
  parameter NOC_ID = 64'h6666666655555555,
  parameter STR_SINK_FIFOSIZE = 11)
(
  input bus_clk, input bus_rst,
  input radio_clk, input radio_rst,
  input ce_clk, input ce_rst,
  input  [63:0] i_tdata, input  i_tlast, input  i_tvalid, output i_tready,
  output [63:0] o_tdata, output o_tlast, output o_tvalid, input  o_tready,
  output [63:0] debug,  input [63:0] timekeeper_share 
);

  ////////////////////////////////////////////////////////////
  //
  // RFNoC Shell
  //
  ////////////////////////////////////////////////////////////
  wire [31:0] set_data;
  wire [7:0]  set_addr;
  wire        set_stb;
  reg  [63:0] rb_data;
  wire [7:0]  rb_addr;

  wire [63:0] cmdout_tdata, ackin_tdata;
  wire        cmdout_tlast, cmdout_tvalid, cmdout_tready, ackin_tlast, ackin_tvalid, ackin_tready;

  wire [63:0] str_sink_tdata, str_src_tdata;
  wire        str_sink_tlast, str_sink_tvalid, str_sink_tready, str_src_tlast, str_src_tvalid, str_src_tready;

  wire [15:0] src_sid;
  wire [15:0] next_dst_sid, resp_out_dst_sid;
  wire [15:0] resp_in_dst_sid;

  wire        clear_tx_seqnum;


  wire [63:0] i_tdata_temp;

  Timestamper #(
   .MAKER(32'habcdbeef),
   .POSITION(2)
  )Timestamper1 (
    .i_tdata(i_tdata), .switch_on(1),
    .counter(simple_counter), .o_tdata(i_tdata_temp)
  );

  noc_shell #(
    .NOC_ID(NOC_ID),
    .STR_SINK_FIFOSIZE(STR_SINK_FIFOSIZE))
  noc_shell (
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .i_tdata(i_tdata_temp), .i_tlast(i_tlast), .i_tvalid(i_tvalid), .i_tready(i_tready),
    .o_tdata(o_tdata), .o_tlast(o_tlast), .o_tvalid(o_tvalid), .o_tready(o_tready),
    // Computer Engine Clock Domain
    .clk(ce_clk), .reset(ce_rst),
    // Control Sink
    .set_data(set_data), .set_addr(set_addr), .set_stb(set_stb), .set_time(), .set_has_time(),
    .rb_stb(1'b1), .rb_data(rb_data), .rb_addr(rb_addr),
    // Control Source
    .cmdout_tdata(cmdout_tdata), .cmdout_tlast(cmdout_tlast), .cmdout_tvalid(cmdout_tvalid), .cmdout_tready(cmdout_tready),
    .ackin_tdata(ackin_tdata), .ackin_tlast(ackin_tlast), .ackin_tvalid(ackin_tvalid), .ackin_tready(ackin_tready),
    // Stream Sink
    .str_sink_tdata(str_sink_tdata), .str_sink_tlast(str_sink_tlast), .str_sink_tvalid(str_sink_tvalid), .str_sink_tready(str_sink_tready),
    // Stream Source
    .str_src_tdata(str_src_tdata), .str_src_tlast(str_src_tlast), .str_src_tvalid(str_src_tvalid), .str_src_tready(str_src_tready),
    // Stream IDs set by host
    .src_sid(src_sid),                   // SID of this block
    .next_dst_sid(next_dst_sid),         // Next destination SID
    .resp_in_dst_sid(resp_in_dst_sid),   // Response destination SID for input stream responses / errors
    .resp_out_dst_sid(resp_out_dst_sid), // Response destination SID for output stream responses / errors
    // Misc
    .vita_time('d0), .clear_tx_seqnum(clear_tx_seqnum),
    .debug(debug));

  ////////////////////////////////////////////////////////////
  //
  // AXI Wrapper
  // Convert RFNoC Shell interface into AXI stream interface
  //
  ////////////////////////////////////////////////////////////
  wire [31:0] m_axis_data_tdata;
  wire        m_axis_data_tlast;
  wire        m_axis_data_tvalid;
  wire        m_axis_data_tready;

  wire [31:0] s_axis_data_tdata;
  wire        s_axis_data_tlast;
  wire        s_axis_data_tvalid;
  wire        s_axis_data_tready;

  axi_wrapper #(
    .SIMPLE_MODE(0))
  axi_wrapper (
    .clk(ce_clk), .reset(ce_rst),
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .clear_tx_seqnum(clear_tx_seqnum),
    .next_dst(next_dst_sid),
    .set_stb(set_stb), .set_addr(set_addr), .set_data(set_data),
    .i_tdata(str_sink_tdata), .i_tlast(str_sink_tlast), .i_tvalid(str_sink_tvalid), .i_tready(str_sink_tready),
    .o_tdata(str_src_tdata), .o_tlast(str_src_tlast), .o_tvalid(str_src_tvalid), .o_tready(str_src_tready),
    .m_axis_data_tdata(m_axis_data_tdata),
    .m_axis_data_tlast(m_axis_data_tlast),
    .m_axis_data_tvalid(m_axis_data_tvalid),
    .m_axis_data_tready(m_axis_data_tready),
    .m_axis_data_tuser(),
    .s_axis_data_tdata(s_axis_data_tdata),
    .s_axis_data_tlast(s_axis_data_tlast),
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tready(s_axis_data_tready),
    .s_axis_data_tuser(),
    .m_axis_config_tdata(),
    .m_axis_config_tlast(),
    .m_axis_config_tvalid(),
    .m_axis_config_tready(),
    .m_axis_pkt_len_tdata(),
    .m_axis_pkt_len_tvalid(),
    .m_axis_pkt_len_tready());

  ////////////////////////////////////////////////////////////
  //
  // User code
  //
  ////////////////////////////////////////////////////////////
  // NoC Shell registers 0 - 127,
  // User register address space starts at 128
  localparam SR_USER_REG_BASE = 128;

  // Control Source Unused
  assign cmdout_tdata  = 64'd0;
  assign cmdout_tlast  = 1'b0;
  assign cmdout_tvalid = 1'b0;
  assign ackin_tready  = 1'b1;

  // Settings registers
  //
  // - The settings register bus is a simple strobed interface.
  // - Transactions include both a write and a readback.
  // - The write occurs when set_stb is asserted.
  //   The settings register with the address matching set_addr will
  //   be loaded with the data on set_data.
  // - Readback occurs when rb_stb is asserted. The read back strobe
  //   must assert at least one clock cycle after set_stb asserts /
  //   rb_stb is ignored if asserted on the same clock cycle of set_stb.
  //   Example valid and invalid timing:
  //              __    __    __    __
  //   clk     __|  |__|  |__|  |__|  |__
  //               _____
  //   set_stb ___|     |________________
  //                     _____
  //   rb_stb  _________|     |__________     (Valid)
  //                           _____
  //   rb_stb  _______________|     |____     (Valid)
  //           __________________________
  //   rb_stb                                 (Valid if readback data is a constant)
  //               _____
  //   rb_stb  ___|     |________________     (Invalid / ignored, same cycle as set_stb)
  //
  localparam [7:0] SR_TEST_REG_0 = SR_USER_REG_BASE;
  localparam [7:0] SR_TEST_REG_1 = SR_USER_REG_BASE + 8'd1;

  wire [31:0] test_reg_0;
  setting_reg #(
    .my_addr(SR_TEST_REG_0), .awidth(8), .width(32))
  sr_test_reg_0 (
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(test_reg_0), .changed());

  wire [31:0] test_reg_1;
  setting_reg #(
    .my_addr(SR_TEST_REG_1), .awidth(8), .width(32))
  sr_test_reg_1 (
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(test_reg_1), .changed());

  // Readback registers
  // rb_stb set to 1'b1 on NoC Shell
  always @(posedge ce_clk) begin
    case(rb_addr)
      8'd0 : rb_data <= {32'd0, test_reg_0};
      8'd1 : rb_data <= {32'd0, test_reg_1};
      default : rb_data <= 64'h0BADC0DE0BADC0DE;
    endcase
  end

 //Header wire and reg
  wire eob = 1'b0;
  wire [15:0] packet_length = 16'h0;
  reg [11:0] seqnum_cnt = 12'h0;
  wire [63:0] header_wire = {2'b00,1'b1,eob,seqnum_cnt,packet_length, src_sid,next_dst_sid};

  

  
  //Shift_Register(depth=4) with AXI
  shiftRegiste_4 #(.PACKET_LENGTH(32))
    shiftRegiste_4_1(
      .clk(ce_clk),
      .reset(ce_rst),
      .clear_tx_seqnum(clear_tx_seqnum), 
      .m_axis_data_tlast(m_axis_data_tlast), .m_axis_data_tdata(m_axis_data_tdata),
      .m_axis_data_tvalid(m_axis_data_tvalid), .m_axis_data_tready(m_axis_data_tready),
      .m_axis_data_tuser(),
      .s_axis_data_tlast(s_axis_data_tlast), .s_axis_data_tdata(s_axis_data_tdata),
      .s_axis_data_tvalid(s_axis_data_tvalid), .s_axis_data_tready(s_axis_data_tready),
      .s_axis_data_tuser(s_axis_data_tuser),
      .timer(timekeeper_share), .header(header_wire),
      .incoming_axi_timestamp(), .incoming_ce_timestamp()
    );
  
 
  
  


  
  
endmodule




module shiftRegiste_4 #(
    parameter PACKET_LENGTH = 32
  )(
    input  reset, input  clk, input  clear_tx_seqnum, 
    input  m_axis_data_tlast, input  [31:0] m_axis_data_tdata,
    input  m_axis_data_tvalid, output  m_axis_data_tready,
    input  [127:0] m_axis_data_tuser,
    output  s_axis_data_tlast, output  [31:0] s_axis_data_tdata,
    output  s_axis_data_tvalid, input  s_axis_data_tready,
    output  [127:0] s_axis_data_tuser,
    input  [63:0] timer,input [63:0] header,
    input  [63:0] incoming_axi_timestamp, input [63:0] incoming_ce_timestamp
  );
  //Axi_fifo_interface wire
  wire [31:0] pipe_in_tdata;
  wire pipe_in_tvalid, pipe_in_tlast;
  wire pipe_in_tready;

  wire [31:0] pipe_out_tdata;
  wire pipe_out_tvalid, pipe_out_tlast;
  wire pipe_out_tready;
  wire [127:0] pipe_out_tuser;
  
  reg [PACKET_LENGTH+1 :0 ] reg1;
  reg [PACKET_LENGTH+1 :0 ] reg2;
  reg [PACKET_LENGTH+1 :0 ] reg3;
  reg [PACKET_LENGTH+1 :0 ] reg4;


  always @(posedge clk or negedge reset) begin
    if (reset) begin 
      reg1 <= 0;
      reg2 <= 0;
      reg3 <= 0;
      reg4 <= 0;
    end else if (clk && s_axis_data_tready) begin
      reg1 <= {m_axis_data_tlast,m_axis_data_tvalid,m_axis_data_tdata}; 
      reg2 <= reg1;
      reg3 <= reg2;
      reg4 <= reg3;
    end
  end

  assign s_axis_data_tlast = reg4[PACKET_LENGTH+1];
  assign s_axis_data_tvalid = reg4[PACKET_LENGTH];
  assign s_axis_data_tdata = reg4[PACKET_LENGTH-1:0];
  assign m_axis_data_tready = s_axis_data_tready;
  assign s_axis_data_tuser = {header,timer[63:0]};     
endmodule

module Timestamper #(
  parameter MAKER = 32'habcdbeef,
  parameter POSITION = 1
)(
  input [63:0] i_tdata,input switch_on,
  input [63:0] counter,output [63:0] o_tdata
);

  wire [63:0] first = {i_tdata[63:32],counter[31:0]};
  wire [63:0] second  = {counter[31:0], i_tdata[31:0]};
  assign o_tdata = (i_tdata[63:32] == MAKER) ?  ((POSITION == 1 ) ? first:second):i_tdata ;



endmodule
