
//
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

//
module noc_block_latencytest #(
  parameter NOC_ID = 64'h5555555566666666,
  parameter STR_SINK_FIFOSIZE = 11,
  parameter MTU = 8'd10)
(
  input bus_clk, input bus_rst,
  input ce_clk, input ce_rst,
  input  [63:0] i_tdata, input  i_tlast, input  i_tvalid, output i_tready,
  output [63:0] o_tdata, output o_tlast, output o_tvalid, input  o_tready,
  output [31:0] leds_test, input [63:0] vita_time_input, output [63:0] debug
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


  //Timestamper wire
  reg [63:0] outcoming_axi_timestamp = 64'h0;
  reg [63:0] incoming_axi_timestamp = 64'h0;
  reg [63:0] incoming_ip_timestamp = 64'h0;
  reg [63:0] outcoming_ip_timestamp = 64'h0;
  wire [32:0] str_sink_tdata_temp;
  wire [32:0] m_axis_data_tdata_temp;
  wire [32:0] s_axis_data_tdata_temp;
  wire [63:0] o_tdata_temp;
  reg [63:0] simple_counter = 64'h0;
  reg [63:0] simple_counter_shift32  = 64'h0;

  always @(posedge ce_clk ) begin 
    if (i_tdata == 64'h00000000deadbeef) begin
      simple_counter <= 64'h0;
    end else begin
      simple_counter <= simple_counter+1;
    end
  end

  assign o_tdata = (o_tdata_temp == 64'h00000000deadbeef) ? {simple_counter[31:0],outcoming_axi_timestamp[31:0]} : o_tdata_temp;
  
  wire [63:0] i_tdata_temp;
  wire  i_tlast_temp;
  wire  i_tvalid_temp;
  wire  i_tready_temp;

  /*
  timestamper #(
      .HEADER(2'b00),
      .PACKET_LENGTH(64),
      .TIME_LENGTH(64)
    )timestamper_in_noc(
      .clk(bus_clk),
      .reset(bus_rst),
      .i_tdata(i_tdata), .i_tlast(i_tlast), .i_tvalid(i_tvalid), .i_tready(i_tready),
      .o_tdata(i_tdata_temp), .o_tlast(i_tlast_temp), .o_tvalid(i_tvalid_temp), .o_tready(i_tready_temp)
    );
  */
  noc_shell #(
    .NOC_ID(NOC_ID),
    .STR_SINK_FIFOSIZE(STR_SINK_FIFOSIZE)
    )
  noc_shell (
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .i_tdata(i_tdata), .i_tlast(i_tlast), .i_tvalid(i_tvalid), .i_tready(i_tready),
    .o_tdata(o_tdata_temp), .o_tlast(o_tlast), .o_tvalid(o_tvalid), .o_tready(o_tready),
    // Computer Engine Clock Domain
    .clk(ce_clk), .reset(ce_rst),
    // Control Sink
    .set_data(set_data), .set_addr(set_addr), .set_stb(set_stb),
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
  wire [31:0]  m_axis_data_tdata;
  wire [127:0] m_axis_data_tuser;
  wire         m_axis_data_tlast;
  wire         m_axis_data_tvalid;
  wire         m_axis_data_tready;

  wire [31:0]  s_axis_data_tdata;
  wire [127:0] s_axis_data_tuser;
  wire         s_axis_data_tlast;
  wire         s_axis_data_tvalid;
  wire         s_axis_data_tready;

  /*
  timestamper #(
      .HEADER(2'b01),
      .PACKET_LENGTH(64),
      .TIME_LENGTH(64)
    )timestamper_noc2axi(
      .clk(ce_clk),
      .reset(ce_rst),
      .input_packet(str_sink_tdata),
      .input_valid(str_sink_tvalid),
      .input_time(simple_counter) ,
      .output_packet(str_sink_tdata_temp)
    );
  */
  always @( posedge ce_clk) begin
    if(str_src_tdata == 64'hdeadbeef) begin
      outcoming_axi_timestamp <= simple_counter;
    end 
  end

  always @( posedge ce_clk) begin
    if(str_sink_tdata == 64'hdeadbeef) begin
      incoming_axi_timestamp <= simple_counter;
    end 
  end
  
  always @( posedge ce_clk) begin
    if(m_axis_data_tdata == 32'hdeadbeef) begin
      incoming_ip_timestamp <= simple_counter;
    end 
  end

  always @( posedge ce_clk) begin
    if(s_axis_data_tdata == 32'hdeadbeef) begin
      outcoming_ip_timestamp <= simple_counter;
    end 
  end

  axi_wrapper #(
    .SIMPLE_MODE(0))
  axi_wrapper (
    .clk(ce_clk), .reset(ce_rst),
    .clear_tx_seqnum(clear_tx_seqnum),
    .next_dst(next_dst_sid),
    .set_stb(set_stb), .set_addr(set_addr), .set_data(set_data),
    .i_tdata(str_sink_tdata), .i_tlast(str_sink_tlast), .i_tvalid(str_sink_tvalid), .i_tready(str_sink_tready),
    .o_tdata(str_src_tdata), .o_tlast(str_src_tlast), .o_tvalid(str_src_tvalid), .o_tready(str_src_tready),
    .m_axis_data_tdata(m_axis_data_tdata),
    .m_axis_data_tlast(m_axis_data_tlast),
    .m_axis_data_tvalid(m_axis_data_tvalid),
    .m_axis_data_tready(m_axis_data_tready),
    .m_axis_data_tuser(m_axis_data_tuser),
    .s_axis_data_tdata(s_axis_data_tdata),
    .s_axis_data_tlast(s_axis_data_tlast),
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tready(s_axis_data_tready),
    .s_axis_data_tuser(s_axis_data_tuser),
    .m_axis_config_tdata(),
    .m_axis_config_tlast(),
    .m_axis_config_tvalid(),
    .m_axis_config_tready(),
    .m_axis_pkt_len_tdata(),
    .m_axis_pkt_len_tvalid(),
    .m_axis_pkt_len_tready());

  /*
  timestamper #(
      .HEADER(2'b10),
      .PACKET_LENGTH(32),
      .TIME_LENGTH(64)
    )timestamper_axi2ip(
      .clk(ce_clk),
      .reset(ce_rst),
      .input_packet(m_axis_data_tdata),
      .input_valid(m_axis_data_tvalid),
      .input_time(simple_counter) ,
      .output_packet(m_axis_data_tdata_temp)
    );
  */
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
  reg [127:0] header_reg = 128'h0;
  reg [11:0] seqnum_cnt = 12'h0;
  wire [127:0] header_wire = {2'b00,1'b1,eob,seqnum_cnt,packet_length, src_sid,next_dst_sid,simple_counter};

  

  always @(posedge ce_clk or negedge ce_rst) begin
    if(ce_rst) begin
      header_reg <= 128'h0;
    end else  begin
      header_reg <= header_wire;
    end
  end

  

  
  //Shift_Register(depth=4) with AXI
  shiftRegiste_4 #(.PACKET_LENGTH(32))
    shiftRegiste_4_1(
      .clk(ce_clk),
      .reset(ce_rst),
      .clear_tx_seqnum(clear_tx_seqnum), 
      .m_axis_data_tlast(m_axis_data_tlast), .m_axis_data_tdata(m_axis_data_tdata),
      .m_axis_data_tvalid(m_axis_data_tvalid), .m_axis_data_tready(m_axis_data_tready),
      .header_reg(header_reg),
      .s_axis_data_tlast(s_axis_data_tlast), .s_axis_data_tdata(s_axis_data_tdata),
      .s_axis_data_tvalid(s_axis_data_tvalid), .s_axis_data_tready(s_axis_data_tready),
      .s_axis_data_tuser(s_axis_data_tuser)
    );
  
 
  
  


  
  
endmodule



/*
Simple MUX module
*/
module mux_2to1 #(
  parameter PACKET_LENGTH  = 32)
 (input clk,
  input [PACKET_LENGTH-1:0]selector,
  input [PACKET_LENGTH-1:0] input1,
  input [PACKET_LENGTH-1:0] input2,
  input [PACKET_LENGTH-1:0] input3,
  output reg [PACKET_LENGTH-1:0] Q); 




  localparam choose1 = 64'h0,
             choose2 = 64'h1,
             choose3  = 64'd2;

  always @(selector ) begin
    case(selector)
    
    64'hdeadbeef00000000: Q <=input1;
    64'habcdbeef00000000: Q <=input2;
    64'hfeedbeef00000000: Q <=input3;
    default : Q <= selector;
    endcase
  end
endmodule




module shiftRegiste_4 #(
    parameter PACKET_LENGTH = 32
  )(
    input  reset, input  clk, input  clear_tx_seqnum, 
    input  m_axis_data_tlast, input  [31:0] m_axis_data_tdata,
    input  m_axis_data_tvalid, output  m_axis_data_tready,
    input  [127:0] header_reg,
    output  s_axis_data_tlast, output  [31:0] s_axis_data_tdata,
    output  s_axis_data_tvalid, input  s_axis_data_tready,
    output  [127:0] s_axis_data_tuser
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
  assign s_axis_data_tuser = header_reg;     
endmodule

module timestamper #(
    parameter HEADER = 2'b00,
    parameter PACKET_LENGTH = 64,
    parameter TIME_LENGTH = 64
  )(
    input wire reset, input wire clk, 
    input  [PACKET_LENGTH-1:0] i_tdata, input  i_tlast, input  i_tvalid, output i_tready,
    output [PACKET_LENGTH-1:0] o_tdata, output o_tlast, output o_tvalid, input  o_tready
  );
  
  localparam inital_state = 3'd0,
             counting_state = 3'd1,
             stop_state  = 3'd2,
             wait_until_send_state = 3'd3,
             send_timestamp_header = 3'd4,
             send_timestamp_data   = 3'd5;

  
  reg [2:0] state = 2'd0;
  reg [2:0] next_state = 2'd0;
  reg [2:0] Enable_counter = 2'd0;
  reg id_captured = 0;
  reg [31:0] stream_id = 0;
  reg counter_stop = 0;
  reg time_stamp_tvalid = 0;
  reg time_stamp_tlast = 0;
  reg time_stamp_tready = 0;
  wire ready2send_time_stamp =(!i_tvalid) && counter_stop && o_tready;
  reg sedning_timestamp = 0;
  reg [63:0] counter = 0;
  wire [63:0] header = {4'h0,12'h0,16'd16,stream_id};
  reg [63:0] time_stamp_packet = 0;

  //Conditional state transistion
  always @(*) begin
    case(state)
      inital_state: begin
        if(i_tdata == 'hdeadbeef ) begin
          next_state <= counting_state;
        end else begin
          next_state <= inital_state;
        end  
      end

      counting_state: begin
        if(i_tdata == 'habcdbeef) begin
          next_state <= wait_until_send_state;
        end else begin
          next_state <= counting_state;
        end
      end


      wait_until_send_state: begin
        if(ready2send_time_stamp) begin
          next_state <= send_timestamp_header;
        end else begin
          next_state <= wait_until_send_state;
        end 
      end

      send_timestamp_header: begin
          next_state <= send_timestamp_data;
      end

      send_timestamp_data: begin
          next_state <= inital_state;
      end

    endcase
  end

  //Contorl signal 
  always @(*) begin
    case(state)
      inital_state: begin
        Enable_counter <= 2'd0;
        time_stamp_tlast <= 0;
        counter_stop <= 0;
        time_stamp_tvalid <= 0;
        time_stamp_tlast <= 0;
        sedning_timestamp <= 0;
        

      end

      counting_state: begin
        Enable_counter <= 2'd1;
        id_captured = 1;
      end


      wait_until_send_state: begin
        time_stamp_packet <= header;
        Enable_counter <= 2'd2;
        counter_stop <= 1;
        sedning_timestamp <= 1;
        
      end

      send_timestamp_header: begin

        time_stamp_tvalid <= 1;
        
      end

      send_timestamp_data: begin
        time_stamp_packet <= {HEADER,counter[PACKET_LENGTH-2-1:0]};
        time_stamp_tlast <= 1;
      end

      endcase
  end

  //Counter
  always @(posedge clk) begin 
    if (reset| (Enable_counter == 2'd0)) begin
      counter <= 0;
    end else if (Enable_counter == 2'd1) begin 
      counter <= counter + 1;
    end 
  end
  
  //Synchronous state transistion 
  always @(posedge clk or negedge reset) begin 
    if (reset) begin
      state <= inital_state;
    end else  begin 
      state <= next_state;
    end 
  end

  always @(posedge i_tvalid ) begin
    if(!id_captured) begin
      stream_id <= i_tdata[31:0];
    end
  end
  //Send our timestamp packet only when Upper stream is not sending, lower stream is ready, and our time_steamp is ready
  assign o_tdata = (sedning_timestamp) ? time_stamp_packet : i_tdata;
  assign o_tlast = (time_stamp_tlast) ? 1: i_tlast;
  assign o_tvalid = (time_stamp_tvalid) ? 1: i_tvalid;
  //tell Upper stream not to send when timestamper is sending
  assign i_tready = (ready2send_time_stamp) ? 0:o_tready;

endmodule

