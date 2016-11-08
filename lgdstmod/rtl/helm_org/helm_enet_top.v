//------------------------------------------------------------------------------
// Copyright 2010 (c) Sculpture Networks
//
// Description:  This module process helm messages via udp/ip/enet.
//------------------------------------------------------------------------------
// clk: System clock
//
// rst_b: System synchronous reset
//
//------------------------------------------------------------------------------
module helm_enet_top(
    input             clk,
    input             rst_b,
    
    input      [31:0] ack_timeout_lim, //number of clocks to wait for read
    
    input      [47:0] dst_mac_addr,
    input      [31:0] dst_ip_addr,
    input      [15:0] dst_port,
    
    input      [31:0] listened_ip_addr1,
    input      [31:0] listened_ip_addr2,
    input      [15:0] listened_port_helm,
    input      [15:0] listened_port_udp,
    
    //statistics
    output            msg_processing,
    output            msg_dropped,
    output            helm_ready,
    
    //MAC interface
    output            mac_tx_src_rdy_n,
    input             mac_tx_dst_rdy_n,
    output            mac_tx_eof_n,
    output            mac_tx_sof_n,
    output      [7:0] mac_tx_data,
    
    input       [3:0] mac_rx_fifo_status,
    output            mac_rx_dst_rdy_n,
    input             mac_rx_src_rdy_n,
    input             mac_rx_eof_n,
    input             mac_rx_sof_n,
    input       [7:0] mac_rx_data,
    
    //user mem interface
    output            usr_mem_cs,
    output            usr_mem_rd_en,
    output            usr_mem_wr_en,
    output      [7:0] usr_mem_page,
    output      [7:0] usr_mem_offset,
    output      [7:0] usr_mem_wr_data,
    input       [7:0] usr_mem_rd_data,
    input             usr_mem_ack,
    
    //rx udp payload
    input             udp_payload_wr_ok,
    output            udp_payload_wr_en,
    output      [7:0] udp_payload_wr_data,
    output     [15:0] udp_payload_length,
    output            udp_payload_sof,
    output            udp_payload_eof,
    
    output    [127:0] test_out
);

wire              req_msg_tx;
wire              msg_tx_rdy;
wire        [7:0] msg_type;
wire        [7:0] msg_seq_no;
wire        [7:0] msg_page;
wire        [7:0] msg_offset;
wire        [7:0] msg_data_length;
wire       [15:0] rx_src_port;

//msg buffer
wire              msg_mem_wr_en;
wire              msg_mem_rd_en;
wire       [10:0] msg_mem_addr;
wire        [7:0] msg_mem_wr_data;
wire        [7:0] msg_mem_rd_data;

wire              usr_mem_rd_en_rx, usr_mem_rd_en_tx;
wire        [7:0] usr_mem_page_rx, usr_mem_page_tx;
wire        [7:0] usr_mem_offset_rx, usr_mem_offset_tx;
wire              usr_mem_cs_tx, usr_mem_cs_rx;

assign usr_mem_cs     = (msg_tx_rdy)? usr_mem_cs_rx     : usr_mem_cs_tx;
assign usr_mem_rd_en  = (msg_tx_rdy)? usr_mem_rd_en_rx  : usr_mem_rd_en_tx;
assign usr_mem_page   = (msg_tx_rdy)? usr_mem_page_rx   : usr_mem_page_tx;
assign usr_mem_offset = (msg_tx_rdy)? usr_mem_offset_rx : usr_mem_offset_tx;

helm_msg_send msg_send(
    .clk                 (clk),
    .rst_b               (rst_b),
    
    .ack_timeout_lim     (ack_timeout_lim),
    
    .dst_mac_addr        (dst_mac_addr),
    .dst_ip_addr         (dst_ip_addr),
    .dst_port            (rx_src_port),
    
    .req_msg_tx          (req_msg_tx     ),
    .msg_tx_rdy          (msg_tx_rdy     ),
    .msg_type            (msg_type       ),
    .msg_seq_no          (msg_seq_no     ),
    .msg_page            (msg_page       ),
    .msg_offset          (msg_offset     ),
    .msg_data_length     (msg_data_length),
    
    .mac_tx_src_rdy_n    (mac_tx_src_rdy_n),
    .mac_tx_dst_rdy_n    (mac_tx_dst_rdy_n),
    .mac_tx_eof_n        (mac_tx_eof_n    ),
    .mac_tx_sof_n        (mac_tx_sof_n    ),
    .mac_tx_data         (mac_tx_data     ),
    
    .usr_mem_cs          (usr_mem_cs_tx    ),
    .usr_mem_rd_en       (usr_mem_rd_en_tx ),
    .usr_mem_page        (usr_mem_page_tx  ),
    .usr_mem_offset      (usr_mem_offset_tx),
    .usr_mem_data        (usr_mem_rd_data  ),
    .usr_mem_ack         (usr_mem_ack      )
);

helm_msg_recv msg_recv(
    .clk                (clk),
    .rst_b              (rst_b),
    
    .listened_ip_addr1  (listened_ip_addr1),
    .listened_ip_addr2  (listened_ip_addr2),
    .listened_port_helm (listened_port_helm),
    .listened_port_udp  (listened_port_udp),
    
    .mac_rx_fifo_status (mac_rx_fifo_status),
    .mac_rx_dst_rdy_n   (mac_rx_dst_rdy_n  ),
    .mac_rx_src_rdy_n   (mac_rx_src_rdy_n  ),
    .mac_rx_eof_n       (mac_rx_eof_n      ),
    .mac_rx_sof_n       (mac_rx_sof_n      ),
    .mac_rx_data        (mac_rx_data       ),
    
    .msg_mem_wr_en      (msg_mem_wr_en  ),
    .msg_mem_rd_en      (msg_mem_rd_en  ),
    .msg_mem_addr       (msg_mem_addr   ),
    .msg_mem_wr_data    (msg_mem_wr_data),
    .msg_mem_rd_data    (msg_mem_rd_data),
    
    .helm_ready         (helm_ready     ),
    .msg_processing     (msg_processing ),
    .msg_dropped        (msg_dropped    ),
    
    .req_msg_tx         (req_msg_tx     ),
    .msg_tx_rdy         (msg_tx_rdy     ),
    .msg_type           (msg_type       ),
    .msg_seq_no         (msg_seq_no     ),
    .msg_page           (msg_page       ),
    .msg_offset         (msg_offset     ),
    .msg_data_length    (msg_data_length),
    .rx_src_port        (rx_src_port    ),
    
    .usr_mem_cs         (usr_mem_cs_rx    ),
    .usr_mem_rd_en      (usr_mem_rd_en_rx ),
    .usr_mem_wr_en      (usr_mem_wr_en    ),
    .usr_mem_page       (usr_mem_page_rx  ),
    .usr_mem_offset     (usr_mem_offset_rx),
    .usr_mem_wr_data    (usr_mem_wr_data  ),
    .usr_mem_rd_data    (usr_mem_rd_data  ),
    .usr_mem_ack        (usr_mem_ack      ),
    
    .udp_payload_wr_ok   (udp_payload_wr_ok  ),
    .udp_payload_wr_en   (udp_payload_wr_en  ),
    .udp_payload_wr_data (udp_payload_wr_data),
    .udp_payload_length  (udp_payload_length ),
    .udp_payload_sof     (udp_payload_sof    ),
    .udp_payload_eof     (udp_payload_eof    )
);

dpram_2048x8 msg_mem(
    .clka  (clk),
    .clkb  (clk),
    .wea   (msg_mem_wr_en),
    .web   (1'b0),
    .addra (msg_mem_addr),
    .addrb ('b0),
    .douta (msg_mem_rd_data),
    .doutb (),
    .dina  (msg_mem_wr_data),
    .dinb  ()
);

//----------------------------------------------------------------------------//
//                                  Debug                                     //
//----------------------------------------------------------------------------//
wire       [35:0] chipscope_control;
wire      [127:0] chipscope_trig;

//chipscope_icon icon(
//    .CONTROL0 (chipscope_control)
//);
//
//chipscope_ila_1024x128 ila(
//    .CONTROL (chipscope_control),
//    .CLK     (clk),
//    .TRIG0   (chipscope_trig[127:0])
//);

assign chipscope_trig[0] = msg_processing;
assign chipscope_trig[1] = mac_tx_src_rdy_n;
assign chipscope_trig[2] = mac_tx_dst_rdy_n;
assign chipscope_trig[3] = mac_tx_eof_n;
assign chipscope_trig[4] = mac_tx_sof_n;
assign chipscope_trig[12:5] = mac_tx_data;

assign chipscope_trig[13] = mac_rx_dst_rdy_n;
assign chipscope_trig[14] = mac_rx_src_rdy_n;
assign chipscope_trig[15] = mac_rx_eof_n;
assign chipscope_trig[16] = mac_rx_sof_n;
assign chipscope_trig[24:17] = mac_rx_data;

assign chipscope_trig[25] = usr_mem_rd_en;
assign chipscope_trig[26] = usr_mem_wr_en;
assign chipscope_trig[34:27] = usr_mem_page;
assign chipscope_trig[42:35] = usr_mem_offset;
assign chipscope_trig[50:43] = usr_mem_wr_data;
assign chipscope_trig[58:51] = usr_mem_rd_data;

assign chipscope_trig[59] = req_msg_tx;
assign chipscope_trig[60] = msg_tx_rdy;
assign chipscope_trig[68:61] = msg_type;
assign chipscope_trig[76:69] = msg_seq_no;
assign chipscope_trig[84:77] = msg_page;
assign chipscope_trig[92:85] = msg_offset;
assign chipscope_trig[100:93] = msg_data_length;

assign chipscope_trig[101] = msg_mem_wr_en;
assign chipscope_trig[102] = msg_mem_rd_en;
assign chipscope_trig[110:103] = msg_mem_addr[7:0];
assign chipscope_trig[111] = usr_mem_cs;
assign chipscope_trig[119:112] = msg_mem_wr_data;
assign chipscope_trig[127:120] = msg_mem_rd_data;

assign test_out = chipscope_trig;
endmodule

