module alu (
    input logic [4:0] alu_code,
    input logic [31:0] op1,
    input logic [31:0] op2,
    output logic [31:0] alu_result,
    output logic br_taken
);

    import cpu_pkg::*;

    always_comb begin
        unique case (alu_code)
            ALU_ADD: alu_result = op1 + op2;
            ALU_SUB: alu_result = op1 - op2;
            ALU_XOR: alu_result = op1 ^ op2;
            ALU_OR: alu_result = op1 | op2;
            ALU_AND: alu_result = op1 & op2;
            ALU_SLT: alu_result = (signed'(op1) < signed'(op2)) ? 32'd1 : 32'd0;
            ALU_SLTU: alu_result = (op1 < op2) ? 32'd1 : 32'd0;
            ALU_SLL: alu_result = op1 << op2[4:0];
            ALU_SRL: alu_result = op1 >> op2[4:0];
            ALU_SRA: alu_result = signed'(op1) >>> op2[4:0];
            ALU_LUI: alu_result = op2;
            ALU_JAL, ALU_JALR: alu_result = op1 + 32'd4;
            default: alu_result = 32'd0;
        endcase
    end

    always_comb begin
        unique case (alu_code)
            ALU_BEQ: br_taken = (op1 == op2);
            ALU_BNE: br_taken = (op1 != op2);
            ALU_BLT: br_taken = (signed'(op1) < signed'(op2));
            ALU_BGE: br_taken = (signed'(op1) >= signed'(op2));
            ALU_BLTU: br_taken = (op1 < op2);
            ALU_BGEU: br_taken = (op1 >= op2);
            ALU_JAL, ALU_JALR: br_taken = ENABLE;
            default: br_taken = DISABLE; 
        endcase
    end

endmodule