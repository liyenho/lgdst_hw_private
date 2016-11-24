/*
 *
 */

`timescale 1ns / 10ps
`include "ver_info.v"

module lgdst_rxglue #(
  parameter TS_MODE = "BYPASS", 
  parameter INC_AD6612 = "TRUE"
) (
  input             clk, 
  input             resync_n,  //active low
  
  //Intf for the 6612
  // IOs for ADRF_brg
  input             spi0_spck,
  input             spi0_npcs0,   //replacecd tp45 cs to this signal
  input             spi0_mosi, 
  output            spi0_miso,

  output            ad_spi_cs, 
  output            ad_spi_sclk,
  inout             ad_spi_sdio, 
  
  //for the TS
  // IOs for TS_brg
  output         spi5_spck ,
  output         spi5_npcs0 , 
  output         spi5_mosi , 

  // IOs for I2C Dummy Read
  input             i2c_base_clk,
  input             i2c_trig,
  output            i2c_scl,
  inout             i2c_sda,
  
  //pin for signal tap
  output  led_wifi,
  output  tp_42,
  input   tp_50,  //connected to the PA17 pin of the atmel
  
  input             ts_clk, 
  input             ts_d0, 
  input             ts_valid,
  input             ts_sync,
  
  //interface signals from the control to the RF switch
  input       gpio2,
  input       gpio3,
  
  output      rf_sw3,
  output      rf_sw4,
  
  input     xout_sms4470_m, //j12
  output    xin_sms4470,    //g2
  
  input     prog_en,
  
  input [7:0]  cnt_in //declared to test out the pins  
);

//test code for the proper working of cpld
wire ufm_prog_en = (prog_en)?1'b1:1'b0;

//signals for controlling the on chip flash
wire          flash_clk;
reg   [3:0]   ufm_rst_ff = 4'hF;
wire          ufm_rst_n;
wire          ufm_spi_clk;
wire          ufm_spi_en_n;
wire          ufm_spi_mosi;
wire          ufm_spi_miso;

// Signals for ADRF_brg
reg  [3:0]    spi0_ck_cnt = 4'd0;
reg           ad_spi_rw   = 1'b0;
reg           ad_spi_oe_b = 1'b1;
wire          ad_spi0_miso;
wire          ad_spi0_mosi;
wire          ad_spi0_npcs0;

//code to route the spi signals in case of upgrade
assign ufm_spi_clk = spi0_spck;
assign ad_spi0_npcs0 = (ufm_prog_en)? 1'b1: spi0_npcs0;
assign ufm_spi_en_n  = (ufm_prog_en)? spi0_npcs0: 1'b1;
assign spi0_miso = (ufm_prog_en)? ufm_spi_miso:    //problem in the readback of the 6612
                   (data_start)? spi0_miso_ver: 
						 ad_spi0_miso;
assign ad_spi0_mosi =  (ufm_prog_en)? 1'b0: spi0_mosi;
assign ufm_spi_mosi =  (ufm_prog_en)? spi0_mosi:1'b0;

//signals for the logic of sending the version to the atmel 
wire [7:0] version;
reg [3:0] cntbit=4'd1;
reg addr_check=1'b0;
reg byte_start_end;
reg [4:0] cntbyte=5'd0;
reg data_start=1'b0;
 
//signals to select the sdio or the internal version for the output
wire spi0_miso_io;
reg  spi0_miso_ver;



//asynchronous resync handling
wire      spi5_bypass_en;
wire      spi5_spck_bypass; 
wire      spi5_npcs0_bypass;
reg       spi5_npcs0_ = 1'b1;
reg rst_arm=1'b0;
reg ts_valid_prelatch; //required to force delay WRT ts_clk

always @(negedge ts_clk) 
  ts_valid_prelatch <= ts_valid; 

  reg ts_valid_prelatch_d1;
  wire ts_valid_risingedge = ~ts_valid_prelatch_d1 & ts_valid_prelatch;
  
always @(posedge clk) begin
 if(!resync_n) rst_arm <= 1'b1;
 else if(ts_valid_risingedge) rst_arm<=1'b0; 
end

//following synchronous resync handling
reg ts_clk_disable;
always @(posedge ts_clk ) begin
 ts_valid_prelatch_d1 <= ts_valid_prelatch;
 if(rst_arm) ts_clk_disable <= 1'b1;
 else if(ts_valid_risingedge)ts_clk_disable <= 1'b0;
end
wire      is_null_pkt; 
assign  spi5_spck = (spi5_bypass_en)? spi5_spck_bypass:
                    (rst_arm)?1'b1:
                    (ts_clk_disable)? 1'b1:
						  (spi5_npcs0) ? 1'b1:
						  (is_null_pkt)? 1'b1:
						ts_clk;
						
//reg spi5_npcs0 defined
assign spi5_npcs0 = (spi5_bypass_en)? spi5_npcs0_bypass: spi5_npcs0_;
always @(posedge ts_clk) begin
  if(rst_arm) spi5_npcs0_ <= 1'b1;
  else if(ts_valid_risingedge) spi5_npcs0_ <= 1'b0;
  else if(ts_valid_prelatch)   spi5_npcs0_ <= 1'b0;
  else                         spi5_npcs0_ <= 1'b1;
end
  							 
  generate 
  begin : spi5_gen
    if (TS_MODE == "TS_PATTERN")
    begin
      ts_pattern i_ts_pat(
        .rst_arm(rst_arm), 
        .ts_clk(ts_clk),        .ts_sync(ts_sync), 

        .spi5_mosi(spi5_mosi)
      );
      assign is_null_pkt = 1'b0;
      assign spi5_bypass_en = 1'b0;
      assign spi5_npcs0_bypass = 1'b0; 
      assign spi5_spck_bypass = 1'b0; 
    end 
    else if (TS_MODE == "NULL_FILTER")
    begin
      null_filter i_null_fi(
        .rst_arm(rst_arm), 
        .ts_clk(ts_clk),        .ts_sync(ts_sync), 
        .ts_d0(ts_d0),

        .spi5_mosi(spi5_mosi),  .is_null(is_null_pkt)
      );
      assign spi5_bypass_en = 1'b0;
      assign spi5_npcs0_bypass = 1'b0; 
      assign spi5_spck_bypass = 1'b0; 
    end 
    else if (TS_MODE == "BYPASS")
    begin
      spi5_bypass i_bypass(
        .clk(clk), 
        
        .ts_valid(ts_valid),
        .ts_clk(ts_clk), 
        .ts_d0(ts_d0), 

        .spi5_npcs0(spi5_npcs0_bypass),
        .spi5_spck(spi5_spck_bypass),
        .spi5_mosi(spi5_mosi)
      );
      assign is_null_pkt = 1'b0;
      assign spi5_bypass_en = 1'b1;
    end
  end
  endgenerate

//reg ts_d0_prelatch; //required to force delay WRT ts_clk
//always @(negedge ts_clk) 
//  ts_d0_prelatch <= ts_d0;
//always @(posedge ts_clk) begin
//  if(rst_arm) spi5_mosi <= 1'b0;
//  else spi5_mosi <= ts_d0_prelatch;
//                         end

//assigning the gpio to control the rf switch signals
assign rf_sw3 = gpio3;
assign rf_sw4 = gpio2;

assign xin_sms4470 = xout_sms4470_m;

////// led_wifi is black wire///////////
								 
wire ts_valid_adj = (resync_n)?ts_valid: 1'b0;
								 
assign led_wifi= (tp_50)? 1'b0: (~ts_valid_adj);
assign tp_42 = ad_spi0_mosi;  //H8

  generate 
  begin
    if (INC_AD6612 != "FALSE")
    begin
      // alt_iobuf is not supported for MAX10
      /*
      alt_iobuf i_iobuf(
        .io(ad_spi_sdio),           .oe(~(ad_spi_oe_b | ad_spi0_npcs0)),
        .o(ad_spi0_miso),            .i(ad_spi0_mosi) 
      );
      */
      assign ad_spi_sdio = (~(ad_spi_oe_b | ad_spi0_npcs0))? ad_spi0_mosi: 1'bz;
      assign ad_spi0_miso = ad_spi_sdio;
      assign {ad_spi_cs, ad_spi_sclk} = {ad_spi0_npcs0, spi0_spck};
    end
    else
      assign {ad_spi_cs, ad_spi_sclk} = 2'd0;
  end
  endgenerate
  
//assign {ad_spi_cs, ad_spi_sclk} = {ad_spi0_npcs0, spi0_spck};
////assign spi0_miso = (data_start)? spi0_miso_ver: spi0_miso_io;//1'b0: spi0_miso_io;//


////** The below buffer has been replaced from the original altio_buf
////** Need to fix this buffer later
//  io_buf io_buf(
//  .dataio(ad_spi_sdio),      .oe(~(ad_spi_oe_b | ad_spi0_npcs0)),
//  .dataout(spi0_miso_io),                .datain(ad_spi0_mosi)  
//  );

  always @(negedge spi0_spck or posedge ad_spi0_npcs0)
  begin
    if (ad_spi0_npcs0)
      ad_spi_oe_b <= 1'b0;
    else
      ad_spi_oe_b <= ad_spi_rw;
  end
  always @(posedge spi0_spck or posedge ad_spi0_npcs0)
  begin
    if (ad_spi0_npcs0)
    begin
      spi0_ck_cnt <= 4'd8;
      //spi0_ck_cnt <= 8'd0;
      ad_spi_rw <= 1'd0;
    end
    else
    begin
      spi0_ck_cnt <= spi0_ck_cnt + {4{|spi0_ck_cnt}};
      ad_spi_rw <= (~|spi0_ck_cnt[2:1] & spi0_ck_cnt[0])? ad_spi0_mosi:
                   ad_spi_rw;
    end
  end

  wire      sdai, sdao;

  assign sdai = i2c_sda;
  assign i2c_sda = (sdao)? 1'bz:1'b0;
						 
  i2c_dummy #(
    .SLAVE_ADR(7'h68)
  ) i_i2c(
    .clk(i2c_base_clk),         .trig(i2c_trig), 

    .scl(i2c_scl),              .sdai(sdai), 
    .sdao(sdao)
  );

// UFM Control Logic
always @(posedge clk)
begin
  ufm_rst_ff <= {ufm_rst_ff[2:0], 1'b0};
end
  assign ufm_rst_n = ~ufm_rst_ff[3]; // Kevin: reset polarity inverted
						 
//code for the on chip flash
  flash_pll i_pll (
	.inclk0(clk),               .c0(flash_clk)
  );

//assigning signals for the on chip flash

 spi_prog i_ufm_spi(
    .rst_n(ufm_rst_n),          .clk(clk), 
    
    .prog_en(ufm_prog_en),
    .spi_clk(ufm_spi_clk),      .spi_en_n(ufm_spi_en_n),  
    .spi_mosi(ufm_spi_mosi),    .spi_miso(ufm_spi_miso),
    
    .flash_clk(flash_clk)    
  );
    
//logic to check for the address using lfsr to reduce the LUTs
 reg spi0_mosi_prelatch;
 reg spi0_npcs0_prelatch;
 
 assign version [7:6] = `BUILD_YEAR;
 assign version [5:3] = `BUILD_MONTH;
 assign version [2:0] = `BUILD_DAY;
 
//prelatch logic for the input data
  always @(posedge spi0_spck)
  begin
   spi0_mosi_prelatch <= ad_spi0_mosi;
	spi0_npcs0_prelatch <= ad_spi0_npcs0; 
  end
////////////////////////////////
  always @(negedge spi0_spck or posedge spi0_npcs0_prelatch)
  begin
   if (spi0_npcs0_prelatch)
   begin
    cntbit = 4'd1;
   end //end of the if of cs
   else
   begin
//////////////////////////////
   if (addr_check == 1'b1)
   begin	
    if (spi0_mosi_prelatch == 1'b1)
 	  begin
	   if (cntbit == 4'd10)
	    begin
	    cntbit<=4'd1;
	    end //end of the if of the cntbit
	   else
	    begin
	    cntbit[3:1] <= cntbit[2:0];
	    cntbit[0] <= cntbit[3] ^ cntbit[2];
	    end //end of the else of the cnbit
	  end //end of the mosi==1
	 else
	  begin
	  cntbit <= 4'd1;
	  end
	end  
	else
	begin
	cntbit <= 4'd1;
	end
   end //end of the else of the cs
  end

//logic to send the version using lfsr comparison
//for 16 bits, 5 bit lfsr is required
  always @(negedge spi0_spck or posedge spi0_npcs0_prelatch)
  begin
   if (spi0_npcs0_prelatch)
	 begin
	 cntbyte <= 5'd1;
	 byte_start_end <= 1'b0;
	 data_start <= 1'b0;
	 end //end of the if of cs
	else
	 begin
	 cntbyte[4:1] <= cntbyte[3:0];
    cntbyte[0] <= cntbyte[4] ^ cntbyte[2];
	 
	  if ((cntbyte==5'd1) || (cntbyte==5'd14))
	   byte_start_end <= 1'b1;
	  else
	   byte_start_end <= 1'b0;
	  
	  
	  if (cntbit == 5'd10)
	  begin
	   data_start <= 1'b1;
	  end
	  
	  if (cntbyte == 5'd14)
	  begin
	   cntbyte <= 5'd1;
		data_start <= 1'b0;
	  end
	  
	 end //end of the else of the cs	 
  end

  
  
  always @(*)
  begin
  
   if ((cntbyte==5'd1) && (~spi0_npcs0_prelatch))
    addr_check <= 1'b1;
   else if (cntbyte==5'd12)
    addr_check <= 1'b0;

   if(data_start)
   begin
    if (cntbyte == 5'd12)
	  spi0_miso_ver = version[7];
	 else if (cntbyte == 5'd25)
	  spi0_miso_ver = version[6];
	 else if (cntbyte == 5'd19)
	  spi0_miso_ver = version[5];
	 else if (cntbyte == 5'd7)
	  spi0_miso_ver = version[4];
	 else if (cntbyte == 5'd15)
	  spi0_miso_ver = version[3];
	 else if (cntbyte == 5'd31)
	  spi0_miso_ver = version[2];
	 else if (cntbyte == 5'd30)
	  spi0_miso_ver = version[1];
	 else if (cntbyte == 5'd28)
	  spi0_miso_ver = version[0];
	 else
	  spi0_miso_ver = 5'd0;
	end
  end
  
//declarations to test out the pins
//wire[7:0]  cnt_in;

reg [7:0] cnt_out;
  
//// Counters to test the pins//////
  
always @ (posedge clk)
 begin
  if (rst_arm)
  begin
   cnt_out <= 8'h0;
  end
  else
  begin
   cnt_out <= cnt_in + 8'h1;
  end
 end

endmodule 
module spi5_bypass(
  input         clk,

  input         ts_valid,
  input         ts_clk, 
  input         ts_d0,

  output reg    spi5_npcs0 = 1'b1,
  output reg    spi5_spck = 1'b1,
  output reg    spi5_mosi = 1'b1
);

  always @(posedge clk)
    {spi5_npcs0, spi5_spck, spi5_mosi} <= {ts_valid, ts_clk, ts_d0};

endmodule

module ts_pattern(
  input         rst_arm,
  input         ts_clk, 
  input         ts_sync,

  output reg    spi5_mosi = 1'b0
);

  reg [3:0] pkg_cnt = 4'd0;
  reg [7:0] pat_sr = 'd0; 
  reg       pat_head = 1'b0;
  reg [3:0] spi5_sh_cnt = 4'd8;
  wire      spi5_sh_hit = &spi5_sh_cnt[3:2];

  always @(posedge ts_clk) 
  begin
    if(ts_sync) 
    begin
	  pkg_cnt <= {pkg_cnt[2:0], ~pkg_cnt[3]}; 
      spi5_sh_cnt <= 4'd8;
      pat_sr <= {pkg_cnt, 4'd0};
      pat_head <= 1'b1;
	end
    else
    begin
      spi5_sh_cnt <= (spi5_sh_hit)? 4'd8: 
                     {spi5_sh_cnt[2:0], spi5_sh_cnt[3] ^ spi5_sh_cnt[2]};
      pat_sr[7:2] <= pat_sr[6:1];
      pat_sr[1]   <= (spi5_sh_hit)? pat_sr[7]:pat_sr[0];
      pat_sr[0]   <= ~pat_head & (spi5_sh_hit ^ pat_sr[6]);
      pat_head <= pat_head & ~spi5_sh_hit;
    end
  end

  always @(posedge ts_clk) begin
    if(rst_arm) spi5_mosi <= 1'b0;
    else
      spi5_mosi <= pat_sr[7];
  end
endmodule

module null_filter(
  input         rst_arm,
  input         ts_clk, 
  input         ts_sync,
  input         ts_d0,

  output reg    spi5_mosi = 1'b0,
  output reg    is_null = 1'b0
);
  reg       ts_d0_dly;

  reg [3:0] bit_cntr = 4'hf;
  wire      null_bit_hit = &{~bit_cntr[3], bit_cntr[2:0]}; 

  always @(posedge ts_clk) 
  begin
    if(ts_sync) 
    begin
	  bit_cntr <= 4'd1; 
	end
    else
    begin
	  bit_cntr <= (&bit_cntr[3:1])? 4'hF:
                  {bit_cntr[2:0], ^bit_cntr[3:2]}; 
      is_null  <= (null_bit_hit)? ts_d0:is_null;
    end
  end

  always @(posedge ts_clk) 
  begin
    ts_d0_dly <= ts_d0;

    if(rst_arm) 
      spi5_mosi <= 1'b0;
    else
      spi5_mosi <= (is_null)? 1'b0:ts_d0_dly;
  end
 
endmodule
