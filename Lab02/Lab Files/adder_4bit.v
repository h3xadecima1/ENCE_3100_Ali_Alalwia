
`default_nettype none

module adder_4bit(
	input 	[3:0] 	i_a,
	input 	[3:0] 	i_b,
	input 				i_cin,
	output 				o_cout,
	output 	[3:0] 	o_s
);

	// Combinational Logic only
	assign o_s[2] = ~(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&~i_a[2]&i_b[2]|~(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_a[2]&~i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&~i_a[2]&~i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_a[2]&i_b[2];
	assign o_s[1] = ~(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&~i_a[1]&i_b[1]|~(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1]&~i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&~i_a[1]&~i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1]&i_b[1];
	assign o_s[0] = ~i_cin&~i_a[0]&i_b[0]|~i_cin&i_a[0]&~i_b[0]|i_cin&~i_a[0]&~i_b[0]|i_cin&i_a[0]&i_b[0];
	assign o_cout = i_a[3]&i_b[3]|(i_a[2]&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_a[2])&i_b[3]|(i_a[2]&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_a[2])&i_a[3];
	assign o_s[3] = ~(i_a[2]&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_a[2])&~i_a[3]&i_b[3]|~(i_a[2]&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_a[2])&i_a[3]&~i_b[3]|(i_a[2]&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_a[2])&~i_a[3]&~i_b[3]|(i_a[2]&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_b[2]|(i_a[1]&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_b[1]|(i_a[0]&i_b[0]|i_cin&i_b[0]|i_cin&i_a[0])&i_a[1])&i_a[2])&i_a[3]&i_b[3];
endmodule
