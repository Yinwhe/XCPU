`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2021 10:40:51 AM
// Design Name: 
// Module Name: BHT
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


module BHT #(
        parameter  ADDR_TAG_LEN  = 6  // Length of Address Tag
    )(
        input clk, rst,
        input [31:0] PC_IF,
        input [31:0] PC_ID,
    
        input Branch_ID,
        input is_Branch_ID,
        
        output Jmp
    );
    
    localparam BHT_SIZE = 1 << ADDR_TAG_LEN;
    wire hit_IF;
    reg  hit_ID;
    reg [31 : 0] BHT_TAG [BHT_SIZE-1 : 0];
    reg [1 : 0]  BHT_STA [BHT_SIZE-1 : 0];
    
    wire [ADDR_TAG_LEN-1 : 0] index_IF, index_ID;
    assign index_IF = PC_IF[ADDR_TAG_LEN-1 : 0];
    assign index_ID = PC_ID[ADDR_TAG_LEN-1 : 0];
    
    assign hit_IF = (PC_IF == BHT_TAG[index_IF]);
    assign Jmp = BHT_STA[index_IF][1] & hit_IF;
    
    integer i;
    
    always@(posedge clk) begin
        hit_ID <= hit_IF;
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < BHT_SIZE; i = i + 1) begin
                BHT_TAG[i] <= 0;
                BHT_STA[i] <= 2'b01;
            end
        end
        else begin
            if (is_Branch_ID) begin
                if (!hit_ID) BHT_TAG[index_ID] = PC_ID;
                case(BHT_STA[index_ID]) // Updates State Machine
                    2'b00:BHT_STA[index_ID] = Branch_ID ? 2'b01 : 2'b00;
                    2'b01:BHT_STA[index_ID] = Branch_ID ? 2'b11 : 2'b00;
                    2'b10:BHT_STA[index_ID] = Branch_ID ? 2'b11 : 2'b00;
                    2'b11:BHT_STA[index_ID] = Branch_ID ? 2'b11 : 2'b10;
                endcase
            end
        end
    end
endmodule