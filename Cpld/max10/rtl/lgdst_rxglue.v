/*
 *
 */

`timescale 1ns / 10ps
`include "ver_info.v"

module lgdst_rxglue(
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
  output            spi5_spck ,
  output reg        spi5_npcs0 , 
  output reg        spi5_mosi , 
  
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
//  input             tp_45,       //test input for the oscillator clk
  input [7:0]  cnt_in //declared to test out the pins  
);

//signals for the logic of sending the version to the atmel 
wire [7:0] version;
reg [3:0] cntbit=4'd1;
reg addr_check=1'b0;
reg byte_start_end;
reg [4:0] cntbyte=5'd0;
reg data_start;
 
//signals to select the sdio or the internal version for the output
wire spi0_miso_io;
reg  spi0_miso_ver;

  // Signals for ADRF_brg
reg  [3:0]    spi0_ck_cnt = 4'd0;
reg           ad_spi_rw   = 1'b0;
reg           ad_spi_oe_b = 1'b1;

//asynchronous resync handling
reg rst_arm;
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
assign  spi5_spck = (rst_arm)?1'b1:
                    (ts_clk_disable)? 1'b1:
						  (spi5_npcs0) ? 1'b1:
						ts_clk;
						
//reg spi5_npcs0 defined
always @(posedge ts_clk) begin
  if(rst_arm) spi5_npcs0 <= 1'b1;
  else if(ts_valid_risingedge) spi5_npcs0 <= 1'b0;
  else if(ts_valid_prelatch)   spi5_npcs0 <= 1'b0;
  else                         spi5_npcs0 <= 1'b1;
                         end

								 

reg ts_d0_prelatch; //required to force delay WRT ts_clk
always @(negedge ts_clk) 
  ts_d0_prelatch <= ts_d0;
always @(posedge ts_clk) begin
  if(rst_arm) spi5_mosi <= 1'b0;
  else spi5_mosi <= ts_d0_prelatch;
                         end

//assigning the gpio to control the rf switch signals
assign rf_sw3 = gpio3;
assign rf_sw4 = gpio2;

assign xin_sms4470 = xout_sms4470_m;

////// led_wifi is black wire///////////
								 
wire ts_valid_adj = (resync_n)?ts_valid: 1'b0;
								 
assign led_wifi= (tp_50)? 1'b0: (~ts_valid_adj);
assign tp_42 = spi0_mosi;  //H8
  
assign {ad_spi_cs, ad_spi_sclk} = {spi0_npcs0, spi0_spck};
//assign ad_spi_sdio = 1'b0; //hard coded to 0 for pin testing purposes
assign spi0_miso = (data_start)? spi0_miso_ver: spi0_miso_io;//1'b0: spi0_miso_io;//

//** The below buffer has been replaced from the original altio_buf
//** Need to fix this buffer later
  io_buf io_buf(
  .dataio(ad_spi_sdio),      .oe(~(ad_spi_oe_b | spi0_npcs0)),
  .dataout(spi0_miso_io),                .datain(spi0_mosi)  
  );

  always @(negedge spi0_spck or posedge spi0_npcs0)
  begin
    if (spi0_npcs0)
      ad_spi_oe_b <= 1'b0;
    else
      ad_spi_oe_b <= ad_spi_rw;
  end
  always @(posedge spi0_spck or posedge spi0_npcs0)
  begin
    if (spi0_npcs0)
    begin
      spi0_ck_cnt <= 4'd8;
      //spi0_ck_cnt <= 8'd0;
      ad_spi_rw <= 1'd0;
    end
    else
    begin
      spi0_ck_cnt <= spi0_ck_cnt + {4{|spi0_ck_cnt}};
      //spi0_ck_cnt <= {spi0_ck_cnt[6:0], 1'b1};
      ad_spi_rw <= (~|spi0_ck_cnt[2:1] & spi0_ck_cnt[0])? spi0_mosi:
      //ad_spi_rw <= (~spi0_ck_cnt[7] & spi0_ck_cnt[6])? spi0_mosi:
                   ad_spi_rw;
    end
  end

//logic to check for the address using lfsr to reduce the LUTs
 reg spi0_mosi_prelatch;
 reg spi0_npcs0_prelatch;
 
 assign version [7:6] = `BUILD_YEAR;
 assign version [5:3] = `BUILD_MONTH;
 assign version [2:0] = `BUILD_DAY;
 
//prelatch logic for the input data
  always @(posedge spi0_spck)
  begin
   spi0_mosi_prelatch <= spi0_mosi;
	spi0_npcs0_prelatch <= spi0_npcs0; 
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
