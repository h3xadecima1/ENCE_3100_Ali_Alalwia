//=======================================================
// Debounce (Verilog-2001)
// - Parameterizable by clock frequency and debounce time
// - Outputs: debounced level, 1-cycle press/release pulses
//=======================================================
module debounce #
(
    parameter integer CLK_HZ       = 50_000_000, // input clock frequency
    parameter integer DEBOUNCE_MS  = 10          // debounce time in ms (5–20 typical)
)
(
    input  wire clk,
    input  wire rst,          // synchronous reset, active high
    input  wire btn_raw,      // asynchronous, noisy button input

    output wire btn_level,    // debounced stable level
    output wire btn_pressed,  // 1-clock pulse on low->high transition
    output wire btn_released  // 1-clock pulse on high->low transition
);

    // ---------------------------------------------------
    // Utility: clog2 for counter width (Verilog-2001 style)
    // ---------------------------------------------------
    function integer clog2;
        input integer value;
        integer i;
        begin
            clog2 = 0;
            for (i = value-1; i > 0; i = i >> 1)
                clog2 = clog2 + 1;
        end
    endfunction

    // Number of clock ticks to consider input stable
    localparam integer CNT_MAX = (CLK_HZ/1000)*DEBOUNCE_MS;
    localparam integer CNT_W   = (CNT_MAX > 1) ? clog2(CNT_MAX) : 1;

    // ---------------------------------------------------
    // 2-FF synchronizer (mitigate metastability)
    // ---------------------------------------------------
    reg sync_ff1, sync_ff2;
    always @(posedge clk) begin
        if (rst) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff1 <= btn_raw;
            sync_ff2 <= sync_ff1;
        end
    end

    // ---------------------------------------------------
    // Debounce counter and stable state
    // If input equals current stable state -> counter resets
    // If different -> count until CNT_MAX-1, then accept new state
    // ---------------------------------------------------
    reg [CNT_W-1:0] cnt;
    reg             stable_state;

    always @(posedge clk) begin
        if (rst) begin
            stable_state <= 1'b0;
            cnt          <= {CNT_W{1'b0}};
        end else if (sync_ff2 == stable_state) begin
            cnt <= {CNT_W{1'b0}};
        end else begin
            if (cnt == CNT_MAX-1) begin
                stable_state <= sync_ff2;
                cnt          <= {CNT_W{1'b0}};
            end else begin
                cnt <= cnt + {{(CNT_W-1){1'b0}}, 1'b1};
            end
        end
    end

    // ---------------------------------------------------
    // Edge detection (one-cycle pulses)
    // ---------------------------------------------------
    reg stable_state_d1;
    always @(posedge clk) begin
        if (rst)
            stable_state_d1 <= 1'b0;
        else
            stable_state_d1 <= stable_state;
    end

    assign btn_level   = stable_state;
    assign btn_pressed =  stable_state & ~stable_state_d1; // rising edge
    assign btn_released= ~stable_state &  stable_state_d1; // falling edge

    // (Optional) sanity message at sim time
    // initial if (CNT_MAX < 2) $display("NOTE: CNT_MAX<2; consider increasing DEBOUNCE_MS.");
endmodule
