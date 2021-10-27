`timescale 1ns / 1ps

module ExceptionUnit(
    input clk, rst,
    input csr_rw_in,
    input[1:0] csr_wsc_mode_in,
    input csr_w_imm_mux,
    input[11:0] csr_rw_addr_in,
    input[31:0] csr_w_data_reg,
    input[4:0] csr_w_data_imm,
    output[31:0] csr_r_data_out,

    input interrupt,
    input illegal_inst,
    input l_access_fault,
    input s_access_fault,
    input ecall_m,
    input mret,

    input[31:0] epc_cur,
    input[31:0] epc_next,
    output[31:0] PC_redirect,
    output redirect_mux,

    output reg_FD_flush, reg_DE_flush, reg_EM_flush, reg_MW_flush, 
    output RegWrite_cancel
);

    reg[11:0] csr_rwaddr;
    reg[31:0] csr_wdata;
    reg csr_w;
    reg[1:0] csr_wsc;
    
    reg[31:0] PCR;
    reg Re;
    reg Flush;
    reg RWC;

    wire[5:0] exp = {mret, ecall_m, s_access_fault, l_access_fault, illegal_inst, interrupt};
    
    reg[31:0] CSR [0:15];
    reg[1:0]  CM;   // Current Mode

    wire[31:0] mstatus = CSR[0];
    wire[31:0] mepc    = CSR[9];
    wire[31:0] mcause  = CSR[10];
    wire[31:0] mie     = CSR[4];
    wire[31:0] mip     = CSR[12];
    wire[31:0] mtvec   = CSR[5];

    wire rwaddr_valid = csr_rwaddr[11:7] == 5'h6 && csr_rwaddr[5:3] == 3'h0;
    wire[3:0] rwaddr_map = (csr_rwaddr[6] << 3) + csr_rwaddr[2:0];

    wire MIE = mstatus[3];
    
    wire MRET = exp[5];
    wire INT  = exp[0] & MIE;
    wire[3:0] EXP = exp[4:1] & {4{MIE}};
    wire ABN = MRET | INT | |EXP;    // Abnormal Type
    

    assign csr_r_data_out = CSR[rwaddr_map];
    assign PC_redirect = PCR;
    assign redirect_mux = Re;
    assign reg_FD_flush = Flush;
    assign reg_DE_flush = Flush;
    assign reg_EM_flush = Flush;
    assign reg_MW_flush = Flush;
    assign RegWrite_cancel = RWC;

    always@(*) begin
        if (rst) begin
            csr_rwaddr <= 0;
            csr_wdata  <= 0;
            csr_w      <= 0;
            csr_wsc    <= 0;
            PCR        <= 0;
            Re         <= 0;
            Flush      <= 0;
            RWC        <= 0;
        end
        else begin
                csr_wsc    <= csr_wsc_mode_in;
                csr_rwaddr <= csr_rw_addr_in;
                csr_wdata  <= {32{csr_w_imm_mux}}  & {27'b0, csr_w_data_imm} |
                              {32{~csr_w_imm_mux}} & csr_w_data_reg;
            if (!ABN) begin
                csr_w      <= csr_rw_in;
                PCR        <= 0;
                Re         <= 0;
                Flush      <= 0;
                RWC        <= 0;
            end
            else begin
                csr_w <= 1'b0;
                Re    <= 1'b1;
                Flush <= 1'b1;
                if (INT) begin
                    PCR <= mtvec;
                    RWC <= 1'b0;
                end
                else if (EXP) begin
                    PCR <= mtvec;
                    RWC <= 1'b1;
                end
                else if (MRET) begin
                    PCR <= mepc;
                    RWC <= 1'b0;
                end
            end
        end
    end

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
        else if(csr_w) begin
            case(csr_wsc)
                2'b01: CSR[rwaddr_map] = csr_wdata;
                2'b10: CSR[rwaddr_map] = CSR[rwaddr_map] | csr_wdata;
                2'b11: CSR[rwaddr_map] = CSR[rwaddr_map] & ~csr_wdata;
                default: CSR[rwaddr_map] = csr_wdata;
            endcase            
        end
        else if(ABN) begin
            if (MRET) begin
                CSR[0][3] <= CSR[0][7]; CSR[0][7] <= 1'b1; CM <= CSR[0][12:11]; CSR[0][12:11] <= 2'b11;
            end
            else if (INT) begin
                CSR[0][7] <= CSR[0][3]; CSR[0][3] <= 1'b0; CSR[0][12:11] <= CM; CM <= 2'b11;  // mstatus
                CSR[9]    <= epc_next;    // mepc
                CSR[10]   <= 32'h8000000B;    // mcause
            end
            else if (EXP) begin
                CSR[0][7] <= CSR[0][3]; CSR[0][3] <= 1'b0; CSR[0][12:11] <= CM; CM <= 2'b11;  // mstatus
                CSR[9]  <= epc_cur;     // mepc
                case(EXP) // ecall_m, s_access_fault, l_access_fault, illegal_inst
                    4'b0001: CSR[10] <= 32'h00000002;
                    4'b0010: CSR[10] <= 32'h00000005;
                    4'b0100: CSR[10] <= 32'h00000007;
                    4'b1000: CSR[10] <= 32'h0000000B;
                endcase
            end
        end
    end
endmodule