module imem (
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] wr_data,
    input logic wr_en,
    output logic [31:0] rd_data
);

    logic [31:0] mem [0:255];
    logic [30:0] addr_sync;

    // store
    always_ff @(posedge clk) begin
        if (wr_en) mem[addr[31:2]] <= wr_data;
    end

    // load    
    always_ff @(posedge clk) begin
        addr_sync <= addr[31:2];
    end
    
    assign rd_data = mem[addr_sync];

endmodule
