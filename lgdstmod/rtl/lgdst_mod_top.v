/* Porting Checking List
  0. Module Checking List
    0.1 DVB T2: Done
    0.2 LVDS & PLL: Done
    0.3 rf_vid_server: DONE
    0.4 Nios & Hedrain's design: Connection DONE!!
    0.5 SPI Slave and Reg map: Done
    0.6 HELM with RS232: Done
    0.7 Board-to-Board Module: No Need for now!!
    0.8 UART from Atmel: Disabled!!
    0.9 ADI Ctrl out/in: Done

  1. DVB T2 integration: Done
  2. DVB T2 TX circuit: Done
      Need simulation to check the bit order: Done 2016/01/09
      Use a MUX for SoftCPU (xx_mb),
  3. DVB T2 RX circuit: Done 
      Need simulation to check the bit order: Done 2016/01/09
  4. DVB T2 igain value: Need check by Bang
  5. NIOS integration: Bang will do
  6. Build a NIOS & Atmel Path for ADI9364 Control:
  7. Check ADI9364 Initialization Seq:
     Yendo do first pass
  8. Integrate Helm with RS232:
     Connect usr_mem_* to module config_mem
  9. Integrate rf_vid_server:
     clk and vid_clk change to 50MHz, 1st priority: Done
     cbr_data*: connect to lgdst_mod_core (from Hedrian's design): Done
     TS Data Interface: Done, Connect to dvb t2
     Check cbr_vid_buffer Behavior:
 10. SPI Slave controller:
     ref: CH31, Atmel-11289-32-bit-Cortex-M4-Microcontroller-SAM-G55_Datasheet
     Fix mode 16-bit format: Need Confirmation by Liyen & Yendo
     1st priority, build a new one and rd/wr for config_rw mem
 11. i2smclk output: Done !!
      12MHz generated from 24MHz OSC and 
      feed it to Atmel U54.4 (PA4/I2SMCLK)
 12. 50MHz and 100MHz for Hedrain's design: Done !!
 13. ADI control in/out: Done 
      Connect to lgdst_mode_core
 14. Check clk scheme of dvb t2

 /////////////////////////////////////////////////////////////////////////////////////////////////
 // Revision History:
 // 2016/02/16:
 //   1. Remove LVDS's *_n pins
 //   2. Add generate option DVBT_VER != (T or T2)
 //   3. Change lgdst_mod_core's IO: spi5_* --> spi_*
 //   4. Remove Board-to-Board Connection Pins
 //   5. Integrate spi_slv_8b8b and SPI connect to Atmel's SPI1
 //   6. Change rst_b design since fpga_rst_b is un-connected!!
 //   7. Integrate cpu_health signal and Pin located AB7
 //   8. Set initial value of {rf_sw1, rf_sw2} = 2'b10
 //   9. Change i2sws0 as output and output 32K signal
 //  10. set fpga_reset_a as tri-state input and connect to
 //                                    config_rw_default[0][0]
 //  11. Add parameter for generating POF: POF_GEN="TRUE"
 // 2016/02/20:
 //   1. spi_slv_8b8b is connected to Atmel's SPI0
 //      ts_data_spi is connected to Atmel's SPI1
 // 2016/02/26
 //   1. Move fpga_reset_a to config_r[0] bit 0
 //      Move config_r[1] = ts_sync_loss_count from config_r[54]
 //      Move config_r[2] = shifted_byte_count from config_r[55]
 //      Connect config_r[3] = pattern_data_error_count
 //      Connect config_r[4] = pattern_pkt_loss_count
 //      Move test_mode =    config_rw[2] bit 1 from config_r[53][0];
 //      Move reset_counts = config_rw[2] bit 0 from config_r[53][1];
 //      test_mode default to 1'b1
 //      read_counts default to 1'b0
 //   2. osc_pll added 3rd clock port for 200MHz
 //      Add module tx_clk_gen
 //   3. Add port usr_mem_wr_msk from helm_uart --> config_mem
 //      Based on Bang's version: SVN 895 
*/

`timescale 1ns /10ps
`include "ver_info.v"

module lgdst_mod_top #(
  //parameter VERSION2 = "FALSE",
  //parameter POF_GEN = "FALSE", //
  //parameter MODULATOR_ENABLE = "FALSE",
  //parameter PROCESSOR_ENABLE = "FALSE",
  parameter MODULATOR_ENABLE = "TRUE",
  parameter PROCESSOR_ENABLE = "TRUE",

  parameter DVBT_VER = "T",     // T2: dvb_t2, T: dvb_t
  parameter CONFIG_SIZE = 160,  // in bytes
  parameter STATUS_SIZE = 56,   // in bytes
  parameter PROC_STAT_SIZE = 8  // in bytes
)(
  input         clk_24M,
  input         fpga_rst_b,     // POR active low
  input         fpga_reset_a,   // backup POR connect from fpga_rst_b

  // The following ADI9364 pin controlled by Atmel's GPIOs
  output        reset_adi,
  output        en_agc,
  output        enable,
  output        txn_rx,
  output        sync_in,            // Sync in multiple ADI env

  // Signals from ADI9634
  //input         adi_clk_out,        // from ADI's XTAL 40MHz
  output        adi_fb_clk_p,       //V1:PIN AA22, V2:Y12
  input         adi_data_clk_p, 
  input         adi_rx_frame_p,
  input   [5:0] adi_rx_p,
  output        adi_tx_frame_p,
  output  [5:0] adi_tx_p,
  output  [3:0] adi_ctrl_in,
  input   [7:0] adi_ctrl_out,

  //additional ports for witching back to the Version 1
  //output        adi_fb_clk_p_v1,       //V1:PIN AA22, V2:Y12

  output        adi_pll_clk_out,  //source from FPGA (V2:R22)
  input         adi_pll_clk_in,   //looped backed in to drive top-right PLL (V2:G13)

  // Signals from Atmel
  //inout       fd_15,         //Reserved GPIOs
  //inout       fd_14,         //Reserved GPIOs
  //inout       fd_12,         //Reserved GPIOs
  //inout       fd_09,         //Reserved GPIOs
  //inout       fd_08,         //Reserved GPIOs
  //inout       fd_07,         //Reserved GPIOs
  //inout       fd_06,         //Reserved GPIOs
  //inout       fd_05,         //Reserved GPIOs
  //inout       fd_04,         //Reserved GPIOs
  //inout       fd_00,         //Reserved GPIOs

  // SPI controlled by Ateml -- Video Pipe
  output       spi5_spck,         
  output       spi5_npcs0,
  output       spi5_mosi,     
  input        spi5_miso,

  // RF curcuit control
  output        rf_sw1,
  output        rf_sw2,
  
  // UARTs
  //input       fpga_uart_rx, //from Atmel PA27
  //output      fpga_uart_tx, //from Atmel PA28
  input         helm_rxd,   // from TP_AB22, to Helm
  output        helm_txd,   // from TP_AA22, to Helm
  
  // SPI controlled by Ateml -- Video Pipe
  input         spi1_spck,
  input         spi1_npcs0,
  input         spi1_mosi,
  output        spi1_miso,
 
  // SPI controlled by Ateml
  input         spi0_spck,
  input         spi0_npcs0,
  input         spi0_mosi,
  output        spi0_miso,

  // I2S
  output        i2smclk,
  input         i2sck0,  //sid: selection pin for the fpga upgrade
  output        i2sws0,  //YH: changed to 32K output for CPU
  input         i2sdi0,
  output        i2sdo0, 

  // LEDs
  output  [6:3] led,
  output        wifi_active,

  // Board-to_board Conn.
  /*
  input         clk1p,
  output        clkoutp,
  
  input         diff_rx_t3p,
  input         diff_rx_b15n,
  input         diff_rx_b15p,
  output        diff_tx_t6n,
  output        diff_tx_t6p,
  input         diff_rx_b7n,
  input         diff_rx_b7p,
  output        diff_tx_t8n,
  output        diff_tx_t8p,
  output        diff_tx_t10n,
  output        diff_tx_t10p,
  output        diff_tx_t11n,
  output        diff_tx_t11p,
  input         diff_rx_t13n,
  input         diff_rx_t13p,
  output        diff_tx_t14n,
  output        diff_tx_t14p,
  output        diff_tx_t16n,
  output        diff_tx_t16p,
  output        diff_tx_t18n, // J2 name error
  output        diff_tx_t18p,
  input         diff_rx_t19n,
  input         diff_rx_t19p,
  output        diff_tx_t20n,
  output        diff_tx_t20p,
  output        diff_tx_t23n, // J2 FPGA name error 
  output        diff_tx_t23p,
  
  output        diff_tx_l9n,
  output        diff_tx_l9p,
  input         diff_rx_l10n,
  input         diff_rx_l10p,
  input         diff_rx_l11n,
  input         diff_rx_l11p,
  output        diff_tx_l12n,
  output        diff_tx_l12p,
  output        diff_tx_l13n,
  output        diff_tx_l13p,
  */
  
  // Debug Ports
  input         cpu_health,
  output [13:8] dbg_tp
);
  localparam RF_CONFIG_SIZE = 16;
  localparam VID_FMT_720p60 = 4'b0000;

  localparam MB_RF_CONFIG_OFFSET = 8'd64;

  assign        sync_in = 1'b0;

  wire          clk12m, clk50m, clk100m;

  wire          clk1, clkout;
  wire          rf_l_clk, rf_data_clk;

  reg     [1:0] i2s_sh_reg, i2s_sh_reg2;

  wire    [1:0] tx_iq_gain;
  
  wire [PROC_STAT_SIZE*8-1:0] nios_usr_stat_page;
  // monitoring
  wire [CONFIG_SIZE*8-1:0] config_vec;
  wire [CONFIG_SIZE*8-1:0] config_default_vec;
  wire [STATUS_SIZE*8-1:0] config_r_vec;

  wire  [7:0] config_rw[CONFIG_SIZE-1:0];
  wire  [7:0] config_rw_default[CONFIG_SIZE-1:0];
  wire  [7:0] config_r[STATUS_SIZE-1:0];
  wire  [7:0] rf_conf_array[RF_CONFIG_SIZE-1:0];
  wire  [7:0] proc_stat_array[PROC_STAT_SIZE-1:0];
  //wire  [7:0] proc_stat[PROC_STAT_SIZE-1:0];

  wire  [5:0] rf_rx_data_p_s, rf_rx_data_n_s;
  wire        rx_frame_p_s, rx_frame_n_s;
  reg   [5:0] rf_tx_p_data_p, rf_tx_p_data_n;
  reg         rf_tx_p_frame;

  reg  [11:0] rf_tx_data_i_dvbt, rf_tx_data_q_dvbt;
  reg         rf_tx_frame_dvbt;

  wire        dvbt_tx_enable;
  wire  [5:0] rf_tx_p_data_p_mb, rf_tx_p_data_n_mb;
  wire        rf_tx_p_frame_mb;

  //Helm Register Config and Status Interfaces
  wire          test_mode;
  wire          reset_counts;
  wire    [7:0] ts_sync_loss_count;
  wire    [7:0] shifted_byte_count;
  wire    [7:0] pattern_data_error_count;
  wire    [7:0] pattern_pkt_loss_count;
  wire   [15:0] tsbitrate1k; //added by sid
  wire    [7:0] continuity_error_count; //added by sid
  wire   [15:0] fifo_bit_rate;
  wire          rf_ordy_out;
  wire          pa_en; //pinW22

  // Signals for rf_vid_server
  (* noprune *) wire  [7:0] cbr_data;
  wire        cbr_data_vld;
  (* noprune *) wire  [7:0] st_data_o;
  wire        st_en_o;
  wire        st_ts_sync_o;
  wire        ts_null_state;
  wire        ts_vid_buf_empty;
  wire  [7:0] ts_vid_drop_cnt;
  wire  [7:0] ts_null_insert_cnt;

  // Signals for DVB T2
  wire        clk146;
  wire        rf_irst;  // TBD
  wire  [7:0] rf_idat = st_data_o;
  wire [31:0] rf_ifreq = 32'd0; //default: 1073729241
  wire [15:0] rf_igain = 16'd1609;
  wire [ 2:0] rf_icode;
  wire  [1:0] rf_iguard;
  wire  [1:0] rf_imod;
  (* noprune *) wire        rf_isop = st_ts_sync_o;
  (* noprune *) wire        rf_ival = st_en_o;
  wire [15:0] rf_odati;
  wire [15:0] rf_odatq;
  (* noprune *) wire        rf_ordy;

  reg   [3:0] rf_clk_cnt;
  reg   [3:0] clk146_cnt;
  reg         rf_out_iq_wr;
  reg         rf_out_iq_rd;
  reg  [15:0] rf_out_i_ext, rf_out_q_ext;
  reg  [31:0] rf_out_iq_din;
  wire [31:0] rf_out_iq_dout;
  wire [15:0] rf_out_i_dout;
  wire [15:0] rf_out_q_dout;
  wire  [4:0] rf_rd_data_count;
  reg         rf_out_iq_active = 1'b0;
                    
  wire         axi_ad9361_clk;
  wire         axi_ad9361_rx_clk_in_p;     
  wire         axi_ad9361_rx_clk_in_n;
  wire         axi_ad9361_rx_frame_in_p;   
  wire         axi_ad9361_rx_frame_in_n;
  wire [5:0]   axi_ad9361_rx_data_in_p;    
  wire [5:0]   axi_ad9361_rx_data_in_n;
  wire         axi_ad9361_tx_clk_out_p;    
  wire         axi_ad9361_tx_clk_out_n;
  wire         axi_ad9361_tx_frame_out_p;  
  wire         axi_ad9361_tx_frame_out_n;
  wire [5:0]   axi_ad9361_tx_data_out_p;   
  wire [5:0]   axi_ad9361_tx_data_out_n;
  wire         axi_ad9361_adc_enable_i0;      
  wire         axi_ad9361_adc_valid_i0;
  wire [15:0]  axi_ad9361_adc_data_i0;        
  wire         axi_ad9361_adc_enable_q0;
  wire         axi_ad9361_adc_valid_q0;       
  wire [15:0]  axi_ad9361_adc_data_q0;
  wire         axi_ad9361_adc_enable_i1;      
  wire         axi_ad9361_adc_valid_i1;
  wire [15:0]  axi_ad9361_adc_data_i1;        
  wire         axi_ad9361_adc_enable_q1;
  wire         axi_ad9361_adc_valid_q1;       
  wire [15:0]  axi_ad9361_adc_data_q1;
  wire         axi_ad9361_adc_dovf;           
  wire         axi_ad9361_adc_dunf;
  wire         axi_ad9361_dac_enable_i0;      
  wire         axi_ad9361_dac_valid_i0;
  wire [15:0]  axi_ad9361_dac_data_i0;        
  wire         axi_ad9361_dac_enable_q0;
  wire         axi_ad9361_dac_valid_q0;       
  wire [15:0]  axi_ad9361_dac_data_q0;
  wire         axi_ad9361_dac_enable_i1;      
  wire         axi_ad9361_dac_valid_i1;
  wire [15:0]  axi_ad9361_dac_data_i1;        
  wire         axi_ad9361_dac_enable_q1;
  wire         axi_ad9361_dac_valid_q1;       
  wire [15:0]  axi_ad9361_dac_data_q1;
  wire         axi_ad9361_dac_dovf;           
  wire         axi_ad9361_dac_dunf;
  wire         axi_ad9361_l_clk;           
  wire         axi_ad9361_dac_sync_in;
  wire         axi_ad9361_dac_sync_out;    
  wire         nios_clk;
  wire [4:0]   gpio_export;      
  wire         reg_map_usr_rd_word_en;
  wire [13:0]   reg_map_usr_rd_word_addr;             
  wire [31:0]  reg_map_usr_rd_word_data;
  wire         reg_map_usr_wr_word_en;               
  wire [3:0]   reg_map_usr_wr_byte_indx;
  wire [13:0]   reg_map_usr_wr_word_addr;             
  wire [31:0]  reg_map_usr_wr_word_data;
  wire [255:0] reg_map_test_out;                     
  wire         reset_reset_n = 1'b1;
  wire         spi_ad9361_external_MISO;             
  wire         spi_ad9361_external_MOSI;
  wire         spi_ad9361_external_SCLK;             
  wire         spi_ad9361_external_SS_n;
  wire [31:0]  sys_gpio_in_port; 
  wire [31:0]  sys_gpio_out_port;

  wire          spi_wr, spi_rd;
  wire   [11:0] spi_adr;
  wire    [7:0] spi_din, spi_dout;
  wire          osc_pll_locked;

  // HELM Mem access
  wire    [7:0] rs232_mem_page;
  wire    [7:0] rs232_mem_offset;
  wire          rs232_mem_wr_en;
  wire    [7:0] rs232_mem_wr_data;
  wire    [7:0] rs232_mem_wr_msk;
  wire          rs232_mem_rd_en;
  wire    [7:0] rs232_mem_rd_data;
  wire          rs232_mem_ack;
  wire    [7:0] alive_cntr;

  reg     [3:0] rst_pll_dly = 4'd15;
  reg           rst_pll = 1'b1;
  reg     [3:0] rst_dly = 4'd15;
  reg           rst_b = 1'b0;
  wire          rf_vid_server_rstb = rst_b;
  wire          tx_clk_locked;
  wire          proc_uart_rxd;
  wire          proc_uart_txd;

  always @(posedge clk_24M)
  begin
    rst_pll_dly <= rst_pll_dly + {4{|rst_pll_dly}};
    rst_pll <= |rst_pll_dly;
  end
  always @(posedge clk50m)
  begin
    if (osc_pll_locked)
    begin
      rst_dly <= rst_dly+{4{|rst_dly}};
      rst_b <= ~|rst_dly;
    end
  end

  //Yendo Test Code
  reg [27:0] clkcnt;
  reg [7:0]  seccnt;
  reg ledval;
  always @(posedge clk50m) 
  begin
    if(clkcnt>= (23999999)) 
    begin
      clkcnt<=0;
      seccnt<=seccnt+1;
    end
    else
      clkcnt<=clkcnt+1;

    if(clkcnt==0) 
      ledval<= ~ledval;
  end 
  
  //test <= config_rw [44]; //testing out the value of the tx power on
  assign led[3] = ((config_rw[68]==8'h80))? 1'b1: 1'b0;
  assign led[4] = (rf_calc_done)? seccnt[0] : 1'b0; //nios is done
  assign led[5] = cpu_health; //this is the atmel connection
  assign led[6] = seccnt[0];

  reg [10:0] clk32kcnt;
  reg clk32k;

  always @(posedge clk_24M)
  begin
    if (clk32kcnt >= 11'd365)
    begin
      clk32kcnt <= 11'b0;
      clk32k <= ~clk32k;
    end
    else
      clk32kcnt <= clk32kcnt + 1;
  end
  assign i2sws0 = clk32k;
  //Yendo Test Code -- End

  always @(posedge i2smclk)
  begin
      i2s_sh_reg <= {i2s_sh_reg[0], i2sdi0};
  end

  function [15:0] clip12(input [3:0] left, input [11:0] val);
  begin
    if (left[3] == 1'b0) begin//sign bit == 0, positive
      if ((|{left, val[11]}) == 0) //no overflow
        clip12 = {4'h0, val};
      else
        clip12 = {4'h0, 12'h7ff};
    end
    else begin //negative
      if (&{left, val[11]} == 1) //no overflow
        clip12 = {4'hf, val};
      else
        clip12 = {4'hf, 12'h801};
    end
  end
  endfunction

  assign tx_iq_gain = config_rw[43][1:0]; //taken from the hardcoded value
  always @(posedge clk146) 
  begin
    clk146_cnt <= clk146_cnt + 1;
    if (clk146_cnt[1:0] == 2'b00)
      rf_out_iq_wr <= 1'b1;  //downsample by 4 => sample rate of 36.57 Msps for 8MHz bandwidth
    else
      rf_out_iq_wr <= 1'b0;

    case(tx_iq_gain)
    2'b01: begin
      rf_out_i_ext <= {{4{rf_odati[15]}}, rf_odati[14:3]};
      rf_out_q_ext <= {{4{rf_odatq[15]}}, rf_odatq[14:3]};
      //rf_out_iq_din <= {clip12({4{rf_odati[15]}}, rf_odati[14:3]), clip12({4{rf_odatq[15]}}, rf_odatq[14:3])};
    end
        
    2'b10: begin
      rf_out_i_ext <= {{2{rf_odati[15]}}, rf_odati[15:14], rf_odati[13:2]};
      rf_out_q_ext <= {{2{rf_odatq[15]}}, rf_odatq[15:14], rf_odatq[13:2]};
      //rf_out_iq_din <= {clip12({2{rf_odati[15]}, rf_odati[15:14]}, rf_odati[13:2]), clip12({2{rf_odatq[15]}, rf_odatq[15:14]}, rf_odatq[13:2])};
    end
        
    2'b11: begin
      rf_out_i_ext <= {rf_odati[15], rf_odati[15:13], rf_odati[12:1]};
      rf_out_q_ext <= {rf_odatq[15], rf_odatq[15:13], rf_odatq[12:1]};
      //rf_out_iq_din <= {clip12({rf_odati[15], rf_odati[15:13]}, rf_odati[12:1]), clip12({rf_odatq[15], rf_odatq[15:13]}, rf_odatq[12:1])};
    end
        
    default: begin
      rf_out_i_ext <= {{4{rf_odati[15]}}, rf_odati[15:4]};
      rf_out_q_ext <= {{4{rf_odatq[15]}}, rf_odatq[15:4]};
      //rf_out_iq_din <= {rf_odati[15:4], rf_odatq[15:4]};
    end
    endcase

    rf_out_iq_din <= {clip12(rf_out_i_ext[15:12], rf_out_i_ext[11:0]), clip12(rf_out_q_ext[15:12], rf_out_q_ext[11:0])};
  end
  //assign rf_out_iq_dout = rf_out_iq_din; // TBD
  assign rf_out_i_dout = rf_out_iq_dout[31:16];
  assign rf_out_q_dout = rf_out_iq_dout[15:0];

  //assign rf_rd_data_count = 5'd0; // from rf_tx_out_fifo

  always @(posedge rf_data_clk)
  begin
    rf_clk_cnt <= rf_clk_cnt + 1;

    //rf_tx_p_data_p <= (~dvbt_tx_enable)? rf_tx_p_data_p_mb : rf_tx_p_data_p_dvbt;
    //rf_tx_p_data_n <= (~dvbt_tx_enable)? rf_tx_p_data_n_mb : rf_tx_p_data_n_dvbt;
    //rf_tx_p_frame  <= (~dvbt_tx_enable)? rf_tx_p_frame_mb  : rf_tx_p_frame_dvbt;

    if (rf_irst)
      rf_out_iq_active <= 1'b0;
    else begin
      if (rf_rd_data_count >= 8)
        rf_out_iq_active <= 1'b1;
    end
    
    rf_out_iq_rd <= rf_clk_cnt[0] & rf_out_iq_active; //read every other clk
    rf_tx_frame_dvbt <= rf_out_iq_rd;
    
    //serialization factor = 2
    if (rf_out_iq_rd) begin
        rf_tx_data_i_dvbt[5:0] <= rf_out_i_dout[11:6]; //I[11:6]
        rf_tx_data_q_dvbt[5:0] <= rf_out_q_dout[11:6]; //Q[11:6]
    end
    else begin
        rf_tx_data_i_dvbt[5:0] <= rf_out_i_dout[5:0]; //I[5:0]
        rf_tx_data_q_dvbt[5:0] <= rf_out_q_dout[5:0]; //Q[5:0]
    end
    
    /*
    //serialization factor = 4
    rf_out_iq_rd <= rf_out_iq_active; //rf_clk_cnt[0] & rf_out_iq_active; //read every other clk
    rf_tx_frame_dvbt <= rf_out_iq_rd;

    if (rf_out_iq_rd) 
    begin
      rf_tx_data_i_dvbt <= rf_out_i_dout[11:0];
      rf_tx_data_q_dvbt <= rf_out_q_dout[11:0];
    end*/
  end

  osc_pll i_osc_pll(
    .refclk(clk_24M),               .rst(rst_pll),

    .outclk_0(clk100m),             .outclk_1(clk50m),
    .outclk_2(clk12m),
    .outclk_3(clk400m),
    .locked(osc_pll_locked)
  );
  assign i2smclk = clk12m;

/*
  idat - input (information) data
  iguard - guard interval:
    0 - 1/32;
    1 - 1/16;
    2 - 1/8;
    3 - 1/4.
  imod - modulation:
    0 - QPSK;
    1 - 16-QAM;
    2 - 64-QAM.
  irst   - asynchronous reset
  isop   - input sync-word byte marker (0x47 TS)
  ival   - input data valid
  odatif - modulator output at intermediate frequency
  odati  - modulator output at baseband (I channel)
  odatq  - modulator output at baseband (Q channel)
  ordy   - ready to accept input data
  */
  assign rf_icode  = rf_conf_array[0][6:4];
  assign rf_iguard = rf_conf_array[0][3:2];
  assign rf_imod   = rf_conf_array[0][1:0];

  generate
    //if (POF_GEN == "TRUE")
    if (MODULATOR_ENABLE == "FALSE")
    begin
      assign rf_odati = 'd0;
      assign rf_odatq = 'd0;
      assign rf_ordy  = 'd0;
    end 
    else if ( DVBT_VER == "T2" )
    begin
      tx i_dvbt2_tx(
        .iclk(clk146),                  .irst(rf_irst),

        .idat(rf_idat),
        //.ifreq(rf_ifreq),               .igain(rf_igain),
        .iguard(rf_iguard),             .imod(rf_imod),
        .isop(rf_isop),                 .ival(rf_ival),
        .odati(rf_odati),               .odatq(rf_odatq),
        .ordy(rf_ordy)
      );
    end
    else if ( DVBT_VER == "T" )
    begin
      tx i_dvbt_tx(
        .iclk(clk146),                  .irst(rf_irst),
  
        .icode(rf_icode),
        .idat(rf_idat),
        .iguard(rf_iguard),             .imod(rf_imod),
        .isop(rf_isop),                 .ival(rf_ival),
        .odati(rf_odati),               .odatq(rf_odatq),
        .ordy(rf_ordy)
      );
    end
    else
    begin
      assign rf_odati = 'd0;
      assign rf_odatq = 'd0;
      assign rf_ordy  = 'd0;
    end
  endgenerate
  
  generate
   if (MODULATOR_ENABLE == "TRUE")
   begin
	lgdst_mod_monitor mod_monitor (
	.clk50m(clk50m),
	.clk146(clk146),
	
	.rf_ordy(rf_ordy),
	.rf_irst(rf_irst),
	
	.data(rf_idat),
	
	.rf_ordy_out(rf_ordy_out),
	.fifo_bit_rate(fifo_bit_rate),
	);
	end
	else begin
	assign rf_ordy_out = 0;
	end
  endgenerate

  (* noprune *) reg [25:0] count;
  (* noprune *) reg tick;
//generic tick counter for the use of delay
  always @ (posedge clk50m)
  begin
  if(count >= 26'd50000000 ) 
   begin
   count <= 0;
   tick <= 1;
   end
  else 
   begin
   count <= count +1;
   tick <= 0;
   end
  end
  
  //logic to make a delay of 5 sec before turning on the pa_en pin 
  (* noprune *) reg [3:0] flag;
  (* noprune *) reg [3:0] power_en;
  always @ (posedge clk50m)
  begin
  if ((tick == 1) && (flag == 5))
	power_en <= 1;
  else if ((tick == 1) && (flag < 5))
	begin
	flag <= flag + 1;
	power_en <= 0;
	end
  else
   flag <= flag;
  end
	
fifo_fwft_16x32 rf_tx_out_fifo(
    .aclr    (rf_irst),
    .data    (rf_out_iq_din),
    .rdclk   (rf_data_clk),
    .rdreq   (rf_out_iq_rd),
    .wrclk   (clk146),
    .wrreq   (rf_out_iq_wr),
    .q       (rf_out_iq_dout),
    .rdempty (),
    .rdusedw (rf_rd_data_count),
    .wrfull  ()
);

  genvar ci;
  generate for(ci = 0; ci < CONFIG_SIZE; ci = ci + 1) begin: config_gen_block
    assign config_rw[ci] = config_vec[((ci + 1) * 8 - 1) : (ci * 8)];
    assign config_default_vec[((ci + 1) * 8 - 1) : (ci * 8)] = config_rw_default[ci];
  end
  endgenerate

  generate for(ci = 0; ci < STATUS_SIZE; ci = ci + 1) begin: status_gen_block
    assign config_r_vec[((ci + 1) * 8 - 1) : (ci * 8)] = config_r[ci];
  end
  endgenerate

  generate for(ci = 0; ci < RF_CONFIG_SIZE; ci = ci + 1) begin: rf_config_gen_block
    assign rf_conf_array[ci] = config_rw[ci + MB_RF_CONFIG_OFFSET];
  end
  endgenerate

  generate for(ci = 0; ci < PROC_STAT_SIZE; ci = ci + 1) begin: proc_stat_gen_block
    assign proc_stat_array[ci] = nios_usr_stat_page[((ci + 1) * 8 - 1) : (ci * 8)];
  end
  endgenerate

  //generate for(ci = 0; ci < PROC_STAT_SIZE; ci = ci + 1) begin: proc_stat_gen_block
  //  assign proc_stat[ci] = mb_usr_stat_page[((ci + 1) * 8 - 1) : (ci * 8)];
  //end
  //endgenerate

  rf_vid_server i_rf_vid_svr(
    .clk            (clk146), 
    .rst_b          (rf_vid_server_rstb),

    // Video Buffer Interface from tp_top
    .vid_clk        (clk50m), 
    .vid_data       (cbr_data),
    .vid_data_vld   (cbr_data_vld), 

    // Output TS Data Interface
    .rf_tx_ready    (rf_ordy),
    .ts_data_out    (st_data_o),
    .ts_data_vld    (st_en_o),
    .ts_sync        (st_ts_sync_o),

    // Kevin: unused outputs
    .ts_null_out    (ts_null_state),
    .vid_buf_empty  (ts_vid_buf_empty),
    .vid_drop_cnt   (ts_vid_drop_cnt),
    .null_insert_cnt(ts_null_insert_cnt)
    // Kevin: unused outputs -- End
  );

  reg clk_12m=1'b0;
  reg clk_6m=1'b0;
  //divide by 4 clk for the remote update block
  always @(posedge clk_24M)
  begin
   clk_12m <= ~clk_12m;
  end
  always @(posedge clk_12m)
  begin
   clk_6m <= ~clk_6m;
  end
  
  //checking if the bit is being set for reconfiguration
  (* noprune *) wire trig = config_rw[12] [0];
  (* noprune *) wire busy;
  (* noprune *) reg reconfig=1'b0;
  (* noprune *) reg read_param=1'b0;
  (* noprune *) reg [3:0] check=4'd0;
  //declaratoins for a sequential logic
  (* noprune *) reg reset;
  (* noprune *) reg tmp;
  reg [31:0] addr_sel;
  reg [2:0] param;
  reg write_param=1'b0;
  reg [1:0] reset_count=2'b0;
  wire pof_error;

  //resetting the remote update
  always @(negedge clk_6m)
  begin
   if (reset_count==2'b11)
   begin
    reset <= 1'b0;
   end
   else
   begin
    reset <= 1'b1;
    reset_count <= reset_count+1'b1;
   end
  end
  
  always @ (negedge clk_6m)//(posedge clk_24M) //(posedge spi0_spck) // 
  begin
  tmp <= pof_error;
  if (reset==1'b0)
  begin
   if (check==3'd0)
	begin
  //reading the reconfiguration condition
	  param <= 3'b000;
     read_param <= 1'b1;
	  if (read_param)
	  begin
	   if (busy)
		begin
		 read_param <= 1'b0;
		 check <= 3'd1;
		 param <= 3'b000;
		end // end of the if condition of the busy signal
		else
		begin
		 read_param <= read_param;
		end
	  end//end of the if condition of the read param
	end //end of the if condition of check=3'd0
	
	  if(check==3'd1)
	  begin
	   if (busy==1'b0)
		check <= 3'd2;
		else
		check <= check;
	  end //else condition of the read param
	  
  //setting the AnF bit
     if (check==3'd2)  
	  begin
	   param <= 3'b101;
		if (param==3'b101)
		begin
		write_param <= 1'b1;
		addr_sel <= 32'h1;
		end
		 if (write_param)
		 begin
		  if (busy)
		  begin
		   write_param <= 1'b0;
			check <= 3'd3;
			addr_sel <= 32'h0;
			param <= 3'b000;
		  end//end of the if condition of the busy signal
		  else
		  begin
		   write_param <= write_param;
		  end		  
		 end//end of the if condition of the write param
	  end//end of the if condition of the check=d3
	  
	  if (check==3'd3)
	  begin
	   if (busy==1'b0)
		check<=3'd4;
		else
		check<=check;
	  end

	  //triggering the reconfiguration and giving the specific address
	  if((check==4'd4) && (trig))
	  begin
	   param <= 3'b100;
		if (param==3'b100)
		begin
		write_param <= 1'b1;
		addr_sel <= 32'h00295700; //32'h0;checking the reconfiguration by giving the address 32'h0
		end
		 if(write_param)
		 begin
		  if(busy)
		  begin
		   write_param<=1'b0;
			check<=4'd5;
			addr_sel<=32'h0;
			param <= 3'b000;
		  end
		  else
		  begin
		   write_param <= write_param;
		  end //end of the else of the busy condition
		 end //end of the if condition of the write_param
	  end //end of the check=3'd3
	 
	 //triggering the reconfiguration signal to active high 
	  if (check==4'd5)
	  begin
	   if(busy==1'b0)
		begin
		 check <= 4'd6;
		 reconfig <= 1'b1;
		end
		else
		begin
		 check <= check;
		end
	  end
	 
	 //triggering the reconfig signal to low 
	  if (check==4'd6)
	  begin
	   if (busy)
		begin
		 //reconfig <= 1'b0;
		 check <= 4'd7;
		end
		else
		begin
		 reconfig <= reconfig;
		 check <= check;
		end
	  end
	 
	 //bringing back to the state before the reconfiguration trigger
	  if (check==4'd7)
	  begin
	  reconfig <= 1'b0;
	   if (trig==1'b0)
	   check<=4'd4;
//		else
//		check <= check;
	  end

	end//end of the reset condition
  end
 
// Signals to connect the remote update to the asmi parallel
  wire asmi_busy, asmi_data_valid, asmi_read, asmi_rden;
  wire [7:0] asmi_dataout;
  wire [31:0] asmi_addr;
  
  
//remote update IP block for loading the factory sof and check for any error while loading the application image
  remote_update factory_image (
  .clock(clk_6m),
  .reset(reset),
  .param (param),
  .write_param(write_param),
  .read_param(read_param),
  .reconfig(reconfig),
  .data_in(addr_sel),
  .busy(busy),
  .pof_error(pof_error),
  .asmi_busy(asmi_busy),
  .asmi_data_valid(asmi_data_valid),
  .asmi_dataout(asmi_dataout),
  .asmi_addr(asmi_addr),
  .asmi_read(asmi_read),
  .asmi_rden(asmi_rden)
  );

//altera asmi IP to check the specified address
  altera_asmi altera_asmi(
  .clkin(clk_6m),
  .reset(reset),
  .addr(asmi_addr),  
  .en4b_addr(),
  .rden(asmi_rden),
  .read(asmi_read),
  .wren(),
  .busy(asmi_busy),
  .data_valid(asmi_data_valid),
  .dataout(asmi_dataout)  
  );
  
  
  spi_slv_8b8b i_spi_slv(
    .clk(clk50m),                       .rst_b(rst_b),

    .spi_clk(spi0_spck),                .spi_en_n(spi0_npcs0),
    .spi_mosi(spi0_mosi),               .spi_miso(spi0_miso),

    .adr(spi_adr),     
    .wr_en(spi_wr),                     .rd_en(spi_rd),
    .dout(spi_dout),                    .din(spi_din)
  );

  config_mem #(
    .CONFIG_SIZE(CONFIG_SIZE),
    .STATUS_SIZE(STATUS_SIZE),
    .CONFIG4_SIZE(PROC_STAT_SIZE)
  )i_config_top(
    .clk(clk50m),                       .rst_b(rst_b),

    .config_ra(config_r_vec),           .config_rwa(config_vec), 
    .config_rwa_default(config_default_vec),
    
    .proc_stat_page(nios_usr_stat_page),

    .spi_wr(spi_wr),                    .spi_rd(spi_rd),
    .spi_adr(spi_adr), 
    .spi_dout(spi_dout),                .spi_din(spi_din),

    .rs232_mem_page    (rs232_mem_page),
    .rs232_mem_offset  (rs232_mem_offset),
    .rs232_mem_wr_en   (rs232_mem_wr_en),
    .rs232_mem_wr_data (rs232_mem_wr_data),
    .rs232_mem_wr_msk  (rs232_mem_wr_msk),
    .rs232_mem_rd_en   (rs232_mem_rd_en),
    .rs232_mem_rd_data (rs232_mem_rd_data),
    .rs232_mem_ack     (rs232_mem_ack),

    .proc_rd_word_en                (reg_map_usr_rd_word_en),
    .proc_rd_word_addr              (reg_map_usr_rd_word_addr),            
    .proc_rd_word_data              (reg_map_usr_rd_word_data),
    .proc_wr_word_en                (reg_map_usr_wr_word_en),              
    .proc_wr_byte_indx              (reg_map_usr_wr_byte_indx),
    .proc_wr_word_addr              (reg_map_usr_wr_word_addr),            
    .proc_wr_word_data              (reg_map_usr_wr_word_data)
  );

  assign {rf_sw1, rf_sw2} = 2'b10;

  lgdst_mod_core i_core(
    .rst_b(rst_b),

    .clk50m(clk50m),
    .clk100m(clk100m),

    .rf_data_clk(rf_data_clk),
    .dvbt_tx_enable(),
    .rf_tx_p_data_p_mb(),
    .rf_tx_p_data_n_mb(),
    .rf_tx_p_frame_mb(),

    // ts_data_spi_receiver SPI & RF_VID_SERVER
    .spi_spck(spi1_spck),                   .spi_npcs0(spi1_npcs0),
    .spi_mosi(spi1_mosi),                   .spi_miso(spi1_miso),
    .cbr_data(cbr_data),                    .cbr_data_vld(cbr_data_vld),

    //Helm Register Config and Status Interfaces
    .TEST_MODE(test_mode),
    .RESET_COUNTS(reset_counts),
    .TS_SYNC_LOSS_COUNT(ts_sync_loss_count),
    .SHIFTED_BYTE_COUNT(shifted_byte_count),
    .PATTERN_DATA_ERROR_COUNT(pattern_data_error_count),
    .PATTERN_PKT_LOSS_COUNT(pattern_pkt_loss_count),
    .CONTINUITY_ERROR_COUNT (continuity_error_count), //added by sid
    .TSBITRATE1k(tsbitrate1k), //added by sid

    .rx_frame_p_s(1'b0), 
    .rx_frame_n_s(1'b0),
    .rf_rx_data_p_s(6'b0),
    .rf_rx_data_n_s(6'b0),

    .adi_ctrl_in(adi_ctrl_in),
    .adi_ctrl_out(adi_ctrl_out)
  );

  helm_uart #(
    .REF_CLK_FREQ(50000000),
    .UART_BAUD_RATE(115200)
  ) i_helm_uart (
    .rst_b(rst_b),              .clk(clk50m),

    .rxd(helm_rxd),             .txd(helm_txd),

    .usr_mem_page    (rs232_mem_page),
    .usr_mem_offset  (rs232_mem_offset),
    .usr_mem_wr_en   (rs232_mem_wr_en),
    .usr_mem_wr_data (rs232_mem_wr_data),
    .usr_mem_wr_msk  (rs232_mem_wr_msk),  
    .usr_mem_rd_en   (rs232_mem_rd_en),
    .usr_mem_rd_data (rs232_mem_rd_data),
    .usr_mem_ack     (rs232_mem_ack),
    
    .alive_cntr(alive_cntr)
  );

  //assign dbg_tp [12] = pa_en; //pin W22
  assign dbg_tp [11] = pa_en; //pin Y22
  
  assign config_r[0] = {rf_calc_done,6'd0, fpga_reset_a};  
  assign config_r[1] = ts_sync_loss_count;
  assign config_r[2] = shifted_byte_count;
  assign config_r[3] = pattern_data_error_count; //added by sid  // 0; //{6'b0,se_uf,se_of};
  assign config_r[4] = pattern_pkt_loss_count; //added by sid// audio_pkt_cnt;
  assign config_r[5] = tsbitrate1k[15:8]; //added by sid // 8'b0;
  assign config_r[6] = tsbitrate1k[7:0]; //added by sid // se_wd_lvl[7:0];
  assign config_r[7] = fifo_bit_rate[15:8]; // {3'b0,se_wd_lvl[12:8]};
  assign config_r[8] = fifo_bit_rate[7:0]; // {2'b0,intra_qp};
  assign config_r[9] = continuity_error_count; // {2'b0, slice_qp};
  assign config_r[10] = 0; // badcycle_cnt;
  assign config_r[11] = 0; // {6'b0,error_mvpipe_latch,
                         //  ddr_af_afull_latch};//ADVANCED ERROR FLAGS
  assign config_r[12]= 0; // vbv_max[7:0];
  assign config_r[13]= 0; // {sdcomp_en,rs232_mode_sel_i,vbv_max[13:8]};
  assign config_r[14]= ts_vid_drop_cnt;
  assign config_r[15]= ts_null_insert_cnt;
  assign config_r[16]= {7'b0, tx_clk_locked}; // sdi_standard[63:56];
  assign config_r[17]= 0; // sdi_standard[55:48];
  assign config_r[18]= 0; // sdi_standard[47:40];
  assign config_r[19]= 0; // sdi_standard[39:32];
  assign config_r[20]= 0; // error_rc_cmplx1_latch;
  assign config_r[21]= 0; // error_rc_cmplx2_latch;
  assign config_r[22]= 0; // generic_cnt[15:8];
  assign config_r[23]= 0; // generic_cnt[7:0];

  assign config_r[24]= nios_build_year;  // Nios build year
  assign config_r[25]= nios_build_month; // Nios build month
  assign config_r[26]= nios_build_day;   // Nios build day

  assign config_r[27]= 0; // {clk1485_lock, format_lock_tbc, format_720p, phy_init_done,
                      //error_latch, ddr3_dcm_locked, hdsdi_clk_lock, mgt_pll_lock};

  assign config_r[28]= 0; // mac_tx_count[15:8];
  assign config_r[29]= 0; // mac_tx_count[7:0];
  assign config_r[30]= 0; // sdi_frame_count[15:8];
  assign config_r[31]= 0; // sdi_frame_count[7:0]; //count frame coming from hdsdi
  assign config_r[32]= `BUILD_YEAR;
  assign config_r[33]= `BUILD_MONTH;
  assign config_r[34]= `BUILD_DAY;
  assign config_r[35]= `BUILD_HOUR;
  assign config_r[36]= `BUILD_MIN;
  assign config_r[37]= `VER_MAJOR;
  assign config_r[38]= `VER_MINOR;
  assign config_r[39] = alive_cntr;
  assign config_r[40] = 0; // ts_mac_des[31:24];
  assign config_r[41] = 0; // ts_mac_des[23:16];
  assign config_r[42] = 0; // ts_mac_des[15:8];
  assign config_r[43] = 0; // ts_mac_des[7:0];
  assign config_r[44] = 0; // mac_rx_count[7:0];
  assign config_r[45] = 0; // udp_rx_count[7:0];
  assign config_r[46] = 0; // 0;
  assign config_r[47] = 0; // 0;
  assign config_r[48] = 0; // fpga_user_access_reg[31:24];
  assign config_r[49] = 0; // fpga_user_access_reg[23:16];
  assign config_r[50] = 0; // fpga_user_access_reg[15:8];
  assign config_r[51] = 0; // fpga_user_access_reg[7:0];
  assign config_r[52] = 0; // 0;
  assign config_r[53] = 0; // 0;
  assign config_r[54] = 0;
  assign config_r[55] = 0;

  
  assign config_rw_default[0] = 0; 
  assign config_rw_default[1] = 0; 
  assign {test_mode, read_counts} = config_rw[2][1:0];
  assign config_rw_default[2] = 8'd2; //{test_mode, read_counts} = 2'b10
  assign config_rw_default[3] = 0;
  //assign pa_en = (power_en)? 1'b1:1'b0;
  //assign pa_en = (power_en)? config_rw[0][1]:1'b0; //pin W22
  assign pa_en = (power_en)? ((config_rw[4] == 8'h88)? 1'b1:1'b0) : 1'b0;
  assign config_rw_default[4] = 0; 
  assign config_rw_default[5] = 0;
  assign config_rw_default[6] = 0; 
  assign config_rw_default[7] = 0;
  assign config_rw_default[8] = `BUILD_YEAR; 
  assign config_rw_default[9] = `BUILD_MONTH;
  assign config_rw_default[10] = `BUILD_DAY; 
  assign config_rw_default[11] = 0;
  assign config_rw_default[12] = 0; 
  assign config_rw_default[13] = 0;
  assign config_rw_default[14] = 0; 
  assign config_rw_default[15] = 8'hff;
  assign config_rw_default[16] = 8'd192;
  assign config_rw_default[17] = 8'd168;
  assign config_rw_default[18] = 8'd54;
  assign config_rw_default[19] = 8'd1;
  assign config_rw_default[20] = 8'd24;
  assign config_rw_default[21] = 0;
  assign config_rw_default[22] = 8'h15;
  assign config_rw_default[23] = 8'hb1; //5553
  assign config_rw_default[24] = 8'd192;
  assign config_rw_default[25] = 8'd168;
  assign config_rw_default[26] = 8'd54;
  assign config_rw_default[27] = 8'd200;
  assign config_rw_default[28] = 8'h18; 
  assign config_rw_default[29] = 8'd20;
  assign config_rw_default[30] = 8'd40; 
  assign config_rw_default[31] = 8'd00;
  assign config_rw_default[32] = 8'd00; 
  assign config_rw_default[33] = 8'd00;
  assign config_rw_default[34] = 8'h15;
  assign config_rw_default[35] = 8'hb1; //5553
  assign config_rw_default[36] = 8'd232;
  assign config_rw_default[37] = 8'd168;
  assign config_rw_default[38] = 8'd54;
  assign config_rw_default[39] = 8'd200;
  assign config_rw_default[40] = 8'd0;
  assign config_rw_default[41] = 8'd0;
  assign config_rw_default[42] = 8'd0;
  assign config_rw_default[43] = 8'h01; //hardcoded and is assigned to the tx_iq_gain
  assign config_rw_default[44] = 8'h00;
  assign config_rw_default[45] = 8'h13;
  assign config_rw_default[46] = 8'h02;
  assign config_rw_default[47] = 8'h06;
  assign config_rw_default[48] = 8'h12;
  assign config_rw_default[49] = 8'h34;
  assign config_rw_default[50] = 8'b0;
  assign config_rw_default[51] = 0; //{3'b000,`LP_MODE_FORCE,2'b10};
//  assign config_rw_default[51] = {`QPDYN_GAIN,`LP_MODE_FORCE,2'b00};
  assign config_rw_default[52]=8'h21; //audio_pid
  assign config_rw_default[53]=8'h00;
  assign config_rw_default[54]=8'h20; //video_pid
  assign config_rw_default[55]=8'h00;
  assign config_rw_default[56]=8'h2f; //pcr_pid
  assign config_rw_default[57]=8'h00;
  assign config_rw_default[58]=8'h01; //pmt_pid
  assign config_rw_default[59]=8'h00;
  assign config_rw_default[60]=8'h00;  //isad_thr_a[7:0]
  assign config_rw_default[61]=8'h00;  //isad_thr_a[15:8]

  genvar di;
  generate for(di = 62; di < CONFIG_SIZE; di = di + 1) begin: config_init_0
    assign config_rw_default[di] = 8'h00;
  end
  endgenerate

  assign rf_l_clk = axi_ad9361_l_clk;
  assign axi_ad9361_clk = rf_l_clk;
  assign rf_data_clk = rf_l_clk;
  assign nios_clk = clk50m;
  //assign clk146 = adi_pll_clk_out;
//  rx_clk_buf u0 (
//      .inclk  (axi_ad9361_l_clk),  //  altclkctrl_input.inclk
//      .outclk (rf_l_clk)  // altclkctrl_output.outclk
//  );

  assign spi_ad9361_external_MISO = spi5_miso;
  assign spi5_spck = spi_ad9361_external_SCLK;
  assign spi5_npcs0 = spi_ad9361_external_SS_n;
  assign spi5_mosi = spi_ad9361_external_MOSI;
  
  assign reset_adi = osc_pll_locked & gpio_export[0];
  
  //assign reset_adi = osc_pll_locked; //active_low reset
  assign en_agc    = 1'b0;
  assign enable    = 1'b1; //not used with SPI in control
  assign txn_rx    = 1'b1; //select TX
  assign sync_in   = 1'b0; //not used
  
/*
  //wires for connecting the ports according to the versions
  wire fb_clk_p;

generate
 if (VERSION2 == "TRUE")
 begin
  assign adi_fb_clk_p_v1 = 0;
  assign adi_fb_clk_p_v2 = fb_clk_p;
 end
 else
 begin
  assign adi_fb_clk_p_v1 = fb_clk_p;
  assign adi_fb_clk_p_v2 = 0;
 end
endgenerate
*/

  generate
    if (PROCESSOR_ENABLE == "TRUE")
    begin
        
      wire rf_calc_done = proc_stat_array[3][0];
		wire [7:0] nios_build_year  = proc_stat_array [4];
		wire [7:0] nios_build_month = proc_stat_array [5];
		wire [7:0] nios_build_day   = proc_stat_array [6];
      wire [7:0] rf_tx_usr_ctrl_reg = proc_stat_array[0];
      wire test_tone_sel = rf_conf_array[0][7];
      assign dvbt_tx_enable = rf_calc_done & (~test_tone_sel);

      system_bd nios_subsystem(                                        
        .axi_ad9361_device_clock_clk           (axi_ad9361_clk),
        .axi_ad9361_device_if_rx_clk_in_p      (adi_data_clk_p), //axi_ad9361_rx_clk_in_p),    
        .axi_ad9361_device_if_rx_clk_in_n      (adi_pll_clk_in), //axi_ad9361_rx_clk_in_n),
        .axi_ad9361_device_if_rx_frame_in_p    (adi_rx_frame_p), //axi_ad9361_rx_frame_in_p),  
        .axi_ad9361_device_if_rx_frame_in_n    (1'b0), //axi_ad9361_rx_frame_in_n),
        .axi_ad9361_device_if_rx_data_in_p     (adi_rx_p),       //axi_ad9361_rx_data_in_p),   
        .axi_ad9361_device_if_rx_data_in_n     (6'b0),       //axi_ad9361_rx_data_in_n),
        .axi_ad9361_device_if_tx_clk_out_p     (adi_fb_clk_p),   //axi_ad9361_tx_clk_out_p),   
        .axi_ad9361_device_if_tx_clk_out_n     (adi_pll_clk_out),   //axi_ad9361_tx_clk_out_n),   adi_fb_clk_n
        .axi_ad9361_device_if_tx_frame_out_p   (adi_tx_frame_p), //axi_ad9361_tx_frame_out_p), 
        .axi_ad9361_device_if_tx_frame_out_n   (), //axi_ad9361_tx_frame_out_n),
        .axi_ad9361_device_if_tx_data_out_p    (adi_tx_p),       //axi_ad9361_tx_data_out_p),  
        .axi_ad9361_device_if_tx_data_out_n    (),       //axi_ad9361_tx_data_out_n),
        
        .axi_ad9361_user_if_usr_ctrl_reg       (rf_tx_usr_ctrl_reg),
        .axi_ad9361_user_if_usr_tx_data_sel    (dvbt_tx_enable),
        .axi_ad9361_user_if_usr_tx_data_i      (rf_tx_data_i_dvbt),
        .axi_ad9361_user_if_usr_tx_data_q      (rf_tx_data_q_dvbt),
        .axi_ad9361_user_if_usr_tx_frame       (rf_tx_frame_dvbt),
        
        .axi_ad9361_dma_if_adc_enable_i0       (axi_ad9361_adc_enable_i0),
        .axi_ad9361_dma_if_adc_valid_i0        (axi_ad9361_adc_valid_i0),      
        .axi_ad9361_dma_if_adc_data_i0         (axi_ad9361_adc_data_i0),
        .axi_ad9361_dma_if_adc_enable_q0       (axi_ad9361_adc_enable_q0),     
        .axi_ad9361_dma_if_adc_valid_q0        (axi_ad9361_adc_valid_q0),
        .axi_ad9361_dma_if_adc_data_q0         (axi_ad9361_adc_data_q0),       
        .axi_ad9361_dma_if_adc_enable_i1       (axi_ad9361_adc_enable_i1),
        .axi_ad9361_dma_if_adc_valid_i1        (axi_ad9361_adc_valid_i1),      
        .axi_ad9361_dma_if_adc_data_i1         (axi_ad9361_adc_data_i1),
        .axi_ad9361_dma_if_adc_enable_q1       (axi_ad9361_adc_enable_q1),     
        .axi_ad9361_dma_if_adc_valid_q1        (axi_ad9361_adc_valid_q1),
        .axi_ad9361_dma_if_adc_data_q1         (axi_ad9361_adc_data_q1),       
        .axi_ad9361_dma_if_adc_dovf            (axi_ad9361_adc_dovf),
        .axi_ad9361_dma_if_adc_dunf            (axi_ad9361_adc_dunf),          
        .axi_ad9361_dma_if_dac_enable_i0       (axi_ad9361_dac_enable_i0),
        .axi_ad9361_dma_if_dac_valid_i0        (axi_ad9361_dac_valid_i0),      
        .axi_ad9361_dma_if_dac_data_i0         (axi_ad9361_dac_data_i0),
        .axi_ad9361_dma_if_dac_enable_q0       (axi_ad9361_dac_enable_q0),     
        .axi_ad9361_dma_if_dac_valid_q0        (axi_ad9361_dac_valid_q0),
        .axi_ad9361_dma_if_dac_data_q0         (axi_ad9361_dac_data_q0),       
        .axi_ad9361_dma_if_dac_enable_i1       (axi_ad9361_dac_enable_i1),
        .axi_ad9361_dma_if_dac_valid_i1        (axi_ad9361_dac_valid_i1),      
        .axi_ad9361_dma_if_dac_data_i1         (axi_ad9361_dac_data_i1),
        .axi_ad9361_dma_if_dac_enable_q1       (axi_ad9361_dac_enable_q1),     
        .axi_ad9361_dma_if_dac_valid_q1        (axi_ad9361_dac_valid_q1),
        .axi_ad9361_dma_if_dac_data_q1         (axi_ad9361_dac_data_q1),       
        .axi_ad9361_dma_if_dac_dovf            (axi_ad9361_dac_dovf),
        .axi_ad9361_dma_if_dac_dunf            (axi_ad9361_dac_dunf),          
        .axi_ad9361_master_if_l_clk            (axi_ad9361_l_clk),
        .axi_ad9361_master_if_dac_sync_in      (axi_ad9361_dac_sync_in),    
        .axi_ad9361_master_if_dac_sync_out     (axi_ad9361_dac_sync_out),
        
        .clk_clk                               (nios_clk),
        .gpio_external_connection_export       (gpio_export),     

        .reg_map_usr_rd_word_en                (reg_map_usr_rd_word_en),              
        .reg_map_usr_rd_word_addr              (reg_map_usr_rd_word_addr),
        .reg_map_usr_rd_word_data              (reg_map_usr_rd_word_data),
        .reg_map_usr_wr_word_en                (reg_map_usr_wr_word_en),
        .reg_map_usr_wr_byte_indx              (reg_map_usr_wr_byte_indx),
        .reg_map_usr_wr_word_addr              (reg_map_usr_wr_word_addr),
        .reg_map_usr_wr_word_data              (reg_map_usr_wr_word_data),            
        .reg_map_test_out                      (reg_map_test_out),
        .reset_reset_n                         (reset_reset_n),

        .spi_ad9361_external_MISO              (spi_ad9361_external_MISO),            
        .spi_ad9361_external_MOSI              (spi_ad9361_external_MOSI),
        .spi_ad9361_external_SCLK              (spi_ad9361_external_SCLK),            
        .spi_ad9361_external_SS_n              (spi_ad9361_external_SS_n),
        
        .sys_gpio_external_connection_in_port  (sys_gpio_in_port),
        .sys_gpio_external_connection_out_port (sys_gpio_out_port),
        
        .uart_0_external_connection_rxd        (proc_uart_rxd),
        .uart_0_external_connection_txd        (proc_uart_txd)
      );

	 end
  endgenerate

wire tx_pll_rst = ~osc_pll_locked;

   generate 
      if (PROCESSOR_ENABLE == "TRUE") begin
tx_clk_gen i_tx_clk_gen(
        .refclk   (axi_ad9361_l_clk), //  refclk.clk
        .rst      (tx_pll_rst), //   reset.reset
        .outclk_0 (clk146), // outclk0.clk
        //.outclk_1 (adi_data_clk2), // outclk1.clk
        //.outclk_2 (clk146), // outclk1.clk
        .locked   (tx_clk_locked)  //  locked.export
    );
      end
      else begin
         //tx_clk_gen_debug i_tx_clk_gen(
         //      .refclk   (clk50m), //  refclk.clk
         //      .rst      (tx_pll_rst), //   reset.reset
         //      .outclk_0 (clk146), // outclk0.clk
         //      //.outclk_1 (adi_data_clk2), // outclk1.clk
         //      //.outclk_2 (clk146), // outclk1.clk   
         //      .locked   (tx_clk_locked)  //  locked.export
         //);
         assign clk146 = clk100m;
         assign tx_clk_locked = osc_pll_locked;
      end
   endgenerate 

assign rf_irst = ~tx_clk_locked;

endmodule
