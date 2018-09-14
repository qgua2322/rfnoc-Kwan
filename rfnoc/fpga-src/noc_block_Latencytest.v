
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
  input ce_clk, input ce_rst,
  input  [63:0] i_tdata, input  i_tlast, input  i_tvalid, output i_tready,
  output [63:0] o_tdata, output o_tlast, output o_tvalid, input  o_tready,
  output [63:0] debug, input [63:0] shared_time
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

  wire [63:0]      str_sink_tdata;
  wire         str_sink_tlast, str_sink_tvalid, str_sink_tready;

   wire [63:0]      str_src_tdata;
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
  (* dont_touch = "true",mark_debug ="true" *) wire [31:0] m_axis_data_tdata;
  wire [127:0] m_axis_data_tuser;
  (* dont_touch = "true",mark_debug ="true" *) wire        m_axis_data_tlast;
  (* dont_touch = "true",mark_debug ="true" *) wire        m_axis_data_tvalid;
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
  localparam [7:0] SR_SPP_SHIFT = SR_USER_REG_BASE;
  localparam [7:0] SR_PACKET_LIMIT = SR_USER_REG_BASE + 8'd1;
  localparam [7:0] SR_PACKET_AVG_SIZE = SR_USER_REG_BASE + 8'd2;
  localparam [7:0] SR_PACKET_SHIFT = SR_USER_REG_BASE + 8'd3;

  wire [31:0] spp_shift;
  setting_reg #(
    .my_addr(SR_SPP_SHIFT), .awidth(8), .width(32), .at_reset(16))
  sr_spp_shift (
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(spp_shift), .changed());

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
      8'd0 : rb_data <= {32'd0, spp_shift};
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
  

  
  //Avg latency block with AXI
  latencyReport #(.PACKET_LENGTH(32))
    latencyReport(
      .clk(ce_clk),
      .reset(ce_rst),
      .clear_tx_seqnum(clear_tx_seqnum), 
      .m_axis_data_tlast(m_axis_data_tlast), .m_axis_data_tdata(m_axis_data_tdata),
      .m_axis_data_tvalid(m_axis_data_tvalid), .m_axis_data_tready(m_axis_data_tready),
      .m_axis_data_tuser(m_axis_data_tuser),
      .s_axis_data_tlast(s_axis_data_tlast), .s_axis_data_tdata(s_axis_data_tdata),
      .s_axis_data_tvalid(s_axis_data_tvalid), .s_axis_data_tready(s_axis_data_tready),
      .s_axis_data_tuser(s_axis_data_tuser),
      .timer(shared_time), .header(header_wire),
      .SPP_SHIFT(spp_shift), .PACKET_LIMIT(packet_limit),
      .PACKET_AVG_SIZE(packet_avg_size), .PACKET_SHIFT(packet_shift)
    );

endmodule

module latencyReport #(
    parameter PACKET_LENGTH = 32
  )(
    input  clk, input reset  , input  clear_tx_seqnum, 
    input  m_axis_data_tlast, input  [PACKET_LENGTH-1:0] m_axis_data_tdata,
    input  m_axis_data_tvalid, output  m_axis_data_tready,
    input  [127:0] m_axis_data_tuser,
    output  s_axis_data_tlast, output  [PACKET_LENGTH-1:0] s_axis_data_tdata,
    output  s_axis_data_tvalid, input  s_axis_data_tready,
    output  [127:0] s_axis_data_tuser,
    input  [63:0] timer,input [63:0] header,
    input  [31:0] SPP_SHIFT, input [31:0] PACKET_LIMIT,
    input [31:0] PACKET_AVG_SIZE, input [8:0] PACKET_SHIFT 
  );
  

  reg [15:0] packet_counter = 16'h0;
  reg [31:0] packet_limit_counter = 32'h0;
  reg re_count = 1'b0;
  reg ready2send = 1'b0;
  reg packet_counter_on = 1'b0;
  reg packet_limit_counter_on = 1'b0;
  reg last_tlast = 1'b0;
  reg [63:0] last_timer = 64'h0;
  reg [63:0] avg_packet_latency = 64'h0;
  reg [63:0] avg_sample_latency = 64'h0;
  reg [63:0] last_avg_packet_latency = 64'h0;
  reg [63:0] last_avg_sample_latency = 64'h0;
  wire [15:0] SAMPLE_SHIFT = PACKET_SHIFT + SPP_SHIFT;
  
  
  wire [63:0] time_diff = (timer - m_axis_data_tuser[63:0]);
  reg [2:0] fsm_count_state = 3'd0;
  reg [2:0] next_count_state = 3'd0;
  localparam [2:0] ST_COUNT_IDLE = 3'd0;
  localparam [2:0] ST_RECOUNT = 3'd1;
  localparam [2:0] ST_WAITING_TLAST = 3'd2;
  localparam [2:0] ST_MID = 3'd3;
  localparam [2:0] ST_STOP = 3'd4;

  reg [1:0] fsm_send_state = 2'd0;
  reg [1:0] next_send_state = 2'd0;
  localparam [1:0] ST_SEND_IDLE = 2'd0;
  localparam [1:0] ST_SAMPLE = 2'd1;
  localparam [1:0] ST_PACKET = 2'd2;

  //Debug wire 
  (* dont_touch = "true",mark_debug ="true" *) wire packet_overflow = (time_diff > 16'd5000) ? 1:0;
  (* dont_touch = "true",mark_debug ="true" *) wire packet_underflow = (time_diff < 16'd100) ? 1:0;
  (* dont_touch = "true",mark_debug ="true" *) wire last_packet_underflow = (last_avg_packet_latency_debug < 64'd100) ? 1:0;
  (* dont_touch = "true",mark_debug ="true" *) wire tlast_twich = last_tlast & m_axis_data_tlast;
  (* dont_touch = "true",mark_debug ="true" *) wire time_twich = (last_timer+1) & timer;
  (* dont_touch = "true",mark_debug ="true" *) wire ready2send_debug = ready2send;
  (* dont_touch = "true",mark_debug ="true" *) wire [31:0] packet_limit_counter_debug = packet_limit_counter;
  (* dont_touch = "true",mark_debug ="true" *) wire [15:0] packet_counter_debug = packet_counter;
  (* dont_touch = "true",mark_debug ="true" *) wire [2:0] fsm_count_state_debug =  fsm_count_state;
  (* dont_touch = "true",mark_debug ="true" *) wire [2:0] next_count_state_debug =  next_count_state;
  (* dont_touch = "true",mark_debug ="true" *) wire [15:0] header_length_debug = m_axis_data_tuser[111:96];
  (* dont_touch = "true",mark_debug ="true" *) wire [3:0] header_type_debug = m_axis_data_tuser[127:124];
  (* dont_touch = "true",mark_debug ="true" *) wire [15:0] time_diff_debug = time_diff[15:0];
  (* dont_touch = "true",mark_debug ="true" *) wire [63:0] header_timestamp = m_axis_data_tuser[63:0];
  (* dont_touch = "true",mark_debug ="true" *) wire [63:0] last_avg_packet_latency_debug = last_avg_packet_latency;
  (* dont_touch = "true",mark_debug ="true" *) wire [63:0] avg_packet_latency_debug = avg_packet_latency;

  always @(posedge clk) begin
    last_tlast <= m_axis_data_tlast;
    last_timer <= timer;
  end
  
  always @(posedge clk) begin
    if(reset) begin
      avg_packet_latency <= 64'h0;
      packet_counter <= 16'h0; 
      packet_limit_counter <= 32'h0;
    end else begin
      if(re_count ) begin
        avg_packet_latency <= 64'h0;
        packet_counter <= 16'h0; 
      end else begin
        if(packet_counter_on & fsm_count_state == ST_WAITING_TLAST) begin
          packet_counter <= packet_counter +1;
          avg_packet_latency <= (avg_packet_latency + time_diff);
          if(packet_limit_counter_on) begin
            packet_limit_counter <= packet_limit_counter + 1;
            last_avg_packet_latency <= (avg_packet_latency + time_diff) >> PACKET_SHIFT;
          end 
        end 

        

      end
    end 
  end 
  
  
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
        re_count = 1;
        packet_counter_on = 0;  
        packet_limit_counter_on = 0;
        ready2send = 0;
        if (m_axis_data_tvalid  == 1'b1 &  m_axis_data_tlast  == 1'b0 ) begin
          next_count_state = ST_WAITING_TLAST;
        end else begin
          next_count_state = ST_RECOUNT;
        end
      end

      ST_WAITING_TLAST: begin
        re_count = 0;
        if (m_axis_data_tvalid  == 1'b1 ) begin
          if(m_axis_data_tlast  == 1'b1 ) begin
            packet_counter_on = 1;       
            if (packet_counter == PACKET_AVG_SIZE) begin  
              packet_limit_counter_on = 1;
              ready2send = 1;
              if (packet_limit_counter == PACKET_LIMIT) begin
                next_count_state = ST_STOP;
              end else begin
                next_count_state = ST_RECOUNT;
              end
            end else begin
              next_count_state = ST_MID;
            end 
          end else begin
            next_count_state = ST_WAITING_TLAST;
          end
        end 
      end 

      ST_MID: begin
        packet_counter_on = 0;  
        packet_limit_counter_on = 0;
        if (m_axis_data_tvalid  == 1'b1 &  m_axis_data_tlast  == 1'b0 ) begin
          next_count_state = ST_WAITING_TLAST;
        end else begin
          next_count_state = ST_MID;
        end
      end

      ST_STOP: begin
        next_count_state = ST_STOP;
        ready2send = 0;
        packet_counter_on = 0;  
        packet_limit_counter_on = 0;
      end

    endcase
  end

  

  //Synchronous state transistion
  always @(posedge clk or negedge reset ) begin
    if(reset) begin
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
          next_send_state = ST_SAMPLE;
        end else begin
          next_send_state = ST_SEND_IDLE;
        end
      end

      ST_SAMPLE: begin 
        if(s_axis_data_tready) begin
          next_send_state = ST_PACKET;
        end else begin
          next_send_state = ST_SAMPLE;
        end
      end 

      ST_PACKET: begin
        next_send_state = ST_SEND_IDLE;
      end
    endcase
  end
     
  //Synchronous state transistion
  always @(posedge clk or negedge reset ) begin
    if(reset) begin
      fsm_send_state <= ST_SEND_IDLE;
    end else begin
      fsm_send_state <= next_send_state;
    end
  end

  assign s_axis_data_tlast = (fsm_send_state == ST_PACKET) ? 1:0;
  assign s_axis_data_tvalid = ((fsm_send_state == ST_SAMPLE) | (fsm_send_state == ST_PACKET)) ? 1:0;
  assign s_axis_data_tdata =  (fsm_send_state == ST_PACKET) ? last_avg_packet_latency[31:0] : (fsm_send_state == ST_SAMPLE) ? last_avg_sample_latency[31:0]:0 ;
  assign m_axis_data_tready =  1;
  assign s_axis_data_tuser = {header,timer[63:0]};     
endmodule
