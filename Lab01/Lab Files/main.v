module main (
    input  MAX10_CLK1_50,   // 50 MHz clock
    input  [9:0] SW,        // 10 switches
    output [9:0] LEDR,      // 10 LEDs
    output reg [7:0] HEX5,
    output reg [7:0] HEX4,
    output reg [7:0] HEX3,
    output reg [7:0] HEX2,
    output reg [7:0] HEX1,
    output reg [7:0] HEX0
);

    // -----------------------------
    // Map switches to LEDs
    // -----------------------------
    assign LEDR = SW;

    // -----------------------------
    // Active-low 7-seg patterns
    // -----------------------------
    localparam BLANK = 8'b11111111;
    localparam H     = 8'b10001001;
    localparam E     = 8'b10000110;
    localparam L     = 8'b11000111;
    localparam O     = 8'b11000000;
    localparam W     = 8'b10000001;
    localparam R     = 8'b10101111;
    localparam D     = 8'b10100001;

    // -----------------------------
    // Message buffers
    // -----------------------------
    parameter MSG_HELO_LEN = 10;
    parameter MSG_HELLO_WORLD_LEN = 20;

    reg [7:0] msg_helo [0:MSG_HELO_LEN-1];
    reg [7:0] msg_helloworld [0:MSG_HELLO_WORLD_LEN-1];

    initial begin
        // "HELO    "
        msg_helo[0] = H;
        msg_helo[1] = E;
        msg_helo[2] = L;
        msg_helo[3] = O;
        msg_helo[4] = BLANK;
        msg_helo[5] = BLANK;
        msg_helo[6] = BLANK;
        msg_helo[7] = BLANK;
        msg_helo[8] = BLANK;
        msg_helo[9] = BLANK;

        // "HELLO WORLD      "
        msg_helloworld[0]  = H;
        msg_helloworld[1]  = E;
        msg_helloworld[2]  = L;
        msg_helloworld[3]  = L;
        msg_helloworld[4]  = O;
        msg_helloworld[5]  = BLANK;
        msg_helloworld[6]  = W;
        msg_helloworld[7]  = O;
        msg_helloworld[8]  = R;
        msg_helloworld[9]  = L;
        msg_helloworld[10] = D;
        msg_helloworld[11] = BLANK;
        msg_helloworld[12] = BLANK;
        msg_helloworld[13] = BLANK;
        msg_helloworld[14] = BLANK;
        msg_helloworld[15] = BLANK;
        msg_helloworld[16] = BLANK;
        msg_helloworld[17] = BLANK;
        msg_helloworld[18] = BLANK;
        msg_helloworld[19] = BLANK;
    end

    integer index = 0;

    // -----------------------------
    // Clock divider (~2 Hz)
    // -----------------------------
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

    // -----------------------------
    // Scroll index update
    // -----------------------------
    always @(posedge MAX10_CLK1_50) begin
        if (tick && ~SW[1]) begin   // SW[1] = pause
            if (~SW[0]) begin
                // left scroll
                if (SW[2] == 0) begin
                    if (index == MSG_HELO_LEN-1) index <= 0;
                    else index <= index + 1;
                end else begin
                    if (index == MSG_HELLO_WORLD_LEN-1) index <= 0;
                    else index <= index + 1;
                end
            end else begin
                // right scroll
                if (SW[2] == 0) begin
                    if (index == 0) index <= MSG_HELO_LEN-1;
                    else index <= index - 1;
                end else begin
                    if (index == 0) index <= MSG_HELLO_WORLD_LEN-1;
                    else index <= index - 1;
                end
            end
        end
    end

    // -----------------------------
    // Drive HEX displays
    // -----------------------------
    always @(*) begin
        if (SW[2] == 0) begin
            // Scroll "HELO"
            HEX5 = (index >= 5) ? msg_helo[index-5] : BLANK;
            HEX4 = (index >= 4) ? msg_helo[index-4] : BLANK;
            HEX3 = (index >= 3) ? msg_helo[index-3] : BLANK;
            HEX2 = (index >= 2) ? msg_helo[index-2] : BLANK;
            HEX1 = (index >= 1) ? msg_helo[index-1] : BLANK;
            HEX0 = msg_helo[index];
        end else begin
            // Scroll "HELLO WORLD"
            HEX5 = (index >= 5) ? msg_helloworld[index-5] : BLANK;
            HEX4 = (index >= 4) ? msg_helloworld[index-4] : BLANK;
            HEX3 = (index >= 3) ? msg_helloworld[index-3] : BLANK;
            HEX2 = (index >= 2) ? msg_helloworld[index-2] : BLANK;
            HEX1 = (index >= 1) ? msg_helloworld[index-1] : BLANK;
            HEX0 = msg_helloworld[index];
        end
    end

endmodule
