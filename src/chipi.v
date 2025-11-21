// chipi.v
`timescale 1ns/1ps

module chipi(
    input  wire clk,
    input  wire rst,
    input  wire serial_in,   // flujo serial con x1 y x2
    input  wire sipo_enable, // habilita desplazamiento del SIPO
    input  wire add_sub,     // operación del sumador FP16
    output wire ready,       // listo del sumador
    output wire serial_out   // salida PISO serial
);

    // --------------------------
    //  SIPO: recibe 32 bits
    // --------------------------
    wire [31:0] sipo_data;

    sipo_32 sipo_inst (
        .clk(clk),
        .rst(rst),
        .en(sipo_enable),
        .serial_in(serial_in),
        .q(sipo_data)
    );

    // Extraer operandos
    wire [15:0] x1 = sipo_data[31:16];
    wire [15:0] x2 = sipo_data[15:0];

    // --------------------------
    // Control FSM
    // --------------------------
    wire sum_enable;
    wire piso_enable;

    control_fsm fsm_inst (
        .clk(clk),
        .rst(rst),
        .sipo_enable(sipo_enable),
        .sum_ready(ready),
        .sum_enable(sum_enable),
        .piso_enable(piso_enable)
    );

    // --------------------------
    // FP16 adder/subtractor
    // --------------------------
    wire [15:0] y_parallel;

    fp16sum_res_pipe fp_add_inst (
        .x1(x1),
        .x2(x2),
        .clk(clk),
        .rst(rst),
        .add_sub(add_sub),
        .en(sum_enable),
        .ready(ready),
        .y(y_parallel)
    );

    // --------------------------
    // PISO: salida serial
    // --------------------------
    piso_16 piso_inst (
        .clk(clk),
        .rst(rst),
        .load(piso_enable),
        .d(y_parallel), 
        .serial_out(serial_out)
    );

endmodule
