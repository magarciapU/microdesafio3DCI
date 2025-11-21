// tb_chipi.v
`timescale 1ns/1ps

module tb_chipi;

    reg clk = 0;
    reg rst = 1;
    reg serial_in = 0;
    reg sipo_enable = 0;
    reg add_sub = 0;

    wire ready;
    wire serial_out;

    // Instanciar DUT
    chipi dut (
        .clk(clk),
        .rst(rst),
        .serial_in(serial_in),
        .sipo_enable(sipo_enable),
        .add_sub(add_sub),
        .ready(ready),
        .serial_out(serial_out)
    );

    // Clock único
    always #5 clk = ~clk;   // 100 MHz

    //-----------------------------------------
    // TASK para enviar 32 bits por serial
    //-----------------------------------------
    task send_serial_32(input [31:0] data);
        integer i;
        begin
            for (i = 31; i >= 0; i = i - 1) begin
                @(posedge clk);
                serial_in <= data[i];
            end
        end
    endtask

    //-----------------------------------------
    // Reconstrucción del resultado serial
    //-----------------------------------------
    reg [15:0] serial_recv = 0;

    always @(posedge clk) begin
        serial_recv <= {serial_recv[14:0], serial_out};
    end

    //-----------------------------------------
    // TEST PRINCIPAL
    //-----------------------------------------
    initial begin
        $dumpfile("chipi.vcd");
        $dumpvars(0, tb_chipi);

        $display("\n===== INICIO DE SIMULACION =====\n");

        // Reset
        repeat(4) @(posedge clk);
        rst <= 0;

        //-------------------------------------
        // Enviar operandos seriales
        //-------------------------------------
        // x1 = 0x4120 → 10.125
        // x2 = 0x40A0 → 5.0

        $display("Enviando operandos en serie: x1=0x4120, x2=0x40A0");

        sipo_enable <= 1;
        send_serial_32({16'h4120, 16'h40A0});
        @(posedge clk);
        sipo_enable <= 0;

        $display("Carga serial terminada.");
        $display("Esperando ready del sumador...");

        //-------------------------------------
        // Esperar resultado del sumador FP16
        //-------------------------------------
        wait (ready == 1);

        $display("SUMADOR COMPLETADO. Leyendo salida serial del PISO...");

        // Esperamos 16 ciclos para capturar salida
        repeat(16) @(posedge clk);

        $display("Resultado serial reconstruido = %h", serial_recv);

        $display("\n===== FIN DE SIMULACION =====\n");
        $finish;
    end

endmodule
