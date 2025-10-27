`default_nettype none
module FSM_Word_Detecter(
    input clk,
    input reset,
    input [7:0] RXD_data,
    input data_ready,                 // one-clock pulse from UART
    output reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4
);

    //------------------------------------------------------------
    //  FSM state encoding
    //------------------------------------------------------------
    localparam [2:0]
        S_IDLE = 3'd0,
        S_H    = 3'd1,
        S_HE   = 3'd2,
        S_HEL  = 3'd3,
        S_HELL = 3'd4,
        S_DONE = 3'd5,
        S_SHOW = 3'd6;

    //------------------------------------------------------------
    //  Timing constants for 50 MHz clock
    //------------------------------------------------------------
    localparam integer CNT_3S    = 150_000_000; // 3 s total
    localparam integer CNT_BLINK = 25_000_000;  // 0.5 s toggle

    //------------------------------------------------------------
    //  Internal registers
    //------------------------------------------------------------
    reg [2:0] state, next_state;
    reg [27:0] counter;
    reg blink_state;

    wire done_3s = (counter >= CNT_3S);

    //------------------------------------------------------------
    //  State register
    //------------------------------------------------------------
    always @(posedge clk or posedge reset)
        if (reset) state <= S_IDLE;
        else       state <= next_state;

    //------------------------------------------------------------
    //  Next-state logic (advance only on data_ready pulse)
    //------------------------------------------------------------
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:  if (data_ready && RXD_data == "h") next_state = S_H;

            S_H:     if (data_ready && RXD_data == "e") next_state = S_HE;
                     else if (data_ready) next_state = S_IDLE;

            S_HE:    if (data_ready && RXD_data == "l") next_state = S_HEL;
                     else if (data_ready) next_state = S_IDLE;

            S_HEL:   if (data_ready && RXD_data == "l") next_state = S_HELL;
                     else if (data_ready) next_state = S_IDLE;

            S_HELL:  if (data_ready && RXD_data == "o") next_state = S_DONE;
                     else if (data_ready) next_state = S_IDLE;

            S_DONE:  next_state = S_SHOW;
            S_SHOW:  if (done_3s) next_state = S_IDLE;
            default: next_state = S_IDLE;
        endcase
    end

    //------------------------------------------------------------
    //  Timer + blink toggler
    //------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            blink_state <= 1'b1;
        end else if (state == S_SHOW) begin
            counter <= counter + 1;
            if (counter % CNT_BLINK == 0)
                blink_state <= ~blink_state;
            if (counter >= CNT_3S) begin
                counter <= 0;
                blink_state <= 1'b1;
            end
        end else begin
            counter <= 0;
            blink_state <= 1'b1;
        end
    end

    //------------------------------------------------------------
    //  Output logic
    //------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            HEX0 <= 7'b1111111;
            HEX1 <= 7'b1111111;
            HEX2 <= 7'b1111111;
            HEX3 <= 7'b1111111;
            HEX4 <= 7'b1111111;
        end else begin
            case (state)
                S_SHOW, S_DONE:
                    if (blink_state) begin
                        HEX4 <= seg_H(1'b0);
                        HEX3 <= seg_E(1'b0);
                        HEX2 <= seg_L(1'b0);
                        HEX1 <= seg_L(1'b0);
                        HEX0 <= seg_O(1'b0);
                    end else begin
                        HEX4 <= 7'b1111111;
                        HEX3 <= 7'b1111111;
                        HEX2 <= 7'b1111111;
                        HEX1 <= 7'b1111111;
                        HEX0 <= 7'b1111111;
                    end
                default: begin
                    HEX0 <= 7'b1111111;
                    HEX1 <= 7'b1111111;
                    HEX2 <= 7'b1111111;
                    HEX3 <= 7'b1111111;
                    HEX4 <= 7'b1111111;
                end
            endcase
        end
    end

    //------------------------------------------------------------
    //  7-segment encoders (active-low)
    //------------------------------------------------------------
    function [6:0] seg_H;
        input dummy;
        begin seg_H = 7'b0001001; end // H
    endfunction

    function [6:0] seg_E;
        input dummy;
        begin seg_E = 7'b0000110; end // E
    endfunction

    function [6:0] seg_L;
        input dummy;
        begin seg_L = 7'b1000111; end // L
    endfunction

    function [6:0] seg_O;
        input dummy;
        begin seg_O = 7'b1000000; end // O
    endfunction

endmodule
`default_nettype wire
