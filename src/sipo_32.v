module sipo_32 (
    input  wire clk,
    input  wire rst,
    input  wire en,           // habilita el shift
    input  wire serial_in,    // bit entrante
    output reg [31:0] q       // salida paralela
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 32'd0;
        else if (en)
            // MSB-first: entra por el bit 31
            q <= {serial_in, q[31:1]};
    end
endmodule
