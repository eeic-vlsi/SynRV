module regfile (
    input logic clk,
    input logic reg_we,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] rd_value,
    output logic [31:0] rs1_value,
    output logic [31:0] rs2_value
);

    logic [31:0] regfile [1:31];

    always_ff @(posedge clk) begin
        if (reg_we) regfile[rd] <= rd_value;
    end

    assign rs1_value = (rs1 == 5'd0) ? 32'd0 : regfile[rs1];
    assign rs2_value = (rs2 == 5'd0) ? 32'd0 : regfile[rs2];

endmodule