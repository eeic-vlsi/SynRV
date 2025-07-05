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
    logic [31:0] imem_addr;
    logic [31:0] insn;
    logic [31:0] imm;
    alu_code_t alu_code;
    logic alu_op1_sel;
    logic alu_op2_sel;
    logic reg_we;
    logic [2:0] is_load;
    logic [1:0] is_store;
    logic [4:0] rd_num;
    logic [31:0] rd_value;
    logic [31:0] rs1_value;
    logic [31:0] rs2_value;
    logic [31:0] alu_op1;
    logic [31:0] alu_op2;
    logic [31:0] alu_result;
    logic br_taken;
    logic [31:0] br_addr;
    logic [31:0] dmem_rd_data;
    
    logic [31:0] ex_pc;
    logic [31:0] rs1_value_fwd;    
    logic [31:0] rs2_value_fwd;
    
    logic wb_reg_we;
    logic [2:0] wb_is_load;
    logic [31:0] wb_alu_result;

    assign next_pc = br_taken ? br_addr + 32'd4 : pc + 32'd4;

    program_counter pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(next_pc),
        .pc(pc)
    );
    
    assign imem_addr = br_taken ? br_addr : pc;

    imem imem_inst (
        .clk(clk),
        .addr(imem_addr),
        .wr_data(imem_wr_data),
        .wr_en(imem_wr_en),
        .rd_data(insn)
    );
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            ex_pc <= 32'd0;
        end else begin
            ex_pc <= imem_addr;
        end
    end

    // ================ EX stage =================

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
        .reg_we(wb_reg_we),
        .rs1(insn[19:15]),
        .rs2(insn[24:20]),
        .rd(rd_num),
        .rd_value(rd_value),
        .rs1_value(rs1_value),
        .rs2_value(rs2_value)
    );
    
    assign rs1_value_fwd = (wb_reg_we && (rd_num == insn[19:15])) ? rd_value : rs1_value;
    assign rs2_value_fwd = (wb_reg_we && (rd_num == insn[24:20])) ? rd_value : rs2_value;

    assign alu_op1 = alu_op1_sel ? ex_pc : rs1_value_fwd;
    assign alu_op2 = alu_op2_sel ? imm : rs2_value_fwd;

    alu alu_inst (
        .alu_code(alu_code),
        .op1(alu_op1),
        .op2(alu_op2),
        .alu_result(alu_result),
        .br_taken(br_taken)
    );

    assign br_addr = (alu_code == ALU_JALR) ? rs1_value_fwd + imm : ex_pc + imm;

    // ================ EX/WB pipeline registers =================

    dmem dmem_inst (
        .clk(clk),
        .addr(alu_result),
        .wr_data(rs2_value_fwd),
        .is_load(is_load),
        .is_store(is_store),
        .rd_data(dmem_rd_data)
    );
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wb_reg_we <= DISABLE;
            rd_num <= 5'd0;
            wb_is_load <= LOAD_DISABLE;
            wb_alu_result <= 32'd0;
        end else begin
            wb_reg_we <= reg_we;
            rd_num <= insn[11:7];
            wb_is_load <= is_load;
            wb_alu_result <= alu_result;
        end
    end

    // ================ WB stage =================

    assign rd_value = (wb_is_load != LOAD_DISABLE) ? dmem_rd_data : wb_alu_result;

    // debug
    assign debug_rd_value = rd_value;

endmodule