module piso_16 (
    input wire clk,
    input wire rst,
    input wire load,
    input wire [15:0] d,
    output reg serial_out
);
    reg [15:0] shift;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift <= 16'b0;
            serial_out <= 0;
        end else begin
            if (load)
                shift <= d;         // cargar dato paralelo
            else begin
                serial_out <= shift[15];
                shift <= {shift[14:0], 1'b0};  // desplazar
            end
        end
    end
endmodule
