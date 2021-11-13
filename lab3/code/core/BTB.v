`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2021 12:34:41 PM
// Design Name: 
// Module Name: BTB
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


module BTB #(
        parameter  ADDR_TAG_LEN  = 6  // tag长度
    )(
        input clk, rst,
        input [31:0] PC_IF,
        input [31:0] PC_ID,

        input hit_ID,
        input Branch_ID,
        input is_Branch_ID,
        input [31:0] Branch_Addr, // Actual brach address

        output hit,
        output [31:0] Pred_PC
    );
    
    localparam BTB_SIZE = 1 << ADDR_TAG_LEN;
    
    reg [31 : 0] BTB_TAG [BTB_SIZE-1 : 0];  // Tag Part
    reg [31 : 0] BTB_PPC [BTB_SIZE-1 : 0];  // Pred PC
    
    integer i;

    wire [ADDR_TAG_LEN-1 : 0] index_IF, index_ID;
    assign index_IF = PC_IF[ADDR_TAG_LEN-1 : 0];
    assign index_ID = PC_ID[ADDR_TAG_LEN-1 : 0];
    
    assign hit = (PC_IF == BTB_TAG[index_IF]);
    assign Pred_PC = BTB_PPC[index_IF];
    
    always@(posedge clk or posedge rst) begin
        if (rst) begin
            for(i = 0; i < BTB_SIZE; i = i + 1) begin
                BTB_TAG[i] <= 0;
                BTB_PPC[i] <= 0;
            end
        end
        else if(is_Branch_ID) begin
            if (!hit_ID) begin // Updates
                BTB_TAG[index_ID] <= PC_ID;
                BTB_PPC[index_ID] <= Branch_Addr;
            end
        end
    end
    
endmodule