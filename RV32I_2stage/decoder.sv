module decoder (
    input logic [31:0] insn,
    output logic [31:0] imm,
    output logic [4:0] alu_code,
    output logic alu_op1_sel,
    output logic alu_op2_sel,
    output logic reg_we,
    output logic [2:0] is_load,
    output logic [1:0] is_store
);

    import cpu_pkg::*;

    logic [6:0] op_code;
    logic [2:0] funct3;

    assign op_code = insn[6:0];
    assign funct3 = insn[14:12];

    // imm
    always_comb begin
        unique case (op_code)
            OPIMM, LOAD, JALR: imm = {{20{insn[31]}}, insn[31:20]};
            LUI, AUIPC: imm = {insn[31:12], 12'd0};
            STORE: imm = {{20{insn[31]}}, insn[31:25], insn[11:7]};
            BRANCH: imm = {{19{insn[31]}}, insn[31], insn[7], insn[30:25], insn[11:8], 1'd0};
            JAL: imm = {{11{insn[31]}}, insn[31], insn[19:12], insn[20], insn[30:21], 1'd0};
            default: imm = 32'd0;
        endcase
    end

    // alu_code
    always_comb begin
        unique case (op_code)
            OPREG: begin
                unique case (funct3)
                    3'b000: alu_code = (insn[30] == 1'b1) ? ALU_SUB : ALU_ADD;
                    3'b001: alu_code = ALU_SLL;
                    3'b010: alu_code = ALU_SLT;
                    3'b011: alu_code = ALU_SLTU;
                    3'b100: alu_code = ALU_XOR;
                    3'b101: alu_code = (insn[30] == 1'b1) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_code = ALU_OR;
                    3'b111: alu_code = ALU_AND;
                    default: alu_code = ALU_ADD;
                endcase
            end
            OPIMM: begin
                unique case (funct3)
                    3'b000: alu_code = ALU_ADD;
                    3'b001: alu_code = ALU_SLL;
                    3'b010: alu_code = ALU_SLT;
                    3'b011: alu_code = ALU_SLTU;
                    3'b100: alu_code = ALU_XOR;
                    3'b101: alu_code = (insn[30] == 1'b1) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_code = ALU_OR;
                    3'b111: alu_code = ALU_AND;
                    default: alu_code = ALU_ADD;
                endcase
            end
            LUI: alu_code = ALU_LUI;
            AUIPC: alu_code = ALU_ADD;
            BRANCH: begin
                unique case (funct3)
                    3'b000: alu_code = ALU_BEQ;
                    3'b001: alu_code = ALU_BNE;
                    3'b100: alu_code = ALU_BLT;
                    3'b101: alu_code = ALU_BGE;
                    3'b110: alu_code = ALU_BLTU;
                    3'b111: alu_code = ALU_BGEU;
                    default: alu_code = ALU_ADD;
                endcase
            end
            JAL: alu_code = ALU_JAL;
            JALR: alu_code = ALU_JALR;
            default: alu_code = ALU_ADD;
        endcase
    end

    // alu_op_sel
    always_comb begin
        unique case (op_code)
            OPIMM, LUI, LOAD, STORE: begin
                alu_op1_sel = ALU_OP1_RS1;
                alu_op2_sel = ALU_OP2_IMM;
            end
            OPREG, BRANCH: begin
                alu_op1_sel = ALU_OP1_RS1;
                alu_op2_sel = ALU_OP2_RS2;
            end
            AUIPC, JAL, JALR: begin
                alu_op1_sel = ALU_OP1_PC;
                alu_op2_sel = ALU_OP2_IMM;
            end
            default: begin
                alu_op1_sel = ALU_OP1_RS1;
                alu_op2_sel = ALU_OP2_RS2;
            end
        endcase
    end

    // reg_we
    always_comb begin
        unique case (op_code)
            OPIMM, OPREG, LUI, AUIPC, LOAD, JAL, JALR: reg_we = ENABLE;
            default: reg_we = DISABLE;
        endcase
        if (insn[11:7] == 5'd0) begin
            reg_we = DISABLE;
        end
    end

    // is_load
    always_comb begin
        unique case (op_code)
            LOAD: begin
                unique case (funct3)
                    3'b000: is_load = LOAD_LB;
                    3'b001: is_load = LOAD_LH;
                    3'b010: is_load = LOAD_LW;
                    3'b100: is_load = LOAD_LBU;
                    3'b101: is_load = LOAD_LHU;
                    default: is_load = LOAD_DISABLE;
                endcase
            end
            default: is_load = LOAD_DISABLE;
        endcase
    end

    // is_store
    always_comb begin
        unique case (op_code)
            STORE: begin
                unique case (funct3)
                    3'b000: is_store = STORE_SB;
                    3'b001: is_store = STORE_SH;
                    3'b010: is_store = STORE_SW;
                    default: is_store = STORE_DISABLE;
                endcase
            end
            default: is_store = STORE_DISABLE;
        endcase
    end

endmodule