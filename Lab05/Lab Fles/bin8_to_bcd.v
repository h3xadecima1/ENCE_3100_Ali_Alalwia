//=======================================================
// 8-bit Binary to BCD (Verilog-2001)
// - Unsigned 8-bit input (0..255)
// - Outputs 3 BCD digits: hundreds, tens, ones
// - Uses shift-add-3 (double dabble), fully combinational
//=======================================================
module bin8_to_bcd
(
    input  wire [7:0] bin,            // 0..255
    output reg  [3:0] bcd_hundreds,   // 0..2
    output reg  [3:0] bcd_tens,       // 0..9
    output reg  [3:0] bcd_ones        // 0..9
);
    integer i;
    reg [19:0] shift; // [19:16]=hundreds, [15:12]=tens, [11:8]=ones, [7:0]=working bits

    always @* begin
        // init: BCD digits = 0, place input in lower 8 bits
        shift = {12'd0, bin};

        // perform 8 iterations (one per input bit)
        for (i = 0; i < 8; i = i + 1) begin
            // add-3 where any BCD nibble >= 5
            if (shift[19:16] >= 5) shift[19:16] = shift[19:16] + 4'd3; // hundreds
            if (shift[15:12] >= 5) shift[15:12] = shift[15:12] + 4'd3; // tens
            if (shift[11:8]  >= 5) shift[11:8]  = shift[11:8]  + 4'd3; // ones

            // shift left by 1 to bring next input bit up
            shift = shift << 1;
        end

        // assign outputs
        bcd_hundreds = shift[19:16];
        bcd_tens     = shift[15:12];
        bcd_ones     = shift[11:8];
    end
endmodule
