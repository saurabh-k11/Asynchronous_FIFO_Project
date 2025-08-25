module Asynchronous_FIFO #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4  // FIFO depth = 2^ADDR_WIDTH
)(
    input wire wr_clk,
    input wire rd_clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout,
    output wire full,
    output wire empty
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    // FIFO memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Binary and Gray pointers
    reg [ADDR_WIDTH:0] wr_ptr_bin, wr_ptr_gray;
    reg [ADDR_WIDTH:0] rd_ptr_bin, rd_ptr_gray;

    // -------------------------
    // Reset Synchronizers
    // -------------------------
    (* ASYNC_REG = "TRUE", KEEP = "TRUE" *) reg rst_wr_sync1, rst_wr_sync2;
    (* ASYNC_REG = "TRUE", KEEP = "TRUE" *) reg rst_rd_sync1, rst_rd_sync2;

    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            rst_wr_sync1 <= 1'b1;
            rst_wr_sync2 <= 1'b1;
        end else begin
            rst_wr_sync1 <= 1'b0;
            rst_wr_sync2 <= rst_wr_sync1;
        end
    end

    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rst_rd_sync1 <= 1'b1;
            rst_rd_sync2 <= 1'b1;
        end else begin
            rst_rd_sync1 <= 1'b0;
            rst_rd_sync2 <= rst_rd_sync1;
        end
    end

    wire rst_wr = rst_wr_sync2;
    wire rst_rd = rst_rd_sync2;

    // -------------------------
    // Pointer Synchronizers
    // -------------------------
    // Read pointer synced into write clock domain
    (* ASYNC_REG = "TRUE", KEEP = "TRUE" *) reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;

    always @(posedge wr_clk or posedge rst_wr) begin
        if (rst_wr) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    // Write pointer synced into read clock domain
    (* ASYNC_REG = "TRUE", KEEP = "TRUE" *) reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;

    always @(posedge rd_clk or posedge rst_rd) begin
        if (rst_rd) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

    // -------------------------
    // Write Logic
    // -------------------------
    always @(posedge wr_clk) begin
        if (rst_wr) begin
            wr_ptr_bin <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= din;
            wr_ptr_bin <= wr_ptr_bin + 1;
            wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1);
        end
    end

    // -------------------------
    // Read Logic
    // -------------------------
    always @(posedge rd_clk) begin
        if (rst_rd) begin
            rd_ptr_bin <= 0;
            rd_ptr_gray <= 0;
            dout <= 0;
        end else if (rd_en && !empty) begin
            dout <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
            rd_ptr_bin <= rd_ptr_bin + 1;
            rd_ptr_gray <= (rd_ptr_bin + 1) ^ ((rd_ptr_bin + 1) >> 1);
        end
    end

    // -------------------------
    // Status Flags
    // -------------------------
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);
    assign full = (wr_ptr_gray == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],
                                   rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});

endmodule
