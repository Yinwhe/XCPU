`timescale 1ns / 1ps

module core_sim;
    reg clk, rst;
    reg int;

    RV32core core(
        .debug_en(1'b0),
        .debug_step(1'b0),
        .debug_addr(7'b0),
        .debug_data(),
        .clk(clk),
        .rst(rst),
        .interrupter(int)
    );

    initial begin
        clk = 0;
        rst = 1;
        int = 0;
        #2 rst = 0;
        #102 int = 1;
        #4 int = 0;
    end
    always #1 clk = ~clk;

endmodule