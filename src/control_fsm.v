// control_fsm.v
`timescale 1ns/1ps

module control_fsm(
    input wire clk,
    input wire rst,
    input wire sipo_enable,   // load_en sincronizado
    input wire sum_ready,     // listo del sumador

    output reg sum_enable,    // enable del sumador
    output reg piso_enable    // carga del PISO
);

    // Estados codificados como localparam (Verilog-2001)
    localparam IDLE   = 3'd0;
    localparam LOAD   = 3'd1;
    localparam SUM    = 3'd2;
    localparam OUT    = 3'd3;
    localparam RETURN = 3'd4;

    reg [2:0] state;
    reg [2:0] next_state;

    // --------- Estado Secuencial ---------
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // --------- Lógica de Próximo Estado ---------
    always @(*) begin
        next_state = state;

        case (state)

            IDLE: begin
                if (sipo_enable)
                    next_state = LOAD;
            end

            LOAD: begin
                if (!sipo_enable)
                    next_state = SUM;
            end

            SUM: begin
                if (sum_ready)
                    next_state = OUT;
            end

            OUT: begin
                next_state = RETURN;
            end

            RETURN: begin
                next_state = IDLE;
            end

        endcase
    end

    // --------- Señales de Control ---------
    always @(*) begin
        // valores por defecto
        sum_enable  = 0;
        piso_enable = 0;

        case (state)

            LOAD: begin
                // SIPO escribiendo → sumador apagado
                sum_enable = 0;
            end

            SUM: begin
                // SIPO terminó → activar sumador
                sum_enable = 1;
            end

            OUT: begin
                // sum_ready=1 → habilita PISO
                sum_enable  = 0;
                piso_enable = 1;
            end

        endcase
    end

endmodule
