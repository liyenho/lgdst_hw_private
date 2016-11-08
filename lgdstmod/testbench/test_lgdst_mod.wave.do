onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /test_lgdst_mod/i_dut/rst_pll
add wave -noupdate -format Logic /test_lgdst_mod/i_dut/rst_b
add wave -noupdate -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rx_vld
add wave -noupdate -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rx_data
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rst_b
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/clk
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rxd
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/txd
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/tx_wr
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/tx_busy
add wave -noupdate -group cmd_uart -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/tx_data
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rx_vld
add wave -noupdate -group cmd_uart -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rx_data
add wave -noupdate -group cmd_uart -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/tx_sh_reg
add wave -noupdate -group cmd_uart -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/tx_sh_cnt
add wave -noupdate -group cmd_uart -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/tx_fsm_cs
add wave -noupdate -group cmd_uart -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/tx_fsm_ns
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/txd_en
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/txd_tick
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/txd_htick
add wave -noupdate -group cmd_uart -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rxd_sync
add wave -noupdate -group cmd_uart -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rx_sh_reg
add wave -noupdate -group cmd_uart -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rx_sh_cnt
add wave -noupdate -group cmd_uart -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rx_fsm_cs
add wave -noupdate -group cmd_uart -format Literal -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rx_fsm_ns
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rxd_idle
add wave -noupdate -group cmd_uart -format Logic -radix hexadecimal /test_lgdst_mod/i_cmd_uart/rxd_htick
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/rst_b
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/clk
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rxd
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/txd
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/txd_en
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/txd_tick
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/txd_htick
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rst_b
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/clk
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/txd
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/tx_wr
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/tx_busy
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/tx_data
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/tx_sh_reg
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/tx_sh_cnt
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/tx_fsm_cs
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/tx_fsm_ns
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/txd_en
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/txd_tick
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/txd_htick
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rxd_idle
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rxd
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rx_sh_reg
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rx_sh_cnt
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rx_fsm_cs
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rx_fsm_ns
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rxd_idle
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rxd_htick
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rxd_sync
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rx_vld
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/rx_data
add wave -noupdate -group helm -divider {New Divider}
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/rxd_idle
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/rxd_htick
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/txd_en
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/txd_tick
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/txd_htick
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/tx_clk_cntr
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/rx_clk_cntr
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/rxd_start_det
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/rxd_start_glitch
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/rxd_en
add wave -noupdate -group helm -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/rxd_sync
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/rxd_rise
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/rxd_fall
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/rxd_htick_hit
add wave -noupdate -group helm -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_uart/i_baud_gen/rxd_tick_hit
add wave -noupdate -group helm_tx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/clk
add wave -noupdate -group helm_tx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/rst_b
add wave -noupdate -group helm_tx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_wr
add wave -noupdate -group helm_tx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_busy
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_data
add wave -noupdate -group helm_tx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_blkrd
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/data_len
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/msg_type
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/msg_seq_no
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/msg_page
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/msg_offset
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_msg_type
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_msg_seq_no
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_msg_base_addr
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_msg_len
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_data_len
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_chksum
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_fsm_cs
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_fsm_ns
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/tx_send_cntr
add wave -noupdate -group helm_tx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/usr_mem_cs
add wave -noupdate -group helm_tx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/usr_mem_rd_en
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/usr_mem_page
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/usr_mem_offset
add wave -noupdate -group helm_tx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/usr_mem_data
add wave -noupdate -group helm_tx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_snd/usr_mem_ack
add wave -noupdate -expand -group helm_rx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/clk
add wave -noupdate -expand -group helm_rx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/rst_b
add wave -noupdate -expand -group helm_rx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/rx_vld
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/rx_data
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_type
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_seq_no
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_page
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_offset
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_data_length
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_chksum
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_data_adr
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_data
add wave -noupdate -expand -group helm_rx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_data_wr
add wave -noupdate -expand -group helm_rx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_exec
add wave -noupdate -expand -group helm_rx -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_chksum_err
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/msg_data_cntr
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/rx_chksum
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/rx_extract_cs
add wave -noupdate -expand -group helm_rx -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_rcv/rx_extract_ns
add wave -noupdate -expand -group helm_ctrl -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/clk
add wave -noupdate -expand -group helm_ctrl -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/rst_b
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_type
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_page
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_offset
add wave -noupdate -expand -group helm_ctrl -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_exec
add wave -noupdate -expand -group helm_ctrl -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_chksum_err
add wave -noupdate -expand -group helm_ctrl -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_data_wr
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_data_adr
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_data
add wave -noupdate -expand -group helm_ctrl -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/tx_blkrd
add wave -noupdate -expand -group helm_ctrl -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/tx_blkwr
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/data_len
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/usr_mem_page
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/usr_mem_offset
add wave -noupdate -expand -group helm_ctrl -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/usr_mem_wr_en
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/usr_mem_wr_data
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/usr_mem_wr_msk
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/wr_cntr
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/ctrl_fsm_cs
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/ctrl_fsm_ns
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_byte_2
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_byte_3
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_rd_adr
add wave -noupdate -expand -group helm_ctrl -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_helm_uart/i_msg_ctrl/msg_rd_data
add wave -noupdate -format Logic /test_lgdst_mod/i_dut/helm_txd
add wave -noupdate -format Logic /test_lgdst_mod/i_dut/helm_rxd
add wave -noupdate -format Logic /test_lgdst_mod/i_dut/rst_b
add wave -noupdate -format Logic /test_lgdst_mod/i_dut/clk146
add wave -noupdate -format Logic /test_lgdst_mod/i_dut/rf_l_clk
add wave -noupdate -format Logic /test_lgdst_mod/i_dut/adi_data_clk_p
add wave -noupdate -format Logic /test_lgdst_mod/i_dut/adi_fb_clk_p
add wave -noupdate -group osc_pll -format Logic /test_lgdst_mod/i_dut/clk_24M
add wave -noupdate -group osc_pll -format Logic /test_lgdst_mod/i_dut/i_osc_pll/refclk
add wave -noupdate -group osc_pll -format Logic /test_lgdst_mod/i_dut/i_osc_pll/rst
add wave -noupdate -group osc_pll -format Logic /test_lgdst_mod/i_dut/i_osc_pll/outclk_0
add wave -noupdate -group osc_pll -format Logic /test_lgdst_mod/i_dut/clk100m
add wave -noupdate -group osc_pll -format Logic /test_lgdst_mod/i_dut/i_osc_pll/outclk_1
add wave -noupdate -group osc_pll -format Logic /test_lgdst_mod/i_dut/clk50m
add wave -noupdate -group osc_pll -format Logic /test_lgdst_mod/i_dut/i_osc_pll/outclk_2
add wave -noupdate -group osc_pll -format Logic /test_lgdst_mod/i_dut/clk12m
add wave -noupdate -group {ADI Tx} -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/rf_tx_p_data_p
add wave -noupdate -group {ADI Tx} -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/rf_tx_p_data_n
add wave -noupdate -group {ADI Tx} -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/rf_tx_p_frame
add wave -noupdate -group {ADI Tx} -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/dvbt_tx_enable
add wave -noupdate -group {ADI Tx} -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/rf_tx_p_data_p_dvbt
add wave -noupdate -group {ADI Tx} -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/rf_tx_p_data_n_dvbt
add wave -noupdate -group {ADI Tx} -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/rf_tx_p_frame_dvbt
add wave -noupdate -group {ADI Tx} -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/rf_tx_p_data_p_mb
add wave -noupdate -group {ADI Tx} -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/rf_tx_p_data_n_mb
add wave -noupdate -group {ADI Tx} -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/rf_tx_p_frame_mb
add wave -noupdate -group {ADI Tx} -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/rf_data_clk
add wave -noupdate -group {ADI Tx} -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/adi_tx_frame_p
add wave -noupdate -group {ADI Tx} -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/adi_tx_p
add wave -noupdate -group {ADI Rx} -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/adi_rx_frame_p
add wave -noupdate -group {ADI Rx} -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/adi_rx_p
add wave -noupdate -group {ADI Rx} -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/rf_rx_data_p_s
add wave -noupdate -group {ADI Rx} -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/rf_rx_data_n_s
add wave -noupdate -group {ADI Rx} -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/rx_frame_p_s
add wave -noupdate -group {ADI Rx} -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/rx_frame_n_s
add wave -noupdate -group {ADI Rx} -format Logic -radix hexadecimal {/test_lgdst_mod/i_dut/i_core/dvbt_gen_cntr[0]}
add wave -noupdate -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_core/dvbt_gen_cntr
add wave -noupdate -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_core/dvbt_gen_i
add wave -noupdate -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_core/dvbt_gen_q
add wave -noupdate -group spi_mstr -format Logic -radix hexadecimal /test_lgdst_mod/i_atmel_spi/spi_clk
add wave -noupdate -group spi_mstr -format Logic -radix hexadecimal /test_lgdst_mod/i_atmel_spi/spi_en_n
add wave -noupdate -group spi_mstr -format Logic -radix hexadecimal /test_lgdst_mod/i_atmel_spi/spi_mosi
add wave -noupdate -group spi_mstr -format Logic -radix hexadecimal /test_lgdst_mod/i_atmel_spi/spi_miso
add wave -noupdate -group spi_mstr -format Logic -radix hexadecimal /test_lgdst_mod/i_atmel_spi/busy_flag
add wave -noupdate -group spi_mstr -format Literal -radix ascii /test_lgdst_mod/i_atmel_spi/msg
add wave -noupdate -group spi_mstr -format Literal -radix hexadecimal /test_lgdst_mod/i_atmel_spi/spi_wr_sh_reg
add wave -noupdate -group spi_mstr -format Literal -radix hexadecimal /test_lgdst_mod/i_atmel_spi/spi_rd_sh_reg
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/rst_b
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/clk
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/spi_clk
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/spi_en_n
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/spi_mosi
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/spi_miso
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/wr_en
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/rd_en
add wave -noupdate -group spi_slv -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/adr
add wave -noupdate -group spi_slv -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/dout
add wave -noupdate -group spi_slv -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/din
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/spi_clk_rise
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/spi_clk_fall
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/spi_en_n_rise
add wave -noupdate -group spi_slv -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/spi_en_n_fall
add wave -noupdate -group spi_slv -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/fsm_cs
add wave -noupdate -group spi_slv -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/fsm_ns
add wave -noupdate -group spi_slv -format Literal -radix unsigned /test_lgdst_mod/i_dut/i_spi_slv/shin_cntr
add wave -noupdate -group spi_slv -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/shin_reg
add wave -noupdate -group spi_slv -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/cmd_hit
add wave -noupdate -group spi_slv -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/spi_cmd
add wave -noupdate -group spi_slv -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/ad_hit
add wave -noupdate -group spi_slv -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_spi_slv/shout_reg
add wave -noupdate -expand -group config_mem -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/clk
add wave -noupdate -expand -group config_mem -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/rst_b
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/config_ra
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/config_rwa
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/config_rwa_default
add wave -noupdate -expand -group config_mem -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/spi_wr
add wave -noupdate -expand -group config_mem -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/spi_rd
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/spi_adr
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/spi_dout
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/spi_din
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/rs232_mem_page
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/rs232_mem_offset
add wave -noupdate -expand -group config_mem -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/rs232_mem_wr_en
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/rs232_mem_wr_data
add wave -noupdate -expand -group config_mem -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/rs232_mem_rd_en
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/rs232_mem_rd_data
add wave -noupdate -expand -group config_mem -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/rs232_mem_ack
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/config_r
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/config_rw_default
add wave -noupdate -expand -group config_mem -format Literal /test_lgdst_mod/i_dut/i_config_top/config_rw
add wave -noupdate -expand -group config_mem -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/write_page4
add wave -noupdate -expand -group config_mem -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/write_page4_2
add wave -noupdate -expand -group config_mem -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/write_page4_3
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/i
add wave -noupdate -expand -group config_mem -format Logic -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/rs232_wr
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/rs232_wr_adr
add wave -noupdate -expand -group config_mem -format Literal -radix hexadecimal /test_lgdst_mod/i_dut/i_config_top/rs232_wr_buf
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {679888592 ps} 0}
configure wave -namecolwidth 430
configure wave -valuecolwidth 82
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {859371272 ps} {863568824 ps}
