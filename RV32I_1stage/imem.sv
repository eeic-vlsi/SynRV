module imem (
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] wr_data,
    input logic wr_en,
    output logic [31:0] rd_data
);

    logic [31:0] mem [0:255];

    // store
    always_ff @(posedge clk) begin
        if (wr_en) mem[addr[31:2]] <= wr_data;
    end

    // load
    assign rd_data = mem[addr[31:2]];

endmodule