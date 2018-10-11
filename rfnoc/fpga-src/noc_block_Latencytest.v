
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
module noc_block_Latencytest #(
  parameter NOC_ID = 64'h5555555566666677,
  parameter STR_SINK_FIFOSIZE = 11)
(
  input bus_clk, input bus_rst,
  input radio_clk, input radio_rst,
  input ce_clk, input ce_rst,
  input  [63:0] i_tdata, input  i_tlast, input  i_tvalid, output i_tready,
  output [63:0] o_tdata, output o_tlast, output o_tvalid, input  o_tready,
  output [63:0] debug, input [63:0] timekeeper_share
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

  wire [63:0]  str_sink_tdata;
  wire         str_sink_tlast, str_sink_tvalid, str_sink_tready;

  wire [63:0] str_src_tdata;
  wire        str_src_tlast, str_src_tvalid, str_src_tready;

  wire [15:0] src_sid;
  wire [15:0] next_dst_sid, resp_out_dst_sid;
  wire [15:0] resp_in_dst_sid;

  wire        clear_tx_seqnum;

  noc_shell #(
    .NOC_ID(NOC_ID),
    .STR_SINK_FIFOSIZE(STR_SINK_FIFOSIZE))
  noc_shell (
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .i_tdata(i_tdata), .i_tlast(i_tlast), .i_tvalid(i_tvalid), .i_tready(i_tready),
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
  wire [127:0] m_axis_data_tuser;
  wire        m_axis_data_tlast;
  wire        m_axis_data_tvalid;
  wire        m_axis_data_tready;
  
  wire [31:0] s_axis_data_tdata;
  wire [127:0] s_axis_data_tuser;
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
  localparam [7:0] SR_SPP_SIZE = SR_USER_REG_BASE;
  localparam [7:0] SR_PACKET_LIMIT = SR_USER_REG_BASE + 8'd1;
  localparam [7:0] SR_PACKET_AVG_SIZE = SR_USER_REG_BASE + 8'd2;
  localparam [7:0] SR_PACKET_SHIFT = SR_USER_REG_BASE + 8'd3;

  wire [31:0] spp_size;
  setting_reg #(
    .my_addr(SR_SPP_SIZE), .awidth(8), .width(32), .at_reset(64))
  sr_spp_size (
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(spp_size), .changed());

  wire [31:0] packet_limit;
  setting_reg #(
    .my_addr(SR_PACKET_LIMIT), .awidth(8), .width(32), .at_reset(10000))
  sr_packet_limit (
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(packet_limit), .changed());
  
  wire [31:0] packet_avg_size;
  setting_reg #(
    .my_addr(SR_PACKET_AVG_SIZE), .awidth(8), .width(32), .at_reset(16))
  sr_packet_avg_size (
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(packet_avg_size), .changed());
  
  wire [31:0] packet_shift;
  setting_reg #(
    .my_addr(SR_PACKET_SHIFT), .awidth(8), .width(32), .at_reset(4))
  sr_packet_shift (
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(packet_shift), .changed());
  

  // Readback registers
  // rb_stb set to 1'b1 on NoC Shell
  always @(posedge ce_clk) begin
    case(rb_addr)
      8'd0 : rb_data <= {32'd0, spp_size};
      8'd1 : rb_data <= {32'd0, packet_limit};
      8'd2 : rb_data <= {32'd0, packet_avg_size};
      8'd3 : rb_data <= {32'd0, packet_shift};
      default : rb_data <= 64'h0BADC0DE0BADC0DE;
    endcase
  end

  wire eob = 1'b0;
  wire [15:0] packet_length = 16'h0;
  reg [11:0] seqnum_cnt = 12'h0;
  wire [63:0] header_wire = {2'b00,1'b1,eob,seqnum_cnt,packet_length, src_sid,next_dst_sid};
  
  //Avg latency block
  latencyReport #(.PACKET_LENGTH(32))
    latencyReport(
      .ce_clk(ce_clk),
      .ce_rst(ce_rst),
      .radio_clk(radio_clk),
      .radio_rst(radio_rst), 
      .m_axis_data_tlast(m_axis_data_tlast), .m_axis_data_tdata(m_axis_data_tdata),
      .m_axis_data_tvalid(m_axis_data_tvalid), .m_axis_data_tready(m_axis_data_tready),
      .m_axis_data_tuser(m_axis_data_tuser),
      .s_axis_data_tlast(s_axis_data_tlast), .s_axis_data_tdata(s_axis_data_tdata),
      .s_axis_data_tvalid(s_axis_data_tvalid), .s_axis_data_tready(s_axis_data_tready),
      .s_axis_data_tuser(s_axis_data_tuser),
      .timekeeper(timekeeper_share), .header(header_wire),
      .SPP_SIZE(spp_size), .PACKET_LIMIT(packet_limit),
      .PACKET_AVG_SIZE(packet_avg_size), .PACKET_SHIFT(packet_shift)
    );

  /*
  //Pipelined
  wire [31:0] pipe_in_tdata;
  wire [127:0] pipe_in_tuser;
  wire pipe_in_tvalid, pipe_in_tlast, pipe_in_tready;
  wire [31:0] pipe_out_tdata;
  wire [127:0] pipe_out_tuser;
  wire pipe_out_tvalid, pipe_out_tlast, pipe_out_tready;

  axi_fifo_flop #(.WIDTH(32+1+128))
    piepeline0_axi_fifio_flop(
      .clk(ce_clk),
      .reset(ce_rst),
      .clear(clear_tx_seqnum),
      .i_tdata({m_axis_data_tlast,m_axis_data_tdata,m_axis_data_tuser}),
      .i_tvalid(m_axis_data_tvalid),
      .i_tready(m_axis_data_tready),
      .o_tdata({pipe_in_tlast,pipe_in_tdata,pipe_in_tuser}),
      .o_tvalid(pipe_in_tvalid),
      .o_tready(pipe_in_tready)
    );
  
  //Avg latency block
  latencyReport #(.PACKET_LENGTH(32))
    latencyReport(
      .ce_clk(ce_clk),
      .ce_rst(ce_rst),
      .radio_clk(radio_clk),
      .radio_rst(radio_rst), 
      .m_axis_data_tlast(pipe_in_tlast), .m_axis_data_tdata(pipe_in_tdata),
      .m_axis_data_tvalid(pipe_in_tvalid), .m_axis_data_tready(pipe_in_tready),
      .m_axis_data_tuser(pipe_in_tuser),
      .s_axis_data_tlast(pipe_out_tlast), .s_axis_data_tdata(pipe_out_tdata),
      .s_axis_data_tvalid(pipe_out_tvalid), .s_axis_data_tready(pipe_out_tready),
      .s_axis_data_tuser(pipe_out_tuser),
      .timekeeper(timekeeper), .header(header_wire),
      .SPP_SIZE(spp_size), .PACKET_LIMIT(packet_limit),
      .PACKET_AVG_SIZE(packet_avg_size), .PACKET_SHIFT(packet_shift)
    );

  
  axi_fifo_flop #(.WIDTH(32+1+128))
    piepeline1_axi_fifio_flop(
      .clk(ce_clk),
      .reset(ce_rst),
      .clear(clear_tx_seqnum),
      .i_tdata({pipe_out_tlast,pipe_out_tdata,pipe_out_tuser}),
      .i_tvalid(pipe_out_tvalid),
      .i_tready(pipe_out_tready),
      .o_tdata({s_axis_data_tlast,s_axis_data_tdata,s_axis_data_tuser}),
      .o_tvalid(s_axis_data_tvalid),
      .o_tready(s_axis_data_tready)
    );
    */
endmodule

module latencyReport #(
  parameter PACKET_LENGTH = 32
)(
  input ce_clk, input ce_rst, 
  input radio_clk, input radio_rst,
  input m_axis_data_tlast, input [PACKET_LENGTH-1:0] m_axis_data_tdata,
  input m_axis_data_tvalid, output m_axis_data_tready,
  input [127:0] m_axis_data_tuser,
  output s_axis_data_tlast, output [PACKET_LENGTH-1:0] s_axis_data_tdata,
  output s_axis_data_tvalid, input s_axis_data_tready,
  output [127:0] s_axis_data_tuser,
  input [63:0] timekeeper, input [63:0] header,
  input [31:0] SPP_SIZE, input [31:0] PACKET_LIMIT,
  input [31:0] PACKET_AVG_SIZE, input [31:0] PACKET_SHIFT 
);
  
  reg [15:0] packet_counter = 16'h0;
  reg [31:0] packet_limit_counter = 32'h0;
  reg second_round = 1'b0;
  reg ready2send = 1'b0;
  reg [64:0] avg_packet_latency = 65'h0;
  reg [64:0] last_avg_packet_latency = 65'h0;
  wire [63:0] MIN_LATENCY = {32'h0,SPP_SIZE};
  wire [63:0] syn_timekeeper;
  (* dont_touch = "true",mark_debug ="true" *) wire [63:0] header_timestamp = m_axis_data_tuser[63:0];
  (* dont_touch = "true",mark_debug ="true" *) wire send_report =  (ready2send == 1);

  reg [4:0] fsm_count_state = 5'b00000;
  reg [4:0] next_count_state = 5'b00000;
  localparam [4:0] ST_COUNT_IDLE = 5'b00001;
  localparam [4:0] ST_RECOUNT = 5'b00010;
  localparam [4:0] ST_WAITING_TLAST = 5'b00100;
  localparam [4:0] ST_GUARD = 5'b01000;
  localparam [4:0] ST_STOP = 5'b10000;

  reg [2:0] fsm_send_state = 3'b000;
  reg [2:0] next_send_state = 3'b000;
  localparam [2:0] ST_SEND_IDLE = 3'b001;
  localparam [2:0] ST_SEND_MARKER = 3'b010;
  localparam [2:0] ST_SEND_PACKET_LATENCY = 3'b100;



  always @(posedge ce_clk or negedge ce_rst ) begin
    if(ce_rst) begin
      second_round <= 1'b0;
    end else if (ready2send == 1 & second_round == 1'b0) begin
      second_round <= 1'b1;
    end
  end 
  
  wire slow_tready,fast_valid;
  axi_fifo_2clk #(.WIDTH(64), .SIZE(5)) sync_fifo (
    .i_aclk(radio_clk), .o_aclk(ce_clk), .reset(radio_rst),
    .i_tdata({timekeeper}), .i_tvalid(1), .i_tready(slow_tready),
    .o_tdata({syn_timekeeper}), .o_tvalid(fast_valid), .o_tready(1)
  );
  
  
  //Counting FSM
  //Conditional state transistion
  always @(*) begin
    
    case(fsm_count_state)
      ST_COUNT_IDLE: begin
        if(m_axis_data_tvalid == 1'b1) begin
          next_count_state = ST_RECOUNT;
        end else begin
          next_count_state = ST_COUNT_IDLE;
        end 
      end

      ST_RECOUNT: begin
        next_count_state = ST_WAITING_TLAST;
      end

      ST_WAITING_TLAST: begin
        if (m_axis_data_tvalid  == 1'b1 & m_axis_data_tlast  == 1'b1) begin   
          if ((packet_counter +1) == PACKET_AVG_SIZE) begin
            if ((packet_limit_counter +1) == PACKET_LIMIT) begin
              next_count_state = ST_STOP;
            end else begin
              next_count_state = ST_RECOUNT;
            end 
          end else begin
            next_count_state = ST_GUARD;
          end
        end else begin
          next_count_state = ST_WAITING_TLAST;
        end 
          
      end 

      ST_GUARD: begin
        next_count_state = ST_WAITING_TLAST;
      end

      ST_STOP: begin
        next_count_state = ST_STOP;
      end

      default: begin
        next_count_state = ST_COUNT_IDLE;
      end 

    endcase
  end

  always @(posedge ce_clk or negedge ce_rst ) begin
    if (ce_rst) begin
      ready2send <= 0;
      avg_packet_latency <= 65'h0;
      packet_counter <= 16'h0; 
      packet_limit_counter <= 32'h0;
      last_avg_packet_latency <= 64'h0;
    end else begin
      case(fsm_count_state)
        ST_COUNT_IDLE: begin
          ready2send <= 0;
          avg_packet_latency <= 65'h0;
          packet_counter <= 16'h0; 
        end

        ST_RECOUNT: begin
          ready2send <= 0;
          avg_packet_latency <= 65'h0;
          packet_counter <= 16'h0; 
        end

        ST_WAITING_TLAST: begin
          if (m_axis_data_tvalid  == 1'b1 & m_axis_data_tlast  == 1'b1 ) begin   
            if ((packet_counter +1) == PACKET_AVG_SIZE) begin
                ready2send <= 1;
                packet_limit_counter <=  packet_limit_counter + 1;
                avg_packet_latency <= avg_packet_latency + syn_timekeeper - header_timestamp;
                last_avg_packet_latency <= (avg_packet_latency + syn_timekeeper - header_timestamp) >> PACKET_SHIFT;
            end else begin
              packet_counter <= packet_counter + 1;
              avg_packet_latency <= avg_packet_latency + syn_timekeeper - header_timestamp;
            end 
          end
        end 

        ST_GUARD: begin
          
        end

        ST_STOP: begin
          ready2send <= 0;
        end

        default: begin
          ready2send <= 0;
          avg_packet_latency <= 65'h0;
          packet_counter <= 16'h0;
        end

      endcase
    end 
  end

  

  //Synchronous state transistion
  always @(posedge ce_clk or negedge ce_rst ) begin
    if(ce_rst) begin
      fsm_count_state <= ST_COUNT_IDLE;
    end else begin
      fsm_count_state <= next_count_state;
    end
  end

  //Sending FSM
  always @(*) begin
    case(fsm_send_state)
      ST_SEND_IDLE: begin
        if(ready2send == 1'b1) begin
          next_send_state = ST_SEND_MARKER;
        end else begin
          next_send_state = ST_SEND_IDLE;
        end
      end

      ST_SEND_MARKER: begin 
        if(s_axis_data_tready) begin
          next_send_state = ST_SEND_PACKET_LATENCY;
        end else begin
          next_send_state = ST_SEND_MARKER;
        end
      end 

      ST_SEND_PACKET_LATENCY: begin
        next_send_state = ST_SEND_IDLE;
      end

      default: begin
        next_send_state = ST_SEND_IDLE;
      end 
    endcase
  end
     
  //Synchronous state transistion
  always @(posedge ce_clk or negedge ce_rst ) begin
    if(ce_rst) begin
      fsm_send_state <= ST_SEND_IDLE;
    end else begin
      fsm_send_state <= next_send_state;
    end
  end

  assign s_axis_data_tlast = (fsm_send_state == ST_SEND_PACKET_LATENCY) ? 1:0;
  assign s_axis_data_tvalid = (((fsm_send_state == ST_SEND_MARKER) | (fsm_send_state == ST_SEND_PACKET_LATENCY)) & s_axis_data_tready) ? 1:0;
  assign s_axis_data_tdata =  (fsm_send_state == ST_SEND_PACKET_LATENCY) ? last_avg_packet_latency[31:0] : (fsm_send_state == ST_SEND_MARKER) ? 32'habcdbeef:0 ;
  assign m_axis_data_tready =  1;
  assign s_axis_data_tuser = {header,syn_timekeeper[63:0]};     
endmodule

