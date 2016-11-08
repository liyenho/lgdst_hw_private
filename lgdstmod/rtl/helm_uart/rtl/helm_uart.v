/*
 *
 *
 */

`timescale 1ns / 10ps

module helm_uart #(
  parameter         REF_CLK_FREQ = 50000000,    // 50MHz
  parameter         UART_BAUD_RATE = 115200,    // i.e., bit width = 8.68us
  parameter         CLK_CNT_BIT = 16, 
  parameter         PREAMBLE = 32'hAA995566
)(
  input         rst_b,
  input         clk,

  input         rxd, 
  output        txd, 

  output        usr_mem_cs, 
  output  [7:0] usr_mem_page,
  output  [7:0] usr_mem_offset,
  output        usr_mem_wr_en,
  output  [7:0] usr_mem_wr_data,
  output  [7:0] usr_mem_wr_msk,
  output        usr_mem_rd_en,
  input   [7:0] usr_mem_rd_data,
  input         usr_mem_ack, 

  output reg [7:0] alive_cntr
);

  localparam C_MSG_BLK_WRITE   = 8'h00,
             C_MSG_BYTE_WRITE  = 8'h01,
             C_MSG_BLK_READ    = 8'h02,
             C_MSG_BLK_WR_VER  = 8'h03,
             C_MSG_BLK_WR_CONF = 8'h80,
             C_MSG_BLK_RD_STAT = 8'h81;

  wire          tx_wr;
  wire    [7:0] tx_data;
  wire          tx_busy;

  wire          rx_vld; 
  wire    [7:0] rx_data;
  
  wire    [7:0] msg_type, 
                msg_seq_no, 
                msg_page, 
                msg_offset, 
                msg_data_length, 
                msg_chksum, 
                msg_data_adr, 
                msg_data;
  wire          msg_data_wr,
                msg_chksum_err, 
                msg_exec;

  wire          tx_blkrd;
  wire          tx_blkwr;
  wire    [7:0] data_len;

  wire          rd_mem_cs;
  wire    [7:0] rd_mem_page, rd_mem_offset;
  wire    [7:0] wr_mem_page, wr_mem_offset;

  wire          alive_cntr_inc = (msg_page == 8'd1)? tx_blkrd:1'b0;
  always @(posedge clk or negedge rst_b)
  begin
    if (~rst_b)
      alive_cntr <= 'd0;
    else
      alive_cntr <= alive_cntr + {7'd0, alive_cntr_inc}; 
  end

  helm_ctrl #(
    .C_MSG_BLK_WRITE (C_MSG_BLK_WRITE),
    .C_MSG_BYTE_WRITE(C_MSG_BYTE_WRITE),
    .C_MSG_BLK_READ  (C_MSG_BLK_READ),
    .C_MSG_BLK_WR_VER(C_MSG_BLK_WR_VER),
    .C_MSG_BLK_WR_CONF(C_MSG_BLK_WR_CONF),
    .C_MSG_BLK_RD_STAT(C_MSG_BLK_RD_STAT)
  )i_msg_ctrl(
    .clk(clk),                  .rst_b(rst_b),

    .msg_type(msg_type),        
    .msg_page(msg_page),        .msg_offset(msg_offset), 
    .msg_exec(msg_exec),        .msg_chksum_err(msg_chksum_err),

    .msg_data_wr(msg_data_wr),  .msg_data_adr(msg_data_adr),
    .msg_data(msg_data), 

    .tx_blkrd(tx_blkrd),        .data_len(data_len),
    .tx_blkwr(tx_blkwr), 

    .usr_mem_wr_en(usr_mem_wr_en),
    .usr_mem_page(wr_mem_page), .usr_mem_offset(wr_mem_offset),
    .usr_mem_wr_data(usr_mem_wr_data), 
    .usr_mem_wr_msk(usr_mem_wr_msk)
  );

  helm_msg_rcv  #(
    .PREAMBLE(PREAMBLE), 

    .C_MSG_BLK_WRITE (C_MSG_BLK_WRITE),
    .C_MSG_BYTE_WRITE(C_MSG_BYTE_WRITE),
    .C_MSG_BLK_READ  (C_MSG_BLK_READ),
    .C_MSG_BLK_WR_VER(C_MSG_BLK_WR_VER),
    .C_MSG_BLK_WR_CONF(C_MSG_BLK_WR_CONF),
    .C_MSG_BLK_RD_STAT(C_MSG_BLK_RD_STAT)
  )i_msg_rcv(
    .clk(clk),                  .rst_b(rst_b),

    .rx_vld(rx_vld),            .rx_data(rx_data), 

    .msg_type(msg_type),        .msg_seq_no(msg_seq_no), 
    .msg_page(msg_page),        .msg_offset(msg_offset), 
    .msg_data_length(msg_data_length), 
    .msg_chksum(msg_chksum), 
    
    .msg_data_wr(msg_data_wr),  .msg_data_adr(msg_data_adr),
    .msg_data(msg_data),
    .msg_exec(msg_exec),        .msg_chksum_err(msg_chksum_err)
  );

  helm_msg_snd  #(
    .PREAMBLE(PREAMBLE)
  )i_msg_snd(
    .clk(clk),                  .rst_b(rst_b),

    .tx_wr(tx_wr),              .tx_busy(tx_busy), 
    .tx_data(tx_data), 

    .tx_blkrd(tx_blkrd),        .tx_blkwr(tx_blkwr),
    .data_len(data_len), 

    .msg_type(msg_type),        .msg_seq_no(msg_seq_no), 
    .msg_page(msg_page),        .msg_offset(msg_offset), 

    .usr_mem_cs(rd_mem_cs),     .usr_mem_rd_en(usr_mem_rd_en), 
    .usr_mem_page(rd_mem_page), .usr_mem_offset(rd_mem_offset),
    .usr_mem_data(usr_mem_rd_data),
    .usr_mem_ack(usr_mem_ack)
  );

  assign usr_mem_cs = rd_mem_cs | usr_mem_wr_en;
  assign {usr_mem_page, usr_mem_offset} = (rd_mem_cs)? {rd_mem_page, rd_mem_offset}:
                                                       {wr_mem_page, wr_mem_offset}; 

  uart_top  #(
    .REF_CLK_FREQ(REF_CLK_FREQ),    .CLK_CNT_BIT(CLK_CNT_BIT),
    .UART_BAUD_RATE(UART_BAUD_RATE)
  ) i_uart (
    .rst_b(rst_b),              .clk(clk),
    
    .rxd(rxd),                  .txd(txd), 

    .tx_wr(tx_wr),              .tx_busy(tx_busy), 
    .tx_data(tx_data), 

    .rx_vld(rx_vld),            .rx_data(rx_data)
  );

endmodule
