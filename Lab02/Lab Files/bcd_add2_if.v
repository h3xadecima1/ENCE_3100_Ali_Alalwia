module bcd_add2_if (
    input  [3:0] A0, A1,
    input  [3:0] B0, B1,
    output reg [3:0] S0, S1,
    output reg       S2
);
    reg [4:0] T0, T1;
    reg [4:0] Z0, Z1;
    reg       c1, c2;

    always @* begin
        // Ones digit
        T0 = A0 + B0;
        if (T0 > 9) begin
            Z0 = 10; c1 = 1;
        end else begin
            Z0 = 0;  c1 = 0;
        end
        S0 = T0 - Z0;

        // Tens digit
        T1 = A1 + B1 + c1;
        if (T1 > 9) begin
            Z1 = 10; c2 = 1;
        end else begin
            Z1 = 0;  c2 = 0;
        end
        S1 = T1 - Z1;

        // Carry into hundreds
        S2 = c2;
    end
endmodule