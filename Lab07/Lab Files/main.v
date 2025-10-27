`default_nettype none

module main(
    input        MAX10_CLK1_50,
    input  [9:0] SW,
    output [9:0] LEDR,
    inout  [35:0] GPIO,
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6
);

    wire w_clk = MAX10_CLK1_50;

    // UART receiver signals
    wire RxD_data_ready;
    wire [7:0] RxD_data;
    reg  [7:0] GPout;

    // UART Receiver (115200 baud)
    async_receiver RX (
        .clk(w_clk),
        .RxD(GPIO[35]),
        .RxD_data_ready(RxD_data_ready),
        .RxD_data(RxD_data)
    );

    // UART Transmitter (echo back)
    async_transmitter TX (
        .clk(w_clk),
        .TxD(GPIO[33]),
        .TxD_start(RxD_data_ready),
        .TxD_data(RxD_data)
    );

    // Store received byte
    always @(posedge w_clk) begin
        if (RxD_data_ready)
            GPout <= RxD_data;
    end

    // Display received byte on LEDs
    assign LEDR[7:0] = GPout;

    // FSM word detector for "hello"
   FSM_Word_Detecter word_detector (
    .clk(w_clk),
    .reset(SW[9]),
    .RXD_data(GPout),
    .data_ready(RxD_data_ready),  // <— added line
    .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4)
);

    // Blank unused HEX displays
    assign HEX5 = 7'b1111111;
    assign HEX6 = 7'b1111111;

endmodule

`default_nettype wire
