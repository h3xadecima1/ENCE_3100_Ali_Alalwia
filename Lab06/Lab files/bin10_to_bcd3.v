// bin10_to_bcd3.v  (Verilog-2001)
// Converts a 10-bit unsigned binary value to 3 BCD digits using double-dabble.
// Outputs: hundreds, tens, ones (each 4 bits). overflow=1 if input > 999.
// Note: when overflow=1, outputs show the lower 3 decimal digits (mod 1000).

module bin10_to_bcd3 (
    input  wire [9:0] bin,         // 0..1023
    output reg  [3:0] hundreds,
    output reg  [3:0] tens,
    output reg  [3:0] ones,
    output reg        overflow
);
    // Shift register: [21:10]=BCD (hundreds|tens|ones), [9:0]=binary
    reg [21:0] shift;
    integer i;

    always @* begin
        // init
        shift      = 22'd0;
        shift[9:0] = bin;
        // 10 iterations (one per binary bit)
        for (i = 0; i < 10; i = i + 1) begin
            // add-3 to any BCD nibble >= 5
            if (shift[21:18] >= 5) shift[21:18] = shift[21:18] + 4'd3; // hundreds
            if (shift[17:14] >= 5) shift[17:14] = shift[17:14] + 4'd3; // tens
            if (shift[13:10] >= 5) shift[13:10] = shift[13:10] + 4'd3; // ones
            // shift left by 1
            shift = shift << 1;
        end

        // extract BCD digits
        hundreds = shift[21:18];
        tens     = shift[17:14];
        ones     = shift[13:10];

        // flag inputs > 999
        overflow = (bin > 10'd999);
    end
endmodule
