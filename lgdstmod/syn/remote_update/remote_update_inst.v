	remote_update u0 (
		.busy            (<connected-to-busy>),            //            busy.busy
		.data_out        (<connected-to-data_out>),        //        data_out.data_out
		.param           (<connected-to-param>),           //           param.param
		.read_param      (<connected-to-read_param>),      //      read_param.read_param
		.reconfig        (<connected-to-reconfig>),        //        reconfig.reconfig
		.reset_timer     (<connected-to-reset_timer>),     //     reset_timer.reset_timer
		.clock           (<connected-to-clock>),           //           clock.clk
		.reset           (<connected-to-reset>),           //           reset.reset
		.write_param     (<connected-to-write_param>),     //     write_param.write_param
		.data_in         (<connected-to-data_in>),         //         data_in.data_in
		.asmi_busy       (<connected-to-asmi_busy>),       //       asmi_busy.asmi_busy
		.asmi_data_valid (<connected-to-asmi_data_valid>), // asmi_data_valid.asmi_data_valid
		.asmi_dataout    (<connected-to-asmi_dataout>),    //    asmi_dataout.asmi_dataout
		.asmi_addr       (<connected-to-asmi_addr>),       //       asmi_addr.asmi_addr
		.asmi_read       (<connected-to-asmi_read>),       //       asmi_read.asmi_read
		.asmi_rden       (<connected-to-asmi_rden>),       //       asmi_rden.asmi_rden
		.pof_error       (<connected-to-pof_error>)        //       pof_error.pof_error
	);

