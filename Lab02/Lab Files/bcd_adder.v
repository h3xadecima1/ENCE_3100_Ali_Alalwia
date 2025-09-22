module bcd_adder (
    input  [3:0] A, B,
    input        Cin,
    output reg [3:0] Sum,
    output reg       Cout
);
    reg [4:0] temp;

    always @(*) begin
        temp = A + B + Cin;
        if (temp > 9) begin
            temp = temp + 6;  // BCD correction
            Cout = 1;
        end else begin
            Cout = 0;
        end
        Sum = temp[3:0];
    end
endmodule
