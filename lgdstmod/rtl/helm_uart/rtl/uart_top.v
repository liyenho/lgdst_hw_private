/*
 *
 *
 */

`timescale 1ns / 10ps

module uart_top #(
  parameter         REF_CLK_FREQ = 50000000,    // 50MHz
  parameter         UART_BAUD_RATE = 115200,    // i.e., bit width = 8.68us
  parameter         CLK_CNT_BIT = 16
)(
  input             rst_b,
  input             clk,

  input             rxd,
  output reg        txd = 1'b1, 

  input             tx_wr,
  output reg        tx_busy =1'b0,
  input       [7:0] tx_data, 

  output reg        rx_vld, 
  output reg  [7:0] rx_data
);
  reg     [7:0] tx_sh_reg;
  reg     [3:0] tx_sh_cnt;
  reg     [2:0] tx_fsm_cs, tx_fsm_ns;

  reg           txd_en =1'b0;
  wire          txd_tick;
  wire          txd_htick;

  reg     [2:0] rxd_sync;
  reg     [7:0] rx_sh_reg;
  reg     [3:0] rx_sh_cnt;
  reg     [2:0] rx_fsm_cs, rx_fsm_ns;

  reg           rxd_idle = 1'b1;
  wire          rxd_htick;

  always @(posedge clk or negedge rst_b)
  begin
    if (~rst_b)
    begin
      tx_busy <= 'd0;
      txd_en <= 1'b0;
      tx_sh_cnt <= 'd0;
      txd <= 1'b1;
    end
    else
    begin
      case (tx_fsm_ns)
      'd1:
      begin
        tx_busy <= 'd1;
        txd_en <= 1'b1;
        tx_sh_cnt <= 'd0;
        txd <= 1'b1;
        if (tx_wr)
          tx_sh_reg <= tx_data;
      end
      'd2: // TX_START
      begin
        tx_busy <= 'd1;
        txd_en <= 1'b1;
        tx_sh_cnt <= 'd8;
        txd <= 1'b0;
      end
      'd3: // TX_DATA
      begin
        tx_busy <= 'd1;
        txd_en <= 1'b1;
        if (txd_tick)
        begin
          {tx_sh_reg, txd} <= (tx_sh_cnt[3])? {tx_sh_reg, txd}:
                                              {1'b1, tx_sh_reg};
          tx_sh_cnt <= tx_sh_cnt + {4{|tx_sh_cnt}};
        end
        else
          txd <= tx_sh_reg[0];
      end
      'd5:
      begin
        tx_busy <= 'd1;
        txd_en <= 1'b1;
        tx_sh_cnt <= 'd0;
        txd <= 1'b1;
      end
      'd6:
      begin
        tx_busy <= 'd1;
        txd_en <= 1'b1;
        tx_sh_cnt <= 'd0;
        txd <= 1'b1;
      end

      default: //'d0
      begin
        tx_busy <= 'd0;
        txd_en <= 1'b0;
        tx_sh_cnt <= 'd0;
        txd <= 1'b1;
      end
      endcase
    end
  end

  always @(posedge clk or negedge rst_b)
  begin
    if (~rst_b)
    begin
      rx_sh_cnt <= 'd0;
      rxd_idle <= 1'b0;
      rx_vld <= 1'b0;
    end
    else
    begin
      case (rx_fsm_cs)
      'd2:
      begin
        rx_sh_cnt <= 'd8;
        rxd_idle <= 1'b0;
        rx_vld <= 1'b0;
      end
      'd3: //RX_DATA
      begin
        if (rxd_htick) 
        begin
          rx_sh_reg <= {rxd_sync[1], rx_sh_reg[7:1]};
          rx_sh_cnt <= rx_sh_cnt + {4{|rx_sh_cnt}};
        end
        rxd_idle <= 1'b0;
        rx_vld <= 1'b0;
      end
      'd5:
      begin
        rx_sh_cnt <= 'd0;
        rxd_idle <= 1'b1;
        rx_vld <= 1'b0;
        rx_data = rx_sh_reg;
      end
      'd6:
      begin
        rx_sh_cnt <= 'd0;
        rxd_idle <= 1'b1;
        rx_vld <= 1'b1;
      end
    
      default: //'d0
      begin
        rx_sh_cnt <= 'd8;
        rxd_idle <= 1'b1;
        rx_vld <= 1'b0;
      end
      endcase
    end
  end

  always @(*)
  begin
    case (tx_fsm_cs)
    'd1: // TX_PREPAER
      tx_fsm_ns = (txd_tick)? 'd2:'d1;
    'd2: // TX_START
      tx_fsm_ns = (txd_tick)? 'd3:'d2;
    'd3: // TX_DATA
      tx_fsm_ns = (txd_tick & ~|tx_sh_cnt)? 'd5:'d3;
     //'d4: // TX_PARITY
    'd5: // TX_SP0
      tx_fsm_ns = (txd_tick)? 'd0:'d5;
    'd6: // TX_SP1
      tx_fsm_ns = (txd_tick)? 'd0:'d6;

    default:  // 'd0
      tx_fsm_ns = (tx_wr)? 'd1:1'b0;
    endcase

    case (rx_fsm_cs)
    'd2: // RX_START
      rx_fsm_ns = (rxd_htick)? 'd3:'d2;
    'd3: // RX_DATA
      rx_fsm_ns = (~|rx_sh_cnt)? 'd5:'d3;
     //'d4: // RX_PARITY
    'd5: // RX_SP0
      rx_fsm_ns = 'd6; //(rxd_htick)? 'd0:'d5;
    'd6: // RX_SP1
      rx_fsm_ns = 'd0; //(rxd_htick)? 'd0:'d6;

    default:  // 'd0
      rx_fsm_ns = (rxd_htick)? 'd3:1'b0;
    endcase
  end

  always @(posedge clk or negedge rst_b)
  begin
    if (~rst_b)
    begin
      rxd_sync <= 'd7;
      tx_fsm_cs <= 'd0;
      rx_fsm_cs <= 'd0;
    end
    else
    begin
      rxd_sync <= {rxd_sync[1:0], rxd};
      tx_fsm_cs <= tx_fsm_ns;
      rx_fsm_cs <= rx_fsm_ns;
    end
  end

  baud_gen  #(
    .REF_CLK_FREQ(REF_CLK_FREQ),    .CLK_CNT_BIT(CLK_CNT_BIT),
    .UART_BAUD_RATE(UART_BAUD_RATE)
  ) i_baud_gen (
    .rst_b(rst_b),              .clk(clk),
    
    .rxd_idle(rxd_idle),        .rxd_sync(rxd_sync), 
    .rxd_htick(rxd_htick),

    .txd_en(txd_en),        
    .txd_tick(txd_tick),        .txd_htick(txd_htick)
  );

endmodule
