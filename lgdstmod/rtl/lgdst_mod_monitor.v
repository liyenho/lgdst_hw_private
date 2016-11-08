/****************************************************
This is an asynchronous Fifo module which gets the inputs at 146 clk speed and send the output at 50m clk
The Read and Write requests are triggered based on the "*_ordy" signals
The bitrate of the output from this fifo is also calculated which comes to 6Mbps
A continuity error couter should be added to this fifo output

*/


module lgdst_mod_monitor ( 
input clk50m, //50m clk
input clk146, //146m clk

input [7:0] data,
input rf_ordy,
input rf_irst,

(* noprune *)output reg [7:0] q,
(* noprune *) output reg [7:0] rf_ordy_out,        //output of the fifo
(* noprune *) output reg [15:0] fifo_bit_rate      //bit rate of the fifo
);

wire [7:0] fifo_in;               //input to the fifo
wire [7:0] ordy_fifo_out;         //output of the fifo 
wire ordy_fifo_empty;             //fifo empty flag (output from the fifo)
wire ordy_fifo_full;              //fifo full flag (output from the fifo)

// reg for writing into the fifo
(* noprune *) reg rf_ordy_test;
(* noprune *) reg fifo_wr_err;    //fifo error flag(output of fifo) 

// reg for reading from the fifo
(* noprune *) reg ordy_rd;        //read request to the fifo (input to the fifo)
(* noprune *) reg fifo_rd_err;    //fifo error flag(output of fifo)

// regs for data rate detection of the fifo 
(* noprune *) reg [25:0] sec_cnt;
(* noprune *) reg [22:0] byte_rate_accu;
(* noprune *) reg [15:0] fifo_bitrate_local;



//code for writing into the fifo
   always @ (posedge clk146)  
   begin
    if (ordy_fifo_full == 0) 
	  begin
     rf_ordy_test <= rf_ordy;
	  fifo_wr_err <= 0;
	  end
	 else 
	  fifo_wr_err <= 1;
   end

//code for reading from the fifo
   always @(posedge clk50m)  
   begin
    if (ordy_fifo_empty == 0)
     begin
     ordy_rd <= 1;
     rf_ordy_out <= ordy_fifo_out;
     fifo_rd_err <= 0;
     end
    else
     begin
     ordy_rd <= 0;
     fifo_rd_err <= 1;
     end
   end

//code to find the data rate of fifo
   always @(posedge clk50m) 
	begin
   if(sec_cnt >= 26'd50000000 ) 
	 begin
    sec_cnt <= 0;
    fifo_bitrate_local <= byte_rate_accu[22:7];
	 byte_rate_accu <= 0;
    end
   else 
	 begin
    sec_cnt <= sec_cnt +1;
	 if(ordy_rd) 
     if(~&byte_rate_accu) byte_rate_accu <= byte_rate_accu+1;
    end
   end            

	assign fifo_in = data;
	
   fifo_fwft_256x8 rf_ordy_out_fifo(
   .aclr(rf_irst),
	.data(fifo_in),
	.rdclk(clk50m),
	.rdreq(ordy_rd),
	.wrclk(clk146),
	.wrreq(rf_ordy_test),
	.q(ordy_fifo_out),
	.rdempty(ordy_fifo_empty),
	.rdusedw(),
	.wrfull(ordy_fifo_full)
   );
  
  always @(*) begin
  fifo_bit_rate = fifo_bitrate_local;
  end
 

endmodule 