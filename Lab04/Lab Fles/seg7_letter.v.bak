// letters.v — map H,E,L,O onto 7-seg (active-low)
module seg7_letter(input [2:0] code, output reg [7:0] HEX);
  // 0:H, 1:E, 2:L, 3:O, others blank
  always @(*) begin
    case (code)
      3'd0: HEX = 8'b1001_1000; // H
      3'd1: HEX = 8'b1000_0110; // E
      3'd2: HEX = 8'b1100_0111; // L
      3'd3: HEX = 8'b1100_0000; // O (same as 0)
      default: HEX = 8'b1111_1111;
    endcase
  end
endmodule