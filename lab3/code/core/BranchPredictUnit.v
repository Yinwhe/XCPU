`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2021 01:40:32 PM
// Design Name: 
// Module Name: BranchPredictUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BranchPredictUnit(
        input clk, rst,
        input [31:0] PC_IF,
        input [31:0] PC_ID,
        
        input data_stall,
        input Branch_ID,
        input is_Branch_ID,
        input [31:0] Branch_Addr,
        
        output fail,
        output [31:0] NPC
    );
    
    wire [31:0] Pred_PC_BTB;
    wire fail_1, fail_2;
    reg hit_ID;
    reg pred_jmp_ID;
    
    always@(posedge clk) begin
        if (!data_stall) begin
            hit_ID <= hit_IF;
            pred_jmp_ID <= pred_jmp_IF;
        end
        else begin
            hit_ID <= hit_ID;
            pred_jmp_ID <= pred_jmp_ID;
        end
    end
        
    BHT BHT (.clk(clk), .rst(rst), .PC_IF(PC_IF), .PC_ID(PC_ID),
             .Branch_ID(Branch_ID), .is_Branch_ID(is_Branch_ID),
             .Jmp(pred_jmp_IF));

    BTB BTB (.clk(clk), .rst(rst), .PC_IF(PC_IF), .PC_ID(PC_ID), .hit_ID(hit_ID),
             .Branch_ID(Branch_ID), .is_Branch_ID(is_Branch_ID), .Branch_Addr(Branch_Addr),
             .hit(hit_IF), .Pred_PC(Pred_PC_BTB));
    
    assign fail_1 = pred_jmp_ID ^ Branch_ID;
    assign fail_2 = pred_jmp_ID & ~hit_ID & ~fail_1;
    assign fail = fail_1 | fail_2;
    
    assign NPC = {32{~fail &  pred_jmp_IF}}  & Pred_PC_BTB |
                 {32{~fail & ~pred_jmp_IF}}  & PC_IF + 4   |
                 {32{fail_1 &  pred_jmp_ID}} & PC_ID + 4   |
                 {32{fail_1 & ~pred_jmp_ID | fail_2}} & Branch_Addr;
                 
endmodule
