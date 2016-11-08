
`timescale 1 ps / 1 ps

	module reg_map_v1_0_S00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 16
		
		//parameter integer C_CONFIG_PAGE_NO      = 8'h04,
		//parameter integer C_STATUS_PAGE_NO      = 8'h04,
		//parameter integer C_REG_CNT             = 8,   //in 32-bit words, must be <= CONF_RDONLY_OFFSET
		//parameter integer C_STAT_VEC_WIDTH      = 32,  //in bits
		//parameter integer C_CONF_VEC_WIDTH      = 128, //in bits
		//parameter integer CONF_RDONLY_OFFSET    = 32   //in 32-bit words
	)
	(
		// Users to add ports here
		//input            usr_mem_wr_en,
        //input            usr_mem_rd_en,
        //input      [7:0] usr_mem_page,
        //input      [7:0] usr_mem_offset,
        //input      [7:0] usr_mem_wr_data,
        //output reg [7:0] usr_mem_rd_data,
        //output           usr_mem_ack,
        //output reg [C_STAT_VEC_WIDTH-1:0] usr_stat_reg,
        //input      [C_CONF_VEC_WIDTH-1:0] usr_conf_reg,
        
        output                             usr_rd_word_en,
        output [C_S_AXI_ADDR_WIDTH-3:0]    usr_rd_word_addr,
        input  [31:0]                      usr_rd_word_data,
        output                             usr_wr_word_en,
        output [3:0]                       usr_wr_byte_indx,
        output [C_S_AXI_ADDR_WIDTH-3:0]    usr_wr_word_addr,
        output [31:0]                      usr_wr_word_data,
        output [255:0]                     test_out,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	wire [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 13;
	//localparam integer CONF_RDONLY_OFFSET = 32; //in 32-bit words
	//localparam integer C_REG_CNT = 64;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 64
	//reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg[C_REG_CNT-1:0];  //read/write by processor
	
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg4;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg5;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg6;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg7;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg8;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg9;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg10;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg11;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg12;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg13;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg14;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg15;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg16;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg17;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg18;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg19;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg20;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg21;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg22;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg23;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg24;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg25;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg26;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg27;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg28;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg29;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg30;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg31;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg32;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg33;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg34;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg35;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg36;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg37;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg38;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg39;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg40;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg41;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg42;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg43;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg44;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg45;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg46;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg47;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg48;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg49;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg50;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg51;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg52;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg53;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg54;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg55;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg56;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg57;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg58;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg59;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg60;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg61;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg62;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg63;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index, i;
	
	//reg usr_mem_rd_ack;
	//reg usr_mem_wr_ack;
	
	assign usr_rd_word_en = slv_reg_rden;
	assign usr_wr_word_en = slv_reg_wren;
	assign usr_wr_byte_indx = S_AXI_WSTRB;
	assign usr_rd_word_addr = axi_araddr[C_S_AXI_ADDR_WIDTH-1:2];
	assign usr_wr_word_addr = axi_awaddr[C_S_AXI_ADDR_WIDTH-1:2];
	assign axi_rdata = usr_rd_word_data;
	assign usr_wr_word_data = S_AXI_WDATA;
	
	//assign usr_mem_ack = usr_mem_rd_ack | usr_mem_wr_ack;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	//always @(*)
	//begin
	//  for(i = 0; i < C_STAT_VEC_WIDTH / C_S_AXI_DATA_WIDTH; i = i + 1)
	//    usr_stat_reg[i*C_S_AXI_DATA_WIDTH +: C_S_AXI_DATA_WIDTH] = slv_reg[i];
	//end
	    
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	// always @( posedge S_AXI_ACLK )
	// begin
	//   if ( S_AXI_ARESETN == 1'b0 )
	//     begin
	//       /*slv_reg0 <= 0;
	//       slv_reg1 <= 0;
	//       slv_reg2 <= 0;
	//       slv_reg3 <= 0;
	//       slv_reg4 <= 0;
	//       slv_reg5 <= 0;
	//       slv_reg6 <= 0;
	//       slv_reg7 <= 0;
	//       slv_reg8 <= 0;
	//       slv_reg9 <= 0;
	//       slv_reg10 <= 0;
	//       slv_reg11 <= 0;
	//       slv_reg12 <= 0;
	//       slv_reg13 <= 0;
	//       slv_reg14 <= 0;
	//       slv_reg15 <= 0;
	//       slv_reg16 <= 0;
	//       slv_reg17 <= 0;
	//       slv_reg18 <= 0;
	//       slv_reg19 <= 0;
	//       slv_reg20 <= 0;
	//       slv_reg21 <= 0;
	//       slv_reg22 <= 0;
	//       slv_reg23 <= 0;
	//       slv_reg24 <= 0;
	//       slv_reg25 <= 0;
	//       slv_reg26 <= 0;
	//       slv_reg27 <= 0;
	//       slv_reg28 <= 0;
	//       slv_reg29 <= 0;
	//       slv_reg30 <= 0;
	//       slv_reg31 <= 0;
	//       slv_reg32 <= 0;
	//       slv_reg33 <= 0;
	//       slv_reg34 <= 0;
	//       slv_reg35 <= 0;
	//       slv_reg36 <= 0;
	//       slv_reg37 <= 0;
	//       slv_reg38 <= 0;
	//       slv_reg39 <= 0;
	//       slv_reg40 <= 0;
	//       slv_reg41 <= 0;
	//       slv_reg42 <= 0;
	//       slv_reg43 <= 0;
	//       slv_reg44 <= 0;
	//       slv_reg45 <= 0;
	//       slv_reg46 <= 0;
	//       slv_reg47 <= 0;
	//       slv_reg48 <= 0;
	//       slv_reg49 <= 0;
	//       slv_reg50 <= 0;
	//       slv_reg51 <= 0;
	//       slv_reg52 <= 0;
	//       slv_reg53 <= 0;
	//       slv_reg54 <= 0;
	//       slv_reg55 <= 0;
	//       slv_reg56 <= 0;
	//       slv_reg57 <= 0;
	//       slv_reg58 <= 0;
	//       slv_reg59 <= 0;
	//       slv_reg60 <= 0;
	//       slv_reg61 <= 0;
	//       slv_reg62 <= 0;
	//       slv_reg63 <= 0;*/
	//       
	//       for(i = 0; i < C_REG_CNT; i = i + 1)
	//           slv_reg[i] <= 0;
	//     end 
	//   else begin
	//     usr_mem_wr_ack <= 1'b0;
	//     
	//     if (slv_reg_wren)
	//       begin
	//         for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	//           if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	//             // Respective byte enables are asserted as per write strobes 
	//             // Slave register 0
	//             slv_reg[axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]][(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	//           end
	//       end
	//     else begin
	//       if ((usr_mem_page == C_CONFIG_PAGE_NO) && (usr_mem_wr_en == 1'b1)) begin
	//           usr_mem_wr_ack <= 1'b1;
	//           
	//           for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	//             if ( usr_mem_offset[1:0] == (C_S_AXI_DATA_WIDTH/8)-1 - byte_index ) begin
	//               // Respective byte enables are asserted as per write strobes 
	//               // Slave register 0
	//               slv_reg[usr_mem_offset[7:2]][(byte_index*8) +: 8] <= usr_mem_wr_data;
	//             end
	//         end
	//       end
	//   end
	// end

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	
	/*always @(*)
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      reg_data_out <= 0;
	    end 
	  else
	    begin    
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        6'h00   : reg_data_out <= slv_reg0;
	        6'h01   : reg_data_out <= slv_reg1;
	        6'h02   : reg_data_out <= slv_reg2;
	        6'h03   : reg_data_out <= slv_reg3;
	        6'h04   : reg_data_out <= slv_reg4;
	        6'h05   : reg_data_out <= slv_reg5;
	        6'h06   : reg_data_out <= slv_reg6;
	        6'h07   : reg_data_out <= slv_reg7;
	        6'h08   : reg_data_out <= slv_reg8;
	        6'h09   : reg_data_out <= slv_reg9;
	        6'h0A   : reg_data_out <= slv_reg10;
	        6'h0B   : reg_data_out <= slv_reg11;
	        6'h0C   : reg_data_out <= slv_reg12;
	        6'h0D   : reg_data_out <= slv_reg13;
	        6'h0E   : reg_data_out <= slv_reg14;
	        6'h0F   : reg_data_out <= slv_reg15;
	        6'h10   : reg_data_out <= slv_reg16;
	        6'h11   : reg_data_out <= slv_reg17;
	        6'h12   : reg_data_out <= slv_reg18;
	        6'h13   : reg_data_out <= slv_reg19;
	        6'h14   : reg_data_out <= slv_reg20;
	        6'h15   : reg_data_out <= slv_reg21;
	        6'h16   : reg_data_out <= slv_reg22;
	        6'h17   : reg_data_out <= slv_reg23;
	        6'h18   : reg_data_out <= slv_reg24;
	        6'h19   : reg_data_out <= slv_reg25;
	        6'h1A   : reg_data_out <= slv_reg26;
	        6'h1B   : reg_data_out <= slv_reg27;
	        6'h1C   : reg_data_out <= slv_reg28;
	        6'h1D   : reg_data_out <= slv_reg29;
	        6'h1E   : reg_data_out <= slv_reg30;
	        6'h1F   : reg_data_out <= slv_reg31;
	        6'h20   : reg_data_out <= slv_reg32;
	        6'h21   : reg_data_out <= slv_reg33;
	        6'h22   : reg_data_out <= slv_reg34;
	        6'h23   : reg_data_out <= slv_reg35;
	        6'h24   : reg_data_out <= slv_reg36;
	        6'h25   : reg_data_out <= slv_reg37;
	        6'h26   : reg_data_out <= slv_reg38;
	        6'h27   : reg_data_out <= slv_reg39;
	        6'h28   : reg_data_out <= slv_reg40;
	        6'h29   : reg_data_out <= slv_reg41;
	        6'h2A   : reg_data_out <= slv_reg42;
	        6'h2B   : reg_data_out <= slv_reg43;
	        6'h2C   : reg_data_out <= slv_reg44;
	        6'h2D   : reg_data_out <= slv_reg45;
	        6'h2E   : reg_data_out <= slv_reg46;
	        6'h2F   : reg_data_out <= slv_reg47;
	        6'h30   : reg_data_out <= slv_reg48;
	        6'h31   : reg_data_out <= slv_reg49;
	        6'h32   : reg_data_out <= slv_reg50;
	        6'h33   : reg_data_out <= slv_reg51;
	        6'h34   : reg_data_out <= slv_reg52;
	        6'h35   : reg_data_out <= slv_reg53;
	        6'h36   : reg_data_out <= slv_reg54;
	        6'h37   : reg_data_out <= slv_reg55;
	        6'h38   : reg_data_out <= slv_reg56;
	        6'h39   : reg_data_out <= slv_reg57;
	        6'h3A   : reg_data_out <= slv_reg58;
	        6'h3B   : reg_data_out <= slv_reg59;
	        6'h3C   : reg_data_out <= slv_reg60;
	        6'h3D   : reg_data_out <= slv_reg61;
	        6'h3E   : reg_data_out <= slv_reg62;
	        6'h3F   : reg_data_out <= slv_reg63;
	        default : reg_data_out <= 0;
	      endcase
	    end   
	end*/

	/*
	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          //axi_rdata <= reg_data_out;     // register read data
	          axi_rdata <= 32'hdeadbeef;
	          
	          if (rd_word_addr < C_REG_CNT) //CONF_RDONLY_OFFSET)
	              axi_rdata <= slv_reg[rd_word_addr];
	          else begin
	              for(i = 0; i < C_CONF_VEC_WIDTH / C_S_AXI_DATA_WIDTH; i = i + 1) begin
	                  if ((rd_word_addr - CONF_RDONLY_OFFSET) == i)
	                      axi_rdata <= usr_conf_reg[i*C_S_AXI_DATA_WIDTH +: C_S_AXI_DATA_WIDTH];
	              end
	          end
	        end
	        
	      usr_mem_rd_ack <= 1'b0;
	      usr_mem_rd_data <= 8'hff;
	      
	      if ((usr_mem_page == C_STATUS_PAGE_NO) && usr_mem_rd_en)
	        begin
	          
	          for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	            if ( usr_mem_offset[1:0] == (C_S_AXI_DATA_WIDTH/8)-1 - byte_index ) begin
	              // Respective byte enables are asserted as per write strobes 
	              // Slave register 0
	              usr_mem_rd_data <= slv_reg[usr_mem_offset[7:2]][(byte_index*8) +: 8];
	            end
	          
	          //usr_mem_rd_data <= slv_reg[usr_mem_offset[7:2]][usr_mem_offset[1:0]];
	          usr_mem_rd_ack <= 1'b1;
	        end
	    end
	end    
*/

	// Add user logic here
//wire      [63:0] chipscope_trig;
//ila_1kx64 ILA_inst (
//  .clk(S_AXI_ACLK), // input clk
//.probe0(chipscope_trig)
//);

assign test_out[15:0]   = axi_awaddr;
assign test_out[47:16]  = S_AXI_WDATA;
assign test_out[51:48]  = S_AXI_WSTRB;
//assign test_out[52]     = slv_reg_wren;
//assign test_out[53]     = usr_mem_rd_en;
//assign test_out[54]     = usr_mem_wr_en;
//assign test_out[55]     = usr_mem_ack;
//assign test_out[63:56]  = usr_mem_page;
//assign test_out[71:64]  = usr_mem_offset;
//assign test_out[79:72]  = usr_mem_rd_data;
//assign test_out[87:80]  = usr_mem_wr_data;
//assign test_out[119:88] = usr_stat_reg;
//assign test_out[151:120] = slv_reg[0];
//assign test_out[183:152] = slv_reg[1];
assign test_out[184]     = S_AXI_ARESETN;
assign test_out[185]     = 1'b1;
	// User logic ends

	endmodule
