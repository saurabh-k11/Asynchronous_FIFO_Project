module async_fifo_tb;
 parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4; // FIFO depth = 16

    reg wr_clk, rd_clk, rst;
    reg wr_en, rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full, empty;

    // Instantiate the FIFO
    Asynchronous_FIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk; // 100 MHz
    end

    initial begin
        rd_clk = 0;
        forever #7 rd_clk = ~rd_clk; // Asynchronous
    end

    // Stimulus
    initial begin
        // Initialize
        rst = 1; wr_en = 0; rd_en = 0; din = 8'h00;
        #20 rst = 0;

        // Write continuously until full
        @(negedge wr_clk);
        wr_en = 1;
        repeat (20) begin  // Try to write more than 16 to hit full
            @(posedge wr_clk);
            if (!full) begin
                din = din + 1;
            end else begin
                wr_en = 0; // Stop writing if full
                $display("FIFO FULL at time = %0t", $time);
            end
        end

        // Hold for observation
        #100;

        $finish;
    end

endmodule
