
`default_nettype none

module counter_Nbits #
(
	parameter N = 10 // Default 10bits
)
(
	input		i_clk,
	input 	i_reset,
	input 	i_enable,
	input 	[N-1:0] i_data,
	input		i_dir,
	output	reg [N-1:0] o_count
);

	always @(posedge i_clk)
		if(i_reset)
			o_count <= i_data;
		else begin
			if(i_enable) begin
				if(i_dir)
					o_count <= o_count + 10'd1;
				else
					o_count <= o_count - 10'd1;
			end
		end

endmodule

`default_nettype wire
