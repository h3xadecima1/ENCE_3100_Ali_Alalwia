//=======================================================
// 16-bit Binary to BCD (Verilog-2001)
// - Unsigned 16-bit input (0..65535)
// - Outputs 5 BCD digits: ten-thousands, thousands, hundreds, tens, ones
// - Shift-add-3 (double dabble), fully combinational
//=======================================================
module bin16_to_bcd
(
    input  wire [15:0] bin,                 // 0..65535

    output reg  [3:0] bcd_ten_thousands,    // 0..6
    output reg  [3:0] bcd_thousands,        // 0..9
    output reg  [3:0] bcd_hundreds,         // 0..9
    output reg  [3:0] bcd_tens,             // 0..9
    output reg  [3:0] bcd_ones              // 0..9
);
    integer i;

    // [35:32]=TT, [31:28]=TH, [27:24]=H, [23:20]=T, [19:16]=O, [15:0]=working input
    reg [35:0] shift;

    always @* begin
        // init: all BCD nibbles zero, input in lower 16 bits
        shift = {20'd0, bin};

        // perform 16 iterations (one per input bit)
        for (i = 0; i < 16; i = i + 1) begin
            // add-3 where any BCD nibble >= 5
            if (shift[35:32] >= 5) shift[35:32] = shift[35:32] + 4'd3; // ten-thousands
            if (shift[31:28] >= 5) shift[31:28] = shift[31:28] + 4'd3; // thousands
            if (shift[27:24] >= 5) shift[27:24] = shift[27:24] + 4'd3; // hundreds
            if (shift[23:20] >= 5) shift[23:20] = shift[23:20] + 4'd3; // tens
            if (shift[19:16] >= 5) shift[19:16] = shift[19:16] + 4'd3; // ones

            // shift left by 1 to bring next input bit up
            shift = shift << 1;
        end

        // assign outputs
        bcd_ten_thousands = shift[35:32];
        bcd_thousands     = shift[31:28];
        bcd_hundreds      = shift[27:24];
        bcd_tens          = shift[23:20];
        bcd_ones          = shift[19:16];
    end
endmodule
