
`timescale 1 ps / 1 ps

	module reg_map_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 16
		
		//parameter integer C_CONFIG_PAGE_NO      = 8'h04,
		//parameter integer C_STATUS_PAGE_NO      = 8'h04,
		//parameter integer C_REG_CNT             = 8,
		//parameter integer C_STAT_VEC_WIDTH      = 32,
		//parameter integer C_CONF_VEC_WIDTH      = 128, //in bits
		//parameter integer CONF_RDONLY_OFFSET    = 32   //in 32-bit words
	)
	(
		// Users to add ports here
		//output                        usr_mem_clk,
        //input                         usr_mem_wr_en,
        //input                         usr_mem_rd_en,
        //input  [7:0]                  usr_mem_page,
        //input  [7:0]                  usr_mem_offset,
        //input  [7:0]                  usr_mem_wr_data,
        //output [7:0]                  usr_mem_rd_data,
        //output                        usr_mem_ack,
        //output [C_STAT_VEC_WIDTH-1:0] usr_stat_reg,
        //input  [C_CONF_VEC_WIDTH-1:0] usr_conf_reg,
        
        output                            usr_rd_word_en,
        output [C_S00_AXI_ADDR_WIDTH-3:0] usr_rd_word_addr,
        input  [31:0]                     usr_rd_word_data,
        output                            usr_wr_word_en,
        output [3:0]                      usr_wr_byte_indx,
        output [C_S00_AXI_ADDR_WIDTH-3:0] usr_wr_word_addr,
        output [31:0]                     usr_wr_word_data,
        
        output [255:0]                    test_out,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI
    //assign usr_mem_clk = s00_axi_aclk;
    
	reg_map_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
		//.C_CONFIG_PAGE_NO(C_CONFIG_PAGE_NO),
		//.C_STATUS_PAGE_NO(C_STATUS_PAGE_NO),
		//.C_REG_CNT(C_REG_CNT),
		//.C_STAT_VEC_WIDTH(C_STAT_VEC_WIDTH),
		//.C_CONF_VEC_WIDTH(C_CONF_VEC_WIDTH),
		//.CONF_RDONLY_OFFSET(CONF_RDONLY_OFFSET)
	) reg_map_v1_0_S00_AXI_inst (
	    //.usr_mem_wr_en   (usr_mem_wr_en  ),
        //.usr_mem_rd_en   (usr_mem_rd_en  ),
        //.usr_mem_page    (usr_mem_page   ),
        //.usr_mem_offset  (usr_mem_offset ),
        //.usr_mem_wr_data (usr_mem_wr_data),
        //.usr_mem_rd_data (usr_mem_rd_data),
        //.usr_mem_ack     (usr_mem_ack    ),
        //.usr_stat_reg    (usr_stat_reg   ),
        //.usr_conf_reg    (usr_conf_reg   ),
        
        .usr_rd_word_en    (usr_rd_word_en  ),
        .usr_rd_word_addr  (usr_rd_word_addr),
        .usr_rd_word_data  (usr_rd_word_data),
        .usr_wr_word_en    (usr_wr_word_en  ),
        .usr_wr_byte_indx  (usr_wr_byte_indx),
        .usr_wr_word_addr  (usr_wr_word_addr),
        .usr_wr_word_data  (usr_wr_word_data),
        
        .test_out        (test_out       ),
        
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
