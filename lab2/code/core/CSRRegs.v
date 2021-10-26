`timescale 1ns / 1ps

module CSRRegs(
    input clk, rst,
    input[11:0] raddr, waddr,
    input[31:0] wdata,
    input csr_w,
    input[1:0] csr_wsc_mode,
    input[5:0] exp,
    input[31:0]
    
    output[31:0] rdata,
    output[31:0] mstatus,
    output[31:0] mepc,
    output[31:0] mcause,
    output[31:0] mie,
    output[31:0] mip
);

    reg[31:0] CSR [0:15];
    reg[1:0]  CM;   // Current Mode

    // Address mapping. The address is 12 bits, but only 4 bits are used in this module.
    wire raddr_valid = raddr[11:7] == 5'h6 && raddr[5:3] == 3'h0;
    wire[3:0] raddr_map = (raddr[6] << 3) + raddr[2:0];
    wire waddr_valid = waddr[11:7] == 5'h6 && waddr[5:3] == 3'h0;
    wire[3:0] waddr_map = (waddr[6] << 3) + waddr[2:0];

    assign mstatus = CSR[0];
    assign mepc    = CSR[9];
    assign mcause  = CSR[10];
    assign mie     = CSR[4];
    assign mip     = CSR[12];
    
    assign rdata = CSR[raddr_map];

    wire ABN = exp != 6'b000000;    // Abnormal Type
    
    wire MRET = exp[5];
    wire INT  = exp[0];
    wire[3:0] EXP = exp[4:1];


    always@(posedge clk or posedge rst) begin
        if(rst) begin
			CSR[0]  <= 32'h88;   // mstatus
			CSR[1]  <= 0;
			CSR[2]  <= 0;
			CSR[3]  <= 0;
			CSR[4]  <= 32'hfff;  // mie
			CSR[5]  <= 0;        // mtvec
			CSR[6]  <= 0;
			CSR[7]  <= 0;
			CSR[8]  <= 0;
			CSR[9]  <= 0;        // mepc
			CSR[10] <= 0;        // mcause
			CSR[11] <= 0;
			CSR[12] <= 0;        // mip
			CSR[13] <= 0;
			CSR[14] <= 0;
			CSR[15] <= 0;
			CM      <= 2'b11;
		end
        else if(!ABN & csr_w) begin
            case(csr_wsc_mode)
                2'b01: CSR[waddr_map] = wdata;
                2'b10: CSR[waddr_map] = CSR[waddr_map] | wdata;
                2'b11: CSR[waddr_map] = CSR[waddr_map] & ~wdata;
                default: CSR[waddr_map] = wdata;
            endcase            
        end
        else if(ABN) begin
            if (MRET) begin
            
            end
            else if (INT) begin
                CSR[0][3] <= 1'b0; CSR[0][7] <= 1'b1; CSR[0][12:11] <= CM;
            end
            else if (EXP) begin
            
            end
        end
    end
endmodule