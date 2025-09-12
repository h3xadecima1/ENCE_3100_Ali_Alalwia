module main (
    input MAX10_CLK1_50,     // 50 MHz clock
    output reg [7:0] HEX5,
    output reg [7:0] HEX4,
    output reg [7:0] HEX3,
    output reg [7:0] HEX2,
    output reg [7:0] HEX1,
    output reg [7:0] HEX0
);

    // Active-low 7-seg patterns
    localparam BLANK = 8'b11111111;
    localparam H     = 8'b10001001;
    localparam E     = 8'b10000110;
    localparam L     = 8'b11000111;
    localparam O     = 8'b11000000;

    // Message buffer: "HELO    "
    parameter MSG_LEN = 10;
    reg [7:0] message [0:MSG_LEN-1];
    initial begin
        message[0] = H;
        message[1] = E;
        message[2] = L;
        message[3] = O;
        message[4] = BLANK;
        message[5] = BLANK;
        message[6] = BLANK;
        message[7] = BLANK;
        message[8] = BLANK;
        message[9] = BLANK;
    end

    integer index = 0;

    // Clock divider (~2 Hz)
    reg [25:0] divcnt = 0;
    reg tick = 0;
    always @(posedge MAX10_CLK1_50) begin
        if (divcnt == 25_000_000) begin
            divcnt <= 0;
            tick   <= 1;
        end else begin
            divcnt <= divcnt + 1;
            tick   <= 0;
        end
    end

    // Update scroll index
    always @(posedge MAX10_CLK1_50) begin
        if (tick) begin
            if (index == MSG_LEN-1)
                index <= 0;
            else
                index <= index + 1;
        end
    end

    // Drive HEX5..HEX0 with right-justified window
    always @(*) begin
        HEX5 = (index >= 5) ? message[index-5] : BLANK;
        HEX4 = (index >= 4) ? message[index-4] : BLANK;
        HEX3 = (index >= 3) ? message[index-3] : BLANK;
        HEX2 = (index >= 2) ? message[index-2] : BLANK;
        HEX1 = (index >= 1) ? message[index-1] : BLANK;
        HEX0 = message[index];
    end

endmodule
