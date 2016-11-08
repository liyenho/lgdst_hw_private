	component remote_update is
		port (
			busy            : out std_logic;                                        -- busy
			data_out        : out std_logic_vector(31 downto 0);                    -- data_out
			param           : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- param
			read_param      : in  std_logic                     := 'X';             -- read_param
			reconfig        : in  std_logic                     := 'X';             -- reconfig
			reset_timer     : in  std_logic                     := 'X';             -- reset_timer
			clock           : in  std_logic                     := 'X';             -- clk
			reset           : in  std_logic                     := 'X';             -- reset
			write_param     : in  std_logic                     := 'X';             -- write_param
			data_in         : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data_in
			asmi_busy       : in  std_logic                     := 'X';             -- asmi_busy
			asmi_data_valid : in  std_logic                     := 'X';             -- asmi_data_valid
			asmi_dataout    : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- asmi_dataout
			asmi_addr       : out std_logic_vector(31 downto 0);                    -- asmi_addr
			asmi_read       : out std_logic;                                        -- asmi_read
			asmi_rden       : out std_logic;                                        -- asmi_rden
			pof_error       : out std_logic                                         -- pof_error
		);
	end component remote_update;

	u0 : component remote_update
		port map (
			busy            => CONNECTED_TO_busy,            --            busy.busy
			data_out        => CONNECTED_TO_data_out,        --        data_out.data_out
			param           => CONNECTED_TO_param,           --           param.param
			read_param      => CONNECTED_TO_read_param,      --      read_param.read_param
			reconfig        => CONNECTED_TO_reconfig,        --        reconfig.reconfig
			reset_timer     => CONNECTED_TO_reset_timer,     --     reset_timer.reset_timer
			clock           => CONNECTED_TO_clock,           --           clock.clk
			reset           => CONNECTED_TO_reset,           --           reset.reset
			write_param     => CONNECTED_TO_write_param,     --     write_param.write_param
			data_in         => CONNECTED_TO_data_in,         --         data_in.data_in
			asmi_busy       => CONNECTED_TO_asmi_busy,       --       asmi_busy.asmi_busy
			asmi_data_valid => CONNECTED_TO_asmi_data_valid, -- asmi_data_valid.asmi_data_valid
			asmi_dataout    => CONNECTED_TO_asmi_dataout,    --    asmi_dataout.asmi_dataout
			asmi_addr       => CONNECTED_TO_asmi_addr,       --       asmi_addr.asmi_addr
			asmi_read       => CONNECTED_TO_asmi_read,       --       asmi_read.asmi_read
			asmi_rden       => CONNECTED_TO_asmi_rden,       --       asmi_rden.asmi_rden
			pof_error       => CONNECTED_TO_pof_error        --       pof_error.pof_error
		);

