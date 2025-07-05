module dmem (
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] wr_data,
    input logic [2:0] is_load,
    input logic [1:0] is_store,
    output logic [31:0] rd_data
);

    logic [31:0] mem [0:255];
    logic [3:0] wr_en;
    logic [31:0] wr_data_aligned;

    // store
    always_comb begin
        unique case (is_store)
            2'b00: wr_en = 4'b0000;
            2'b01: begin
                unique case (addr[1:0])
                    2'b00: wr_en = 4'b0001;
                    2'b01: wr_en = 4'b0010;
                    2'b10: wr_en = 4'b0100;
                    2'b11: wr_en = 4'b1000;
                endcase
            end
            2'b10: begin
                unique case (addr[1:0])
                    2'b00: wr_en = 4'b0011;
                    2'b01: wr_en = 4'b0110;
                    2'b10: wr_en = 4'b1100;
                    default: wr_en = 4'b0000;
                endcase
            end
            2'b11: wr_en = 4'b1111;
        endcase
    end

    always_comb begin
        unique case (addr[1:0])
            2'b00: wr_data_aligned = wr_data;                      
            2'b01: wr_data_aligned = {wr_data[23:0], 8'd0};
            2'b10: wr_data_aligned = {wr_data[15:0], 16'd0};
            2'b11: wr_data_aligned = {wr_data[7:0], 24'd0};
        endcase
    end

    always_ff @(posedge clk) begin
        if (wr_en[0]) mem[addr[31:2]][7:0] <= wr_data_aligned[7:0];
        if (wr_en[1]) mem[addr[31:2]][15:8] <= wr_data_aligned[15:8];
        if (wr_en[2]) mem[addr[31:2]][23:16] <= wr_data_aligned[23:16];
        if (wr_en[3]) mem[addr[31:2]][31:24] <= wr_data_aligned[31:24];
    end

    // load
    always_comb begin
        unique case (is_load)
            3'b000: rd_data = 32'd0;
            3'b001: begin
                unique case (addr[1:0])
                    2'b00: rd_data = {{24{mem[addr[31:2]][7]}}, mem[addr[31:2]][7:0]};
                    2'b01: rd_data = {{24{mem[addr[31:2]][15]}}, mem[addr[31:2]][15:8]};
                    2'b10: rd_data = {{24{mem[addr[31:2]][23]}}, mem[addr[31:2]][23:16]};
                    2'b11: rd_data = {{24{mem[addr[31:2]][31]}}, mem[addr[31:2]][31:24]};
                endcase
            end
            3'b010: begin
                unique case (addr[1:0])
                    2'b00: rd_data = {{16{mem[addr[31:2]][15]}}, mem[addr[31:2]][15:0]};
                    2'b01: rd_data = {{16{mem[addr[31:2]][23]}}, mem[addr[31:2]][23:8]};
                    2'b10: rd_data = {{16{mem[addr[31:2]][31]}}, mem[addr[31:2]][31:16]};
                    default: rd_data = 32'd0;
                endcase
            end
            3'b011: rd_data = mem[addr[31:2]];
            3'b101: begin
                unique case (addr[1:0])
                    2'b00: rd_data = {24'd0, mem[addr[31:2]][7:0]};
                    2'b01: rd_data = {24'd0, mem[addr[31:2]][15:8]};
                    2'b10: rd_data = {24'd0, mem[addr[31:2]][23:16]};
                    2'b11: rd_data = {24'd0, mem[addr[31:2]][31:24]};
                endcase
            end
            3'b110: begin
                unique case (addr[1:0])
                    2'b00: rd_data = {16'd0, mem[addr[31:2]][15:0]};
                    2'b01: rd_data = {16'd0, mem[addr[31:2]][23:8]};
                    2'b10: rd_data = {16'd0, mem[addr[31:2]][31:16]};
                    default: rd_data = 32'd0;
                endcase
            end
            default: rd_data = 32'd0;
        endcase
    end

endmodule