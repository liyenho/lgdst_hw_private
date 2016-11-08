`timescale 1ns /10ps

module config_mem #(
  parameter CONFIG_SIZE = 128,  //in bytes
  parameter STATUS_SIZE = 32,   //in bytes
  parameter CONFIG4_SIZE = 8    //page 4, in bytes
)(  
  input             clk,
  input             rst_b,
  input  [STATUS_SIZE*8-1:0] config_ra,
  output [CONFIG_SIZE*8-1:0] config_rwa,
  input  [CONFIG_SIZE*8-1:0] config_rwa_default, 
  output [CONFIG4_SIZE*8-1:0] proc_stat_page,

  input             spi_wr,
  input             spi_rd,
  input      [11:0] spi_adr,
  input       [7:0] spi_dout,
  output reg  [7:0] spi_din, 

  input       [7:0] rs232_mem_page,
  input       [7:0] rs232_mem_offset,
  input             rs232_mem_wr_en,
  input       [7:0] rs232_mem_wr_data,
  input       [7:0] rs232_mem_wr_msk,
  input             rs232_mem_rd_en,
  output reg  [7:0] rs232_mem_rd_data,
  output reg        rs232_mem_ack, 

  input             proc_rd_word_en,               
  input [13:0]      proc_rd_word_addr,             
  output reg[31:0]  proc_rd_word_data,             
  input             proc_wr_word_en,               
  input [3:0]       proc_wr_byte_indx,             
  input [13:0]      proc_wr_word_addr,             
  input [31:0]      proc_wr_word_data    
);
  reg             rs232_wr;
  reg       [7:0] rs232_wr_adr, rs232_wr_buf;

  reg             write_page0_3;
  reg       [3:0] proc_wr_byte_indx_d1;
  reg       [7:0] proc_wr_word_addr_d1;             
  reg      [31:0] proc_wr_word_data_d1;    

  // configuration
  wire [7:0] config_r[STATUS_SIZE-1:0];
  reg  [7:0] config_rw[CONFIG_SIZE-1:0];
  reg  [7:0] config_page4[CONFIG4_SIZE-1:0];
  wire [7:0] config_rw_default[CONFIG_SIZE-1:0];

  reg write_page4, write_page4_2, write_page4_3;
   
  genvar ci;
  generate for(ci = 0; ci < CONFIG_SIZE; ci = ci + 1) begin: config_gen_block
    assign config_rwa[((ci + 1) * 8 - 1) : (ci * 8)] = config_rw[ci];
    assign config_rw_default[ci] = config_rwa_default[((ci + 1) * 8 - 1) : (ci * 8)];
  end
  endgenerate
  
  generate for(ci = 0; ci < STATUS_SIZE; ci = ci + 1) begin: status_gen_block
    assign config_r[ci] = config_ra[((ci + 1) * 8 - 1) : (ci * 8)];
  end
  endgenerate
  
  generate for(ci = 0; ci < CONFIG4_SIZE; ci = ci + 1) begin: proc_stat_page_block
    assign proc_stat_page[((ci + 1) * 8 - 1) : (ci * 8)] = config_page4[ci];
  end
  endgenerate

  integer i;

  always @(posedge clk or negedge rst_b)
  begin: config_blk
    if (!rst_b)
    begin
      //rs232_wr <= 'd0;
      write_page0_3 <= 'd0;

      for(i = 0; i < CONFIG_SIZE; i = i + 1) begin
        config_rw[i]<= config_rw_default[i];
      end
    end
    else
    begin
      if (write_page0_3) begin
        if (proc_wr_byte_indx[3] == 1'b1)
          config_rw[{proc_wr_word_addr_d1[5:0], 2'b00}] <= proc_wr_word_data_d1[31:24];
            
        if (proc_wr_byte_indx[2] == 1'b1)
          config_rw[{proc_wr_word_addr_d1[5:0], 2'b01}] <= proc_wr_word_data_d1[23:16];
            
        if (proc_wr_byte_indx[1] == 1'b1)
          config_rw[{proc_wr_word_addr_d1[5:0], 2'b10}] <= proc_wr_word_data_d1[15:8];
            
        if (proc_wr_byte_indx[0] == 1'b1)
          config_rw[{proc_wr_word_addr_d1[5:0], 2'b11}] <= proc_wr_word_data_d1[7:0];
      end
      else if (spi_wr && (spi_adr[11:8] == 4'd0))
        config_rw[spi_adr[7:0]] <= spi_dout;
      else if (rs232_mem_wr_en && (rs232_mem_page == 8'd0))
        config_rw[rs232_mem_offset] <= (config_rw[rs232_mem_offset] & (~rs232_mem_wr_msk)) | 
                                       (rs232_mem_wr_data & rs232_mem_wr_msk);
      //else if (rs232_wr) // Second write when write conflict
      //  config_rw[rs232_wr_adr] <= rs232_wr_buf;

      //rs232_wr <= spi_wr & rs232_mem_wr_en & (rs232_mem_page == 8'd0 && spi_adr[11:8] == 4'd0);
      //{rs232_wr_adr, rs232_wr_buf} <= (rs232_mem_wr_en)? {rs232_mem_offset, rs232_mem_wr_data}: 
      //                                             {rs232_wr_adr, rs232_wr_buf};

      write_page0_3 <= proc_wr_word_en && (~|proc_wr_word_addr[7:6]);
      
      proc_wr_byte_indx_d1 <= proc_wr_byte_indx;
      proc_wr_word_addr_d1 <= proc_wr_word_addr;
      proc_wr_word_data_d1 <= proc_wr_word_data;
      write_page4_3 <= proc_wr_word_en && (proc_wr_word_addr[13:6]==8'd4);
      
      if (write_page4_3) begin //only processor can write
          if (proc_wr_byte_indx_d1[3] == 1'b1)
              config_page4[{proc_wr_word_addr_d1[5:0], 2'b00}] <= proc_wr_word_data_d1[31:24];
              
          if (proc_wr_byte_indx[2] == 1'b1)
              config_page4[{proc_wr_word_addr_d1[5:0], 2'b01}] <= proc_wr_word_data_d1[23:16];
              
          if (proc_wr_byte_indx[1] == 1'b1)
              config_page4[{proc_wr_word_addr_d1[5:0], 2'b10}] <= proc_wr_word_data_d1[15:8];
              
          if (proc_wr_byte_indx[0] == 1'b1)
              config_page4[{proc_wr_word_addr_d1[5:0], 2'b11}] <= proc_wr_word_data_d1[7:0];
      end
    end
  end
    
  always @(*)
  begin
    spi_din <= (spi_adr[11:8] == 4'd1)? config_r[spi_adr[7:0]]:
               (spi_adr[11:8] == 4'd4)? config_page4[spi_adr[7:0]]:
                                        config_rw[spi_adr[7:0]];
  end
 
  always @(posedge clk or negedge rst_b)
  begin
    if (~rst_b)
    begin
      rs232_mem_ack <= 'd0;
    end
    else
    begin
      rs232_mem_ack <= rs232_mem_rd_en | rs232_mem_wr_en;
      if (rs232_mem_rd_en)
        rs232_mem_rd_data <= (rs232_mem_page == 8'd1)? config_r[rs232_mem_offset]: 
                             (rs232_mem_page == 8'd4)? config_page4[rs232_mem_offset]:
                                                       config_rw[rs232_mem_offset];
      if (proc_rd_word_en) begin
        if (proc_rd_word_addr[7:6] == 0) begin //page 0
            proc_rd_word_data[31:24] <= config_rw[{proc_rd_word_addr[5:0], 2'b00}];
            proc_rd_word_data[23:16] <= config_rw[{proc_rd_word_addr[5:0], 2'b01}];
            proc_rd_word_data[15:8]  <= config_rw[{proc_rd_word_addr[5:0], 2'b10}];
            proc_rd_word_data[7:0]   <= config_rw[{proc_rd_word_addr[5:0], 2'b11}];
        end
        else if (proc_rd_word_addr[7:6] == 1) begin //page 1
            proc_rd_word_data[31:24] <= config_r[{proc_rd_word_addr[5:0], 2'b00}];
            proc_rd_word_data[23:16] <= config_r[{proc_rd_word_addr[5:0], 2'b01}];
            proc_rd_word_data[15:8]  <= config_r[{proc_rd_word_addr[5:0], 2'b10}];
            proc_rd_word_data[7:0]   <= config_r[{proc_rd_word_addr[5:0], 2'b11}];
        end
        else if (proc_rd_word_addr[13:6] == 4) begin //page 4
            proc_rd_word_data[31:24] <= config_page4[{proc_rd_word_addr[5:0], 2'b00}];
            proc_rd_word_data[23:16] <= config_page4[{proc_rd_word_addr[5:0], 2'b01}];
            proc_rd_word_data[15:8]  <= config_page4[{proc_rd_word_addr[5:0], 2'b10}];
            proc_rd_word_data[7:0]   <= config_page4[{proc_rd_word_addr[5:0], 2'b11}];
        end
      end
    end
  end
endmodule
