`timescale 1ns / 10ps

module spi_prog #(
    parameter       DATECODE = 32'h8002_3456
)(
    input           rst_n, 
    input           clk, 

    input           prog_en, 
    input           spi_clk,
    input           spi_en_n, 
    input           spi_mosi,
    output reg      spi_miso, 

    input           flash_clk
);
    reg     [1:0]   spi_en_sync, spi_clk_sync, spi_mosi_sync;
    reg     [5:0]   spi_shcntr;
    reg    [31:0]   spi_shbuf;
    reg    [31:0]   spi_shobuf;
    reg             spi_cmd_hit = 1'b0, 
                    spi_cmd_cmpl = 1'b0;

    reg             onchip_ctrl_wr, 
                    onchip_ctrl_rd,
                    onchip_data_wr, 
                    onchip_data_ld;
    reg    [31:0]   onchip_status, 
                    onchip_ctrl, 
                    onchip_addr,
                    onchip_data,
                    onchip_rdata;

    reg             onchip_ctrl_rd_ack = 1'b0;
    reg             onchip_ctrl_wr_ack = 1'b0;
    reg             onchip_data_wr_ack = 1'b0;
    reg             onchip_data_ld_ack = 1'b0;

    reg     [3:0]   spi_fsm_cs, spi_fsm_ns;

	wire  	[31:0]	avmm_csr_readdata;
    reg             flash_adr_inc;
    reg      [1:0]  flash_adr_inc_ack;

    assign spi_clk_rise = ~spi_clk_sync[1] &  spi_clk_sync[0];
    assign spi_clk_fall =  spi_clk_sync[1] & ~spi_clk_sync[0];

    always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
      begin
        spi_en_sync <= 2'd3;
        spi_clk_sync <= 2'd3;
        spi_mosi_sync <= 2'd3;
      end
      else
      begin
        spi_en_sync <= {spi_en_sync[0], spi_en_n};
        spi_clk_sync <= {spi_clk_sync[0], spi_clk};
        spi_mosi_sync <= {spi_mosi_sync[0], spi_mosi};
      end
    end

    always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
      begin
        spi_shcntr <= 'd0;
        spi_cmd_hit <= 'd0;
        spi_cmd_cmpl <= 'd0;
      end
      else
      begin
        if (spi_en_sync[1] | ~prog_en)
        begin
          spi_shcntr <= 'd0;
          spi_cmd_hit <= 'd0;
        end
        else 
        begin
          if (~spi_en_sync[1] & spi_clk_rise)
          begin
            spi_shcntr <= (spi_shcntr[5] & spi_shcntr[3])? spi_shcntr: spi_shcntr+ 1'b1;
            spi_shbuf <= {spi_shbuf, spi_mosi_sync[1]};
          end

          if (~spi_en_sync[1] & spi_clk_rise)
            spi_cmd_hit <= (spi_shcntr == 'd7)? 1'b1:1'b0;
          else
            spi_cmd_hit <= 1'b0;

          if (~spi_en_sync[1] & spi_clk_rise)
            spi_cmd_cmpl <= (spi_shcntr == 'd39)? 1'b1:1'b0;
          else
            spi_cmd_cmpl <= 1'b0;
        end
      end
    end

    always @(*)
    begin
      if (~spi_en_sync[1])
        spi_fsm_ns = 'd0;
      else
        case (spi_fsm_cs)
        'd1:
          spi_fsm_ns = (spi_cmd_cmpl)? 'd0:'d1;
        'd3:
          spi_fsm_ns = (spi_cmd_cmpl)? 'd0:'d3;
        'd4:
          spi_fsm_ns = (spi_cmd_cmpl)? 'd0:'d4;
        'd6:
          spi_fsm_ns = (spi_cmd_cmpl)? 'd0:'d6;
        'd7:
          spi_fsm_ns = (spi_cmd_cmpl)? 'd0:'d7;

        default: 
          spi_fsm_ns = (~spi_cmd_hit)? 'd0:
                       (spi_shbuf[7:0] == 8'h01)? 'd1:
                       (spi_shbuf[7:0] == 8'h02)? 'd1:
                       (spi_shbuf[7:0] == 8'h03)? 'd3:
                       (spi_shbuf[7:0] == 8'h04)? 'd4:
                       (spi_shbuf[7:0] == 8'h05)? 'd1:
                       (spi_shbuf[7:0] == 8'h06)? 'd6:
                       (spi_shbuf[7:0] == 8'h07)? 'd7:
                       (spi_shbuf[7:0] == 8'h08)? 'd1:
                       'd0;
        endcase
    end

    always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
      begin
        spi_shobuf <= 'd0;
        spi_miso <= 1'b0;
      end
      else
      begin
        if (spi_cmd_hit & spi_fsm_cs == 'd0)
        begin
          case (spi_shbuf[7:0])
          8'h01:
            spi_shobuf <= DATECODE;
          8'h05:
            spi_shobuf <= onchip_addr;
          8'h08:
            spi_shobuf <= onchip_rdata;
          default:
            spi_shobuf <= onchip_status;
          endcase
        end
        else if (spi_clk_fall)
           {spi_miso, spi_shobuf} <= {spi_shobuf, 1'b0};
      end
    end

    always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        spi_fsm_cs <= 'd0;
      else
        spi_fsm_cs <= spi_fsm_ns;
    end

    always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
      begin
        onchip_ctrl_wr <= 1'b0;
        onchip_ctrl_rd <= 1'b0;
        onchip_data_wr <= 1'b0;
        onchip_data_ld <= 1'b0;
        onchip_status <= 32'hA55A_8877; //'d0;
        flash_adr_inc_ack <= 'd0;
      end
      else
      begin
        onchip_ctrl_rd <= (~onchip_ctrl_rd)? spi_en_sync[1] & ~spi_en_sync[0]: ~onchip_ctrl_rd_ack;
        onchip_ctrl_wr <= (~onchip_ctrl_wr)? (spi_fsm_cs == 8'h03 & spi_cmd_cmpl): ~onchip_ctrl_wr_ack;
        onchip_data_wr <= (~onchip_data_wr)? (spi_fsm_cs == 8'h06 & spi_cmd_cmpl): ~onchip_data_wr_ack;
        onchip_data_ld <= (~onchip_data_ld)? (spi_fsm_cs == 8'h07 & spi_cmd_cmpl): ~onchip_data_ld_ack;
        flash_adr_inc_ack <= {flash_adr_inc_ack[0], flash_adr_inc};

        if (spi_fsm_cs == 8'h03 & spi_cmd_cmpl)
          onchip_ctrl <= spi_shbuf;
        if (spi_fsm_cs == 8'h04 & spi_cmd_cmpl)
          onchip_addr <= spi_shbuf;
        else if (flash_adr_inc_ack[1] & ~flash_adr_inc_ack[0])
          onchip_addr <= onchip_addr + 1'b1;
        if (spi_fsm_cs == 8'h06 & spi_cmd_cmpl)
          onchip_data <= spi_shbuf;
        onchip_status <= (spi_cmd_hit)? avmm_csr_readdata: onchip_status;
      end
    end

    reg       [2:0] flash_rst_n = 3'b000;

    always @(posedge flash_clk)
    begin
      flash_rst_n <= {flash_rst_n, 1'b1};
      onchip_ctrl_rd_ack <= onchip_ctrl_rd; 
      onchip_ctrl_wr_ack <= onchip_ctrl_wr; 
      onchip_data_wr_ack <= onchip_data_wr; 
      onchip_data_ld_ack <= onchip_data_ld; 
    end

	reg  	[14:0]	avmm_data_addr;
	reg  		    avmm_data_read;
	reg  		    avmm_data_write;
	reg     [0:0]	avmm_data_writedata;
	reg  	[10:0]	avmm_data_burstcount = 'd32;
	wire  	[0:0]	avmm_data_readdata;
	wire  		    avmm_data_waitrequest;
	wire  		    avmm_data_readdatavalid;
    reg     [31:0]  flash_wrdata;
    reg     [4:0]   data_bitcntr;
    reg             flash_adr_cmpl;

    reg     [2:0]   avmm_dat_fsm_cs, avmm_dat_fsm_ns;

    always @(*)
    begin
      avmm_data_addr = onchip_addr[14:0];
      avmm_data_writedata[0] = flash_wrdata[31];
    end

    always @(posedge flash_clk or negedge flash_rst_n[2])
    begin
      if (!flash_rst_n[2])
      begin
        avmm_data_read <= 'd0;
        avmm_data_write <= 'd0;
        flash_wrdata <= 'd0;
        data_bitcntr <= 'd31;
        flash_adr_cmpl <= 'd0;
        flash_adr_inc <= 'd0;
        onchip_rdata <= 'd0;
      end
      else
      begin
        flash_adr_inc <= (~flash_adr_inc)? flash_adr_cmpl:~flash_adr_inc_ack[0];
        onchip_rdata <= (avmm_data_readdatavalid)? {onchip_rdata, avmm_data_readdata}: onchip_rdata;

        case (avmm_dat_fsm_ns)
        'd1:
        begin
          avmm_data_read <= 'd0;
          avmm_data_write <= 'd1;
          flash_wrdata <= (onchip_data_wr_ack)? onchip_data: flash_wrdata; 
          data_bitcntr <= 'd31;
          flash_adr_cmpl <= 'd0;
        end
        'd2:
        begin
          avmm_data_read <= 'd0;
          avmm_data_write <= 'd1;
          flash_wrdata <= {flash_wrdata, 1'b0}; 
          data_bitcntr <= data_bitcntr + {6{|data_bitcntr}};
          flash_adr_cmpl <= 'd0;
        end
        'd3:
        begin
          avmm_data_read <= 'd0;
          avmm_data_write <= 'd0;
          flash_adr_cmpl <= 'd1;
        end
        'd4:
        begin
          avmm_data_read <= 'd1;
          avmm_data_write <= 'd0;
          data_bitcntr <= 'd31;
          flash_adr_cmpl <= 'd0;
        end
        'd5:
        begin
          avmm_data_read <= 'd0;
          avmm_data_write <= 'd0;
          data_bitcntr <= 'd31;
          flash_adr_cmpl <= 'd0;
        end
        'd6:
        begin
          avmm_data_read <= 'd0;
          avmm_data_write <= 'd0;
          data_bitcntr <= data_bitcntr + {6{|data_bitcntr}};
          flash_adr_cmpl <= 'd0;
        end
        
        default:
        begin
          avmm_data_read <= 'd0;
          avmm_data_write <= 'd0;
          data_bitcntr <= 'd31;
          flash_adr_cmpl <= 'd0;
        end
        endcase
      end
    end

    always @(*)
    begin
      case (avmm_dat_fsm_cs)
      'd1:
        avmm_dat_fsm_ns = (avmm_data_waitrequest)? 'd1:'d2;
      'd2:
        avmm_dat_fsm_ns = (|data_bitcntr)? 'd2:'d3;
      'd3:
        avmm_dat_fsm_ns = 'd0;
      'd4:
        avmm_dat_fsm_ns = (avmm_data_waitrequest)? 'd4:'d5;
      'd5:
        avmm_dat_fsm_ns = 'd6;
      'd6:
        avmm_dat_fsm_ns = (|data_bitcntr)? 'd6:'d3;

      default:
        avmm_dat_fsm_ns = (onchip_data_wr_ack)? 'd1:
                          (onchip_data_ld_ack)? 'd4:
                          'd0;
      endcase
    end
    always @(posedge flash_clk or negedge flash_rst_n[2])
    begin
      if (!flash_rst_n[2])
        avmm_dat_fsm_cs <= 'd0;
      else
        avmm_dat_fsm_cs <= avmm_dat_fsm_ns;
    end

    /********************************************************************************/
    // AVMM CSR Access Control Logic
    /********************************************************************************/
	reg  		    avmm_csr_addr;
	reg  		    avmm_csr_read;
	reg  	[31:0]	avmm_csr_writedata;
	reg  		    avmm_csr_write;
    reg     [1:0]   avmm_csr_fsm_cs, avmm_csr_fsm_ns;
    
    always @(*)
    begin
      avmm_csr_writedata = onchip_ctrl;
    end

    always @(posedge flash_clk or negedge flash_rst_n[2])
    begin
      if (!flash_rst_n[2])
      begin
	    avmm_csr_addr <= 1'b0;
	    avmm_csr_read <= 1'b0;
	    avmm_csr_write <= 1'b0;
      end
      else
      begin
        case (avmm_csr_fsm_ns)
        'd1:
        begin
	      avmm_csr_addr <= 1'b0;
	      avmm_csr_read <= 1'b1;
	      avmm_csr_write <= 1'b0;
        end
        'd2:
        begin
	      avmm_csr_addr <= 1'b1;
	      avmm_csr_read <= 1'b0;
	      avmm_csr_write <= 1'b1;
        end

        default:
        begin
	      avmm_csr_addr <= 1'b0;
	      avmm_csr_read <= 1'b0;
	      avmm_csr_write <= 1'b0;
        end
        endcase
      end
    end

    always @(*)
    begin
      case (avmm_csr_fsm_cs)
      'd1, 'd2:
        avmm_csr_fsm_ns = 'd0;
      default: 
        avmm_csr_fsm_ns = (onchip_ctrl_rd_ack)? 'd1:
                          (onchip_ctrl_wr_ack)? 'd2:
                          'd0;
      endcase
    end

    always @(posedge flash_clk or negedge flash_rst_n[2])
    begin
      if (!flash_rst_n[2])
        avmm_csr_fsm_cs <= 'd0;
      else
        avmm_csr_fsm_cs <= avmm_csr_fsm_ns;
    end
  /*
  initial 
  begin
    avmm_csr_addr = 1'b1;
    avmm_csr_read = 1'b0;
    avmm_csr_write = 1'b0;
    avmm_csr_writedata = 32'd0;
    avmm_data_addr = 15'h0000/4;
    avmm_data_read = 1'b0;
    avmm_data_write = 1'b0;
    avmm_data_writedata = 1'b0;
    avmm_data_burstcount = 9'd32;
    flash_wrdata = 32'd33;

    #30000;
    @(posedge flash_clk); #1;
    #500000;

    @(posedge flash_clk); #1;
    avmm_csr_addr = 1'b0;
    @(posedge flash_clk); #1;
    avmm_csr_read = 1'b1;
    @(posedge flash_clk); #1;
    avmm_csr_read = 1'b0;
    repeat(3) @(posedge flash_clk); #1;

    @(posedge flash_clk); #1;
    avmm_csr_addr = 1'b1;
    avmm_csr_writedata = 32'hF7FF_FFFF; //CFM0 Unprotect
    //avmm_csr_writedata = 32'hFFFF_FFFF; //CFM0 Protect
    avmm_csr_write = 1'b1;
    @(posedge flash_clk); #1;
    avmm_csr_write = 1'b0;

    avmm_csr_addr = 1'b0;
    repeat(1)
    begin
      @(posedge flash_clk); #1;
      avmm_csr_read = 1'b1;
      @(posedge flash_clk); #1;
      avmm_csr_read = 1'b0;
      #3000;
    end

    @(posedge flash_clk); #1;
    avmm_csr_addr = 1'b0;
    avmm_csr_read = 1'b1;
    @(posedge flash_clk); #1;
    avmm_csr_read = 1'b0;

    @(posedge flash_clk); #1;
    avmm_csr_addr = 1'b1;
    avmm_csr_writedata = 32'hF7DF_FFFF; //CFM0_Erase
    //avmm_csr_writedata = 32'hFFFF_FFFF; //CFM0_Erase
    avmm_csr_write = 1'b1;
    @(posedge flash_clk); #1;
    avmm_csr_write = 1'b0;
    
    #100000;
    avmm_csr_addr = 1'b1;
    repeat(8)
    begin
      @(posedge flash_clk); #1;
      avmm_csr_read = 1'b1;
      @(posedge flash_clk); #1;
      avmm_csr_read = 1'b0;
      avmm_csr_addr = ~avmm_csr_addr;
      #100;
    end
    avmm_csr_addr = 1'b0;
    #100000;

    avmm_csr_addr = 1'b0;
    avmm_data_addr = 15'h3000/4;
    repeat(3)
    begin
      #10000;
      avmm_data_writedata = flash_wrdata[31];
      flash_wrdata = {flash_wrdata[30:0], flash_wrdata[31]};
      avmm_data_write = 1'b1;
      @(posedge flash_clk); #1;
      @(negedge avmm_data_waitrequest); #1;
      repeat(32)
      begin
        avmm_data_writedata = flash_wrdata[31];
        flash_wrdata = {flash_wrdata[30:0], flash_wrdata[31]};
        @(posedge flash_clk); #1;
      end
      avmm_data_write = 1'b0;
      flash_wrdata = flash_wrdata + 16;
      avmm_data_addr = avmm_data_addr + 1'b1;
      
      @(negedge avmm_csr_readdata[1]); #1;
    end

    #3000;
    @(posedge flash_clk); #1;
    avmm_data_addr = 15'h3000/4;
    repeat(1)
    begin
      avmm_data_read = 1'b1;
      @(posedge flash_clk); #1;
      avmm_data_read = 1'b0;
      @(posedge flash_clk); #1;
    end
    
    repeat (1)
    begin
      #3000;
      @(posedge flash_clk); #1;
      avmm_csr_read = 1'b1;
      @(posedge flash_clk); #1;
      avmm_csr_read = 1'b0;
      avmm_csr_addr = 0; //~avmm_csr_addr;
    end
  end
  */
	onchip_flash i_flash (
		.clock                   (flash_clk),               // clk.clk
		.reset_n                 (flash_rst_n[2]),          // nreset.reset_n
		.avmm_data_addr          (avmm_data_addr),          // data.address
		.avmm_data_read          (avmm_data_read),          //       .read
		.avmm_data_writedata     (avmm_data_writedata),     //       .writedata
		.avmm_data_write         (avmm_data_write),         //       .write
		.avmm_data_readdata      (avmm_data_readdata),      //       .readdata
		.avmm_data_waitrequest   (avmm_data_waitrequest),   //       .waitrequest
		.avmm_data_readdatavalid (avmm_data_readdatavalid), //       .readdatavalid
		.avmm_data_burstcount    (avmm_data_burstcount),    //       .burstcount
		.avmm_csr_addr           (avmm_csr_addr),           // csr.address
		.avmm_csr_read           (avmm_csr_read),           //       .read
		.avmm_csr_writedata      (avmm_csr_writedata),      //       .writedata
		.avmm_csr_write          (avmm_csr_write),          //       .write
		.avmm_csr_readdata       (avmm_csr_readdata)        //       .readdata
	);
endmodule

