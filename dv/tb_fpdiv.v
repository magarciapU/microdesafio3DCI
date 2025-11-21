`timescale 1ns / 1ps

module tb_fpdiv;

    reg [15:0] x1, x2;
    wire [15:0] y;
    reg clk, rst, en;
    wire ready;
    real value1, value2;

    parameter clk_period = 10;
    parameter rst_time = 50;

    // ------------------------------------------------------------
    // FUNCTION: real → BF16
    // (igual a tu testbench anterior)
    // ------------------------------------------------------------
    function [15:0] dtobf16 (input real a);
        reg [63:0] a_bits; 
        reg s;
        reg [7:0]exp;
        reg [8:0]mant;
        reg [11:0]mant_grs;
        reg [6:0] o_mant;
    begin
        if (a==0.0)
            dtobf16=16'd0;
        else begin    
            a_bits=$realtobits(a);
            s=a_bits[63];
            exp=(a_bits[62:52]-1023)+127;
            mant_grs={2'b01,a_bits[51:42]};
            mant=mant_grs[11:3];
            
            if (mant_grs[2:0]>3'd4)
                mant=mant_grs[11:3]+9'd1;
            
            if (mant_grs[2:0]==3'd4) begin
                if(mant_grs[3]==1'b1)
                    mant=mant_grs[11:3]+9'd1;
                else
                    mant=mant_grs[11:3];
            end
            
            if(mant[8]==1'b1) begin
                o_mant=mant[7:1];
                exp=exp+1;
            end else
                o_mant=mant[6:0];

            dtobf16={s,exp,o_mant};
        end
    end
    endfunction


    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------
    fpdiv uut(
        .x1(x1),
        .x2(x2),
        .y(y),
        .clk(clk),
        .rst(rst),
        .en(en),
        .ready(ready)
    );


    // ------------------------------------------------------------
    // TASK PARA APLICAR ENTRADAS Y ESPERAR READY
    // ------------------------------------------------------------
    task apply_div(input real a, input real b);
        begin
            x1 <= dtobf16(a);
            x2 <= dtobf16(b);

            @(posedge clk);
            wait(ready);

            $display("[%0t] DIV %f / %f = y = %h", 
                     $time, a, b, y);
        end
    endtask


    // ------------------------------------------------------------
    // STIMULUS
    // ------------------------------------------------------------
    initial begin
        $dumpfile("fpdiv_tb.vcd");
        $dumpvars(0, tb_fpdiv);

        // Valores de prueba
        value1 = 45.83;
        value2 = 625.41;

        x1 = 0;
        x2 = 0;

        // Espera reset
        #(rst_time + 20);

        // Divisiones normales
        apply_div(value1, value2);
        apply_div(-value1, value2);
        apply_div(value1, -value2);
        apply_div(-value1, -value2);

        // División por cero
        apply_div(value1, 0.0);
        
        // Cero dividido entre número
        apply_div(0.0, value2);

        // Cero / cero (NaN)
        apply_div(0.0, 0.0);

        // Otro caso
        apply_div(3.1416, 1.4142);

        #(clk_period*20);
        $finish;
    end


    // ------------------------------------------------------------
    // CLOCK GENERATOR
    // ------------------------------------------------------------
    initial begin
        clk = 0;
        forever #(clk_period/2) clk = ~clk;
    end


    // ------------------------------------------------------------
    // RESET
    // ------------------------------------------------------------
    initial begin
        rst = 1;
        #rst_time rst = 0;
    end


    // ------------------------------------------------------------
    // ENABLE PARA PIPELINE
    // ------------------------------------------------------------
    initial begin
        en = 0;
        #rst_time en = 1;
    end

endmodule
