module cpu_top (
    input logic clk,
    input logic rst_n,
    input logic [31:0] imem_wr_data,
    input logic imem_wr_en,
    output logic [31:0] debug_rd_value
);

    import cpu_pkg::*;

    logic [31:0] next_pc;
    logic [31:0] pc;
    logic [31:0] insn;
    logic [31:0] imm;
    alu_code_t alu_code;
    logic alu_op1_sel;
    logic alu_op2_sel;
    logic reg_we;
    logic [2:0] is_load;
    logic [1:0] is_store;
    logic [31:0] rd_value;
    logic [31:0] rs1_value;
    logic [31:0] rs2_value;
    logic [31:0] alu_op1;
    logic [31:0] alu_op2;
    logic [31:0] alu_result;
    logic br_taken;
    logic [31:0] br_addr;
    logic [31:0] dmem_rd_data;

    assign next_pc = br_taken ? br_addr : pc + 32'd4;

    program_counter pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(next_pc),
        .pc(pc)
    );

    imem imem_inst (
        .clk(clk),
        .addr(pc),
        .wr_data(imem_wr_data),
        .wr_en(imem_wr_en),
        .rd_data(insn)
    );

    decoder decoder_inst (
        .insn(insn),
        .imm(imm),
        .alu_code(alu_code),
        .alu_op1_sel(alu_op1_sel),
        .alu_op2_sel(alu_op2_sel),
        .reg_we(reg_we),
        .is_load(is_load),
        .is_store(is_store)
    );

    regfile regfile_inst (
        .clk(clk),
        .reg_we(reg_we),
        .rs1(insn[19:15]),
        .rs2(insn[24:20]),
        .rd(insn[11:7]),
        .rd_value(rd_value),
        .rs1_value(rs1_value),
        .rs2_value(rs2_value)
    );

    assign alu_op1 = alu_op1_sel ? pc : rs1_value;
    assign alu_op2 = alu_op2_sel ? imm : rs2_value;

    alu alu_inst (
        .alu_code(alu_code),
        .op1(alu_op1),
        .op2(alu_op2),
        .alu_result(alu_result),
        .br_taken(br_taken)
    );

    assign br_addr = (alu_code == ALU_JALR) ? rs1_value + imm : pc + imm;

    dmem dmem_inst (
        .clk(clk),
        .addr(dmem_addr),
        .wr_data(rs2_value),
        .is_load(is_load),
        .is_store(is_store),
        .rd_data(dmem_rd_data)
    );

    assign rd_value = (is_load != LOAD_DISABLE) ? dmem_rd_data : alu_result;

    // debug
    assign debug_rd_value = rd_value;

endmodule