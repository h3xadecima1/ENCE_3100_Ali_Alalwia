`default_nettype none

module FSM_ChessTimer(
    input clk,
    input reset,
    input [1:0] buttons,         // buttons[0] = Player 1, buttons[1] = Player 2
    input [9:0] counter_1,
    input [9:0] counter_2,
    output reg [1:0] load_counters,
    output reg [1:0] en_counters,
    output reg [1:0] state_displays
);

    // State encoding
    localparam IDLE    = 2'b00;
    localparam PLAYER1 = 2'b01;
    localparam PLAYER2 = 2'b10;
    localparam END     = 2'b11;

    reg [1:0] state, next_state;

    // 1. State Register (sequential)
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // 2. Next-State Logic (combinational)
    always @(*) begin
        case (state)
            IDLE: begin
                if (buttons[0])
                    next_state = PLAYER1;
                else if (buttons[1])
                    next_state = PLAYER2;
                else
                    next_state = IDLE;
            end

            PLAYER1: begin
                if (counter_1 == 10'd0)
                    next_state = END;
                else if (buttons[1])
                    next_state = PLAYER2;
                else
                    next_state = PLAYER1;
            end

            PLAYER2: begin
                if (counter_2 == 10'd0)
                    next_state = END;
                else if (buttons[0])
                    next_state = PLAYER1;
                else
                    next_state = PLAYER2;
            end

            END: begin
                if (reset)
                    next_state = IDLE;
                else
                    next_state = END;
            end

            default: next_state = IDLE;
        endcase
    end

    // 3. Output Logic (combinational)
    always @(*) begin
        // Default outputs
        load_counters   = 2'b00;
        en_counters     = 2'b00;
        state_displays  = 2'b00;

        case (state)
            IDLE: begin
                load_counters   = 2'b11;  // Load both counters
                en_counters     = 2'b00;  // Disable counting
                state_displays  = 2'b00;  // Show "OG"
            end

            PLAYER1: begin
                load_counters   = 2'b00;
                en_counters     = 2'b01;  // Enable Player 1 counter
                state_displays  = 2'b01;  // Show both counters
            end

            PLAYER2: begin
                load_counters   = 2'b00;
                en_counters     = 2'b10;  // Enable Player 2 counter
                state_displays  = 2'b01;  // Show both counters
            end

            END: begin
                load_counters   = 2'b00;
                en_counters     = 2'b00;
                state_displays  = 2'b10;  // Show "Pend"
            end
        endcase
    end

endmodule

`default_nettype wire
