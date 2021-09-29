`timescale 1ps/1ps

module HazardDetectionUnit(
    input clk,
    input Branch_ID, rs1use_ID, rs2use_ID,
    input RegW_EXE, RegW_MEM,
    input MIO_EXE, mem_w_EXE,
    input MIO_MEM, mem_w_MEM,
    input MIO_WB,  mem_w_WB,
    input[1:0] hazard_optype_ID,
    input[4:0] rd_EXE, rd_MEM, rd_WB, rs1_ID, rs2_ID,
    output reg PC_EN_IF, reg_FD_EN, reg_FD_stall, reg_FD_flush,
        reg_DE_EN, reg_DE_flush, reg_EM_EN, reg_EM_flush, reg_MW_EN,
    output reg forward_ctrl_ls,
    output reg [1:0] forward_ctrl_A, forward_ctrl_B
);

    //according to the diagram, design the Hazard Detection Unit
    wire Data_hazard = hazard_optype_ID == 2'b01;
    wire Control_hazard = hazard_optype_ID == 2'b10;
    
    wire mem_r_EXE = MIO_EXE && !mem_w_EXE;
    wire mem_r_MEM = MIO_MEM && !mem_w_MEM;
    wire mem_r_WB  = MIO_WB  && !mem_w_WB;
    
    wire load_stall_1_A = mem_r_EXE && rs1use_ID && rd_EXE !=0 && rd_EXE == rs1_ID;
    wire load_stall_2_A = mem_r_MEM && rs1use_ID && rd_MEM !=0 && rd_MEM == rs1_ID;
    wire load_hazard_A  = mem_r_WB  && rs1use_ID && rd_WB  !=0 && rd_WB  == rs1_ID;
    
    wire load_stall_1_B = mem_r_EXE && rs2use_ID && rd_EXE !=0 && rd_EXE == rs2_ID;
    wire load_stall_2_B = mem_r_MEM && rs2use_ID && rd_MEM !=0 && rd_MEM == rs2_ID;
    wire load_hazard_B  = mem_r_WB  && rs2use_ID && rd_WB  !=0 && rd_WB  == rs2_ID;
    
    wire ex_hazard_A  = rs1use_ID && RegW_EXE && rd_EXE != 0 && rs1_ID == rd_EXE;
    wire mem_hazard_A = rs1use_ID && RegW_MEM && rd_MEM != 0 && rs1_ID == rd_MEM;
    
    wire ex_hazard_B  = rs2use_ID && RegW_EXE && rd_EXE != 0 && rs2_ID == rd_EXE;
    wire mem_hazard_B = rs2use_ID && RegW_MEM && rd_MEM != 0 && rs2_ID == rd_MEM;
    // reg_FD_stall
    // reg_FD_flush
    // reg_DE_flush
    // reg_EM_flush
    initial begin
        reg_FD_stall = 0;
        reg_FD_flush = 0;
        reg_DE_flush = 0;
        reg_EM_flush = 0;
        PC_EN_IF  = 1;
        reg_FD_EN = 1;
        reg_DE_EN = 1;
        reg_EM_EN = 1;
        reg_MW_EN = 1;
        
        forward_ctrl_ls = 0;
    end
    
    always@(*) begin
        reg_FD_stall = 0;
        reg_FD_flush = 0;
        reg_DE_flush = 0;
        PC_EN_IF = 1;
        
        if (load_stall_1_A | load_stall_2_A) begin // Load use stall
            reg_FD_stall = 1;
            reg_DE_flush = 1;
            PC_EN_IF = 0;
            forward_ctrl_A = 2'b00;
        end
        else if (load_hazard_A) begin // Actual load use hazard
            forward_ctrl_A = 2'b11;
        end
        else if (ex_hazard_A) begin // EX Hazard A
            forward_ctrl_A = 2'b01;
        end
        else if (mem_hazard_A) begin // MEM Hazard A
            forward_ctrl_A = 2'b10;
        end
        else begin
            forward_ctrl_A = 2'b00;
        end


        if (load_stall_1_B | load_stall_2_B) begin // Load use stall
            reg_FD_stall = 1;
            reg_DE_flush = 1;
            PC_EN_IF = 0;
            forward_ctrl_B = 2'b00;
        end
        else if (load_hazard_B) begin // Actual load use hazard
            forward_ctrl_B = 2'b11;
        end
        else if (ex_hazard_B) begin // EX Hazard B
            forward_ctrl_B = 2'b01;
        end
        else if (mem_hazard_B) begin // MEM Hazard B
            forward_ctrl_B = 2'b10;
        end
        else begin
            forward_ctrl_B = 2'b00;
        end
        
        if (Control_hazard) begin
            reg_FD_flush = 1;
        end
    end
endmodule