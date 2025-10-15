module counter_1s(
	// Board I/Os
	input		Clock,
	input 	Resetn,
	output	reg led_out
);
	
	// Counter Template
	parameter DIVISOR = 25000000;
	reg [24:0] counter;  // 2^25 = 33,554,432 > 25,000,000
	//reg led_out;

	always @(posedge Clock, negedge Resetn)
		if(!Resetn)
		begin
			counter <= 0;
			led_out <= 0;
		end else
		begin
			// Comparator
			if(counter == DIVISOR - 1)
			begin
				counter <= 0;
				led_out <= ~led_out;  // toggle LED
			end else
				counter <= counter + 1;
		end

endmodule
