module program_counter (
    input logic clk,
    input logic rst_n,
    input logic [31:0] next_pc,
    output logic [31:0] pc
);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            pc <= 32'd0;
        end else begin
            pc <= next_pc;
        end
    end

endmodule