// 1-Hz tick from 50-MHz — no derived clocks, just enable pulses
module tick_1hz #(parameter CLK_HZ = 50_000_000)(
  input  wire clk, input wire rst_n,
  output reg  tick
);
  localparam integer N = $clog2(CLK_HZ);
  reg [N-1:0] cnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt  <= 0;
      tick <= 1'b0;
    end else if (cnt == CLK_HZ-1) begin
      cnt  <= 0;
      tick <= 1'b1;   // one-cycle pulse every second
    end else begin
      cnt  <= cnt + 1'b1;
      tick <= 1'b0;
    end
  end
endmodule