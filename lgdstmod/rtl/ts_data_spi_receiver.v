//------------------------------------------------------------------------------
// File name:    ts_data_spi_receiver.v
//
// Description:  This is an SPI slave device that extracts transport stream data 
//               data packets received via the SPI interface.  It detects the
//               transport stream data packet boundary and ensures that a
//               complete transport stream packet is buffered and transferred.
//               It also detects test data.
// 
// Developer:    Hedrian Cuaresma
// 
// Created On:   01/10/2016
// 
// Known Errors: None
// 
// Limitations:  None
//
// Comments:     ***(THIS MAYBE OUTDATED INFORMATION!!)****
//               The test data is a counting pattern that counts from 0 to 255
//               with the exception of every 3760 byte (1880x2).  The count will
//               be at 175 and roll over to 0 at this point and repeat the count
//               pattern again from 0 to 255. the packet count will go upto 0x3F (63) and 
//               rollover. ***(THIS MAYBE OUTDATED INFORMATION!!)****
//
//               This module currently only receives SPI data and does not put
//               anything out hte MISO line.
// 
// Project:      Encoder
// 
// Library:      Work
// 
// Simulator:    ModelSim 6.4d
// 
// Synthesizer:  Xilinx XST 11.2
// 
// Platform:     Microsoft Windows XP
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// CLK: System clock (50 MHz)
//
// RST: System synchronous reset
//
// TEST_MODE: Indicates that test data is being provided on the SPI data line
//
// ERROR_COUNT: Number of SPI bytes detected with errors during TEST_MODE
//              Number of sync lost due to bad ts data sync in normal operation
//
// DATA_COUNT: Number of SPI bytes (good and bad) received during normal
//             operation as well as TEST_MODE
//
// SCLK: SPI master clock input
//
// MOSI: SPI master out slave in data input
//
// MISO: SPI master in slave out data output
//
// SS_NOT: SPI active low slave select line
//
// TS_DATA: Transport stream data
// 
// TS_DATA_VALID: Transport stream data valid during full sync on ts stream
//
//------------------------------------------------------------------------------
module ts_data_spi_receiver(
    //System Control
    input             CLK,
    input             RST,
    
    //Helm Register Config and Status Interfaces
    input             TEST_MODE,
    input             RESET_COUNTS,
    output reg [7:0]  TS_SYNC_LOSS_COUNT,
    output reg [7:0]  SHIFTED_BYTE_COUNT,
    output reg [7:0]  PATTERN_DATA_ERROR_COUNT,
    output reg [7:0]  PATTERN_PKT_LOSS_COUNT,
    output reg [7:0]  CONTINUITY_ERROR_COUNT,
    output reg [15:0] TSBITRATE1k,          // getting assigned to the mem by sid
 
    //SPI Interface
    input             SCLK,
    input             MOSI,
    output            MISO,
    input             SS_NOT,
    
    //Transport Stream Interface
    output reg [7:0]  TS_DATA,
    output reg        TS_DATA_VALID
);

reg       sclk_q0;
reg       sclk_q1;
reg       sclk_rise_edge;
reg       sclk_fall_edge;
reg       mosi_q0;
(* noprune *) reg        miso_q0;
reg        ss_not_q0;

reg       reset_counts_q0;
reg       reset_counts_rise_edge;

reg [7:0] mosi_shift_reg;
reg       mosi_shift_reg_valid;
reg [2:0] mosi_bit_counter;
//reg       shift_data_done;
reg       high_byte_flag;
reg       high_byte_valid;
reg [7:0] high_byte;
reg       low_byte_valid;
reg [7:0] low_byte;
//reg [7:0]  low_byte_q0;

reg [7:0] ts_data_counter;
reg       half_sync;
reg       full_sync;
reg       full_sync_q0;
wire      full_sync_rise_edge;

reg       test_mode_active;
reg       ts_data_sync_loss_detect;
reg       test_pattern_error_detect;
reg       test_packet_loss_detect;
reg [7:0] test_packet_counter;
reg [7:0] test_data_counter;
reg       check_continuity;
reg [3:0] continuity_counter;
reg       continuity_error_detect;

reg [2:0] output_delay_counter;
reg       output_low_byte;

// No data being sent by the SPI slave
assign    MISO = 1'b0;

//*************************************************
// SPI SCLK Edge Detector Logic
//*************************************************
always @(posedge CLK) begin : test_mode_selector
   if(RST) begin
      test_mode_active <= 1'b0;
   end
   else begin
      //Wait until SPI transaction is over before transitioning to test mode
      if (ss_not_q0) begin
         if (TEST_MODE) begin
            test_mode_active <= 1'b1;
         end
         else begin
            test_mode_active <= 1'b0;
         end
      end
   end
end

//*************************************************
// SPI SCLK Edge Detector Logic
//*************************************************
always @(posedge CLK) begin : spi_sclk_edge_detector
    if(RST) begin
        sclk_q0        <= 1'b0;
        sclk_rise_edge <= 1'b0;
        sclk_fall_edge <= 1'b0;
        mosi_q0        <= 1'b0;
        miso_q0        <= 1'b0;
        ss_not_q0      <= 1'b1;
    end
    else begin
        sclk_q0        <= SCLK;
        sclk_q1        <= sclk_q0;
        sclk_rise_edge <= sclk_q0 && !(sclk_q1);
        sclk_fall_edge <= !(sclk_q0) && sclk_q1;
        
        reset_counts_q0        <= RESET_COUNTS;
        reset_counts_rise_edge <= RESET_COUNTS && !(reset_counts_q0);
        //delay other spi signals since SCLK was delayed
        mosi_q0        <= MOSI;
        miso_q0        <= MISO;
        ss_not_q0      <= SS_NOT;
    end
end

//*************************************************
// SPI MOSI Shift In Logic
//*************************************************
always @(posedge CLK) begin : spi_mosi_shift_in_proc
    if (RST) begin
        mosi_bit_counter     <= 0;
        //shift_data_done      <= 1'b0;
        mosi_shift_reg_valid <= 1'b0;
        
    end
    else begin
        mosi_shift_reg_valid <= 1'b0;
        
        if (sclk_rise_edge) begin
            //When slave select is active clock in a byte of data
            if (ss_not_q0 == 1'b0) begin// && shift_data_done == 1'b0) begin
                mosi_shift_reg[0]   <= mosi_q0;
                mosi_shift_reg[7:1] <=  mosi_shift_reg[6:0];
                
                if (mosi_bit_counter == 7) begin
                    mosi_bit_counter <= 0;
                    mosi_shift_reg_valid <= 1'b1; //pulse reg valid
                    //shift_data_done      <= 1'b1;
                end
                else begin
                    mosi_bit_counter <= mosi_bit_counter + 1;
                end
            end
        end
        
        //determine the end of the spi transaction and de-assert 
        //shift_data_done to indicate that the next time ss_not goes low
        //data must be shifted in again
        //if (ss_not_q0 == 1'b1) begin
        //    shift_data_done <= 1'b0;
        //end
    end
end   

//*************************************************
// SPI DATA IN ENDIAN CONVERTER
//*************************************************
always @(posedge CLK) begin : endian_converter
   if (RST) begin
      high_byte_flag  <= 1'b0;
      high_byte_valid <= 1'b0;
      low_byte_valid  <= 1'b0;
      high_byte       <= 0;
      low_byte        <= 0;
      //low_byte_q0     <= 0;
   end
   else begin
      high_byte_valid <= 1'b0;
      low_byte_valid  <= 1'b0;
      
      if (ss_not_q0) begin
         high_byte_flag  <= 1'b0;
      end
      
      if (mosi_shift_reg_valid) begin
         high_byte_flag <= ~high_byte_flag;
         // First byte serially transferred second
         if (high_byte_flag) begin
            high_byte       <= mosi_shift_reg;
            high_byte_valid <= 1'b1;
         end
         // Second byte serially transferred first
         else begin
            low_byte       <= mosi_shift_reg;
            low_byte_valid <= 1'b1;
         end
      end
      
      //delay register in order to output at TS_DATA before
      //it is overwritten.
      //low_byte_q0 <= low_byte;
   end
end

//*************************************************
// Transport Stream Detect Logic
//*************************************************
always @(posedge CLK) begin : ts_detect_proc
   if (RST) begin
      ts_data_counter          <= 0;
      half_sync                <= 1'b0;
      full_sync                <= 1'b0;
      full_sync_q0             <= 1'b0;
      ts_data_sync_loss_detect <= 1'b0;
   end
   else begin
      ts_data_sync_loss_detect <= 1'b0;
      
      if (mosi_shift_reg_valid == 1'b1) begin
         // Search for first transport sync byte to achieve half sync
         // x47 should be found during the high byte shift in process
         if (~half_sync && ~full_sync) begin
            if (mosi_shift_reg[7:0] == 8'h47) begin
               half_sync       <= 1'b1;
               ts_data_counter <= 1;
            end
         end
            
         // Searches for the next consecutive sync mark to acheive full sync
         if (half_sync) begin
            ts_data_counter <= ts_data_counter + 1;
            
            if (ts_data_counter == 187) begin
               ts_data_counter <= 0;
            end
            
            // Once in half sync, search for the the next sync marker 188 bytes
            // after the first sync byte to get full sync and begin ts buffering
            if (ts_data_counter == 0) begin
               if (mosi_shift_reg[7:0] == 8'h47) begin
                  full_sync      <= 1'b1;
               end
               else begin
               // Start search sync over by trying to re-establish half sync
                  half_sync                <= 1'b0;
                  full_sync                <= 1'b0;
                  ts_data_sync_loss_detect <= 1'b1;
               end
            end
         end
      end
      
      full_sync_q0 <= full_sync;
   end
end

assign full_sync_rise_edge = full_sync && ~full_sync_q0;

//*************************************************
// TS Data Output Detect Logic
//*************************************************
(* noprune *) reg [7:0] ts_data_mon;
reg [2:0] output_delay_counter_mon;
(* noprune *) reg       output_low_byte_mon;
reg ts_data_valid_mon /* synthesis noprune */ ; 
always @(posedge CLK) begin : ts_data_out_proc
   if (RST) begin
      TS_DATA              <= 0;
      TS_DATA_VALID        <= 1'b0;
      output_delay_counter <= 0;
      output_low_byte      <= 1'b0;
      output_delay_counter_mon <= 0;
      output_low_byte_mon      <= 1'b0;
      ts_data_valid_mon        <= 1'b0;
   end
   else begin
      TS_DATA_VALID   <= 1'b0;
      
      //if (high_byte_valid) begin
      //   output_low_byte  <= 1'b1;
      //end

      if (~full_sync) begin
         output_low_byte  <= 1'b0;
      end
      
      if (full_sync) begin
         if (high_byte_valid) begin
            TS_DATA         <= high_byte;
            TS_DATA_VALID   <= 1'b1;
            output_low_byte <= 1'b1;
         end;
         
         //After the high byte is outputted, output
         //the low byte that was previously acquired
         //if (output_delay_counter == 7) begin
         //   TS_DATA         <= low_byte_q0;
         //   TS_DATA_VALID   <= 1'b1;
         //end
      end
      
      // This logic was not necessary but was added in order to
      // output the data at a nice and consistent manner of every
      // 8 spi clock cycles a new transport stream byte would be outputted
      if (output_low_byte && sclk_rise_edge) begin
         output_delay_counter <= output_delay_counter + 1;
         
         if (output_delay_counter == 7) begin
            output_delay_counter <= 0;
            output_low_byte      <= 1'b0;

            //After the high byte is outputted, output
            //the low byte that was previously acquired
            TS_DATA              <= low_byte;
            TS_DATA_VALID        <= 1'b1;
         end
      end
      
      //monitoring logic
      ts_data_valid_mon <=1'b0;
      if(high_byte_valid) begin
        ts_data_mon <= high_byte;
        ts_data_valid_mon <= 1'b1;
        output_low_byte_mon<=1'b1; end
      if (output_low_byte_mon && sclk_rise_edge) begin
         output_delay_counter_mon <= output_delay_counter_mon + 1;
         
         if (output_delay_counter_mon == 7) begin
            output_delay_counter_mon <= 0;
            output_low_byte_mon      <= 1'b0;

            //After the high byte is outputted, output
            //the low byte that was previously acquired
            ts_data_mon              <= low_byte;
            ts_data_valid_mon        <= 1'b1;
         end
      end
      
   end
end

//*************************************************
// Pattern Detect Logic
//*************************************************
always @(posedge CLK) begin : pattern_detect_proc
   if (RST) begin
      test_packet_counter       <= 0;
      test_packet_loss_detect   <= 1'b0;
      test_pattern_error_detect <= 1'b0;
      test_data_counter         <= 0;
      check_continuity          <= 1'b1;
      continuity_counter        <= 0;
      continuity_error_detect   <= 1'b0;
   end
   else begin
      test_packet_loss_detect   <= 1'b0;
      test_pattern_error_detect <= 1'b0;
      continuity_error_detect   <= 1'b0;
      
      if (full_sync_rise_edge) begin
         test_packet_counter <= low_byte;
         test_data_counter   <= 0;
         check_continuity    <= 1'b0;
         continuity_counter  <= 0;
      end

      // Test Counter Pattern Detection
      //if (test_mode_active) begin
      if (TS_DATA_VALID) begin
         test_data_counter <= test_data_counter + 1;
         
         if (test_data_counter == 0) begin
            if (TS_DATA != 8'hx47) begin
               test_pattern_error_detect <= 1'b1;
            end
         end
         else if (test_data_counter == 1) begin
            if (TS_DATA != test_packet_counter) begin
               test_packet_loss_detect   <= 1'b1;
               test_pattern_error_detect <= 1'b1;
               
               //Packet count resets at 3F
               if (low_byte>=8'h3f) begin
                  test_packet_counter <= 0;
               end
               else begin
                  test_packet_counter <= low_byte + 1;
               end
            end
            else begin
               //Packet count resets at 3F
               if (test_packet_counter >= 8'h3f) begin
                  test_packet_counter <= 8'h0;
               end
               else begin
                  test_packet_counter <= test_packet_counter + 1;
               end
            end
         end
         // Special Byte xFF used instead of normal count
         // to avoid false sync on x47
         else if (test_data_counter == 8'h47) begin //71
            if (TS_DATA != 8'hFF) begin
               test_pattern_error_detect <= 1'b1;
            end
         end
         else begin
            // Test pattern check
            if (TS_DATA != test_data_counter) begin
               test_pattern_error_detect <= 1'b1;
            end

            // Continuity Counter PID Check
            if (test_data_counter == 2 && TS_DATA == 8'h40) begin
               check_continuity <= 1'b1;
            end
            
            if (check_continuity == 1'b1 && test_data_counter == 3) begin
               check_continuity   <= 1'b0;
               continuity_counter <= continuity_counter + 1;
               
               // Continuity Counter Count Value Check
               if (TS_DATA[3:0] != continuity_counter) begin
                  continuity_error_detect <= 1'b1;
                  continuity_counter      <= TS_DATA[3:0] + 1;
               end
            end
            
            if (test_data_counter == 8'hBB) begin //187
               test_data_counter <= 0;
            end
         end
      end
      //end
      //else begin
      //   test_packet_counter <= 0;
      //   test_data_counter   <= 0;
      //end
   end
end

//*************************************************
// Error Detect Logic
//*************************************************
reg [7:0] dataoverflowcntlocal;
assign DATAOVERFLOWCNT = dataoverflowcntlocal;
always @(posedge CLK) begin : pattern_detect_proc2
   if (RST) begin
      TS_SYNC_LOSS_COUNT       <= 0;
      SHIFTED_BYTE_COUNT       <= 0;
      PATTERN_DATA_ERROR_COUNT <= 0;
      PATTERN_PKT_LOSS_COUNT   <= 0;
      CONTINUITY_ERROR_COUNT   <= 0;
      dataoverflowcntlocal     <= 0;
   end
   else begin
      if(ts_data_sync_loss_detect) begin
         TS_SYNC_LOSS_COUNT <= TS_SYNC_LOSS_COUNT + 1;
      end
      
      if (mosi_shift_reg_valid) begin
         SHIFTED_BYTE_COUNT <= SHIFTED_BYTE_COUNT + 1;
      end
      
      if (test_pattern_error_detect) begin
         PATTERN_DATA_ERROR_COUNT <= PATTERN_DATA_ERROR_COUNT + 1;
      end
      
      if (test_packet_loss_detect) begin
         PATTERN_PKT_LOSS_COUNT <= PATTERN_PKT_LOSS_COUNT + 1;
      end
      
      if (continuity_error_detect) begin
         CONTINUITY_ERROR_COUNT <= CONTINUITY_ERROR_COUNT + 1;
      end
      
      if (reset_counts_rise_edge) begin
         TS_SYNC_LOSS_COUNT       <= 0;
         SHIFTED_BYTE_COUNT       <= 0;
         PATTERN_DATA_ERROR_COUNT <= 0;
         PATTERN_PKT_LOSS_COUNT   <= 0;
         CONTINUITY_ERROR_COUNT   <= 0;
      end
   end
end

//*************************************************
// data rate detection
//*************************************************
reg [25:0] seccnt;
reg [22:0] byterateaccu;
(* noprune *) reg [15:0] tsbitrate1klocal;
assign TSBITRATE1K = tsbitrate1klocal;

always @(posedge CLK) begin//50mhz clock
  if(seccnt >= 26'd50000000 ) begin
    seccnt <= 0;
    tsbitrate1klocal <= byterateaccu[22:7];
    byterateaccu <= 0;
                          end
  else begin
    seccnt <= seccnt +1;
    if(ts_data_valid_mon) 
      if(~&byterateaccu) byterateaccu <= byterateaccu+1;
       end
end            
    
always @(*) begin
TSBITRATE1k = tsbitrate1klocal;
end
endmodule