//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 10/01/2024 09:44:42 PM
//// Design Name: 
//// Module Name: dual_clock_fifo
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////

//module dual_clock_fifo #(
//    parameter DATA_WIDTH = 8,   // Data width
//    parameter DEPTH = 4         // Depth of FIFO
//)(
//    input wire wr_clk,           // Write clock
//    input wire wr_en,            // Write enable
//    input wire reset,            // Reset signal for both clock domains
//    input wire [DATA_WIDTH-1:0] wr_data, // Data input
    
//    input wire rd_clk,           // Read clock
//    input wire rd_en,            // Read enable
//    output reg [DATA_WIDTH-1:0] rd_data, // Data output
    
//    output reg full,            // FIFO full flag
//    output reg empty            // FIFO empty flag
//);

//    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];  // FIFO memory array
//    reg [$clog2(DEPTH):0] wr_ptr = 0, rd_ptr = 0;           // Write and read pointers
//    reg [$clog2(DEPTH):0] wr_ptr_sync = 0, rd_ptr_sync = 0;

//    // Write operation (in the write clock domain)
//    always @(posedge wr_clk or posedge reset) begin
//        if (reset) begin
//            wr_ptr <= 0;
//            wr_ptr_sync <= 0;
//            rd_ptr <= 0;
//            rd_ptr_sync <= 0;
//            full <= 0;
//            empty <= 1;
//        end else if (wr_en && !full) begin
//            fifo_mem[wr_ptr] <= wr_data;
//            wr_ptr <= wr_ptr + 1;
//            if(empty) begin
//                empty = 0;
//            end
//            if( {~wr_ptr[$clog2(DEPTH)],wr_ptr[$clog2(DEPTH)-1:0]} == rd_ptr) begin
//                full <= 1;
//            end else begin
//                full <= 0;
//            end
            
//        end
//    end

//    // Read operation (in the read clock domain)
//    always @(posedge rd_clk or posedge reset) begin
//        if (reset) begin
//            wr_ptr <= 0;
//            wr_ptr_sync <= 0;
//            rd_ptr <= 0;
//            rd_ptr_sync <= 0;
//            full <= 0;
//            empty <= 1;
//        end else if (rd_en && !empty) begin
//            rd_data <= fifo_mem[rd_ptr];
//            rd_ptr = rd_ptr+1;
//            if(full) begin
//                full = 0;
//            end
//            if (wr_ptr == rd_ptr) begin
//                empty = 1;
//            end else begin
//                empty = 0;
//            end
//        end
//    end

//    // Synchronize pointers across clock domains
//    always @(posedge wr_clk or posedge reset) begin
//        if (reset) begin
//            rd_ptr_sync <= 0;
//        end else begin
//            rd_ptr_sync <= rd_ptr;
//        end
//    end

//    always @(posedge rd_clk or posedge reset) begin
//        if (reset) begin
//            wr_ptr_sync <= 0;
//        end else begin
//            wr_ptr_sync <= wr_ptr;
//        end
//    end

//endmodule


module dual_clock_fifo #(
    parameter DATA_WIDTH = 8,   // Width of data
    parameter ADDR_WIDTH = 4    // Depth = 2^ADDR_WIDTH
)(
    input   wire wr_clk,       // Write clock
    input   wire rd_clk,       // Read clock
    input   wire reset,        // Active-low reset
    input   wire wr_en,        // Write enable
    input   wire rd_en,        // Read enable
    input   wire [DATA_WIDTH-1:0] wr_data, // Input write data
    output  reg  [DATA_WIDTH-1:0] rd_data, // Output read data
    output  wire full,          // FIFO full flag
    output  wire empty          // FIFO empty flag
);

    localparam DEPTH = 2**ADDR_WIDTH;

    // FIFO Memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Read & Write Pointers (Binary)
    reg [ADDR_WIDTH:0] wr_ptr_bin, rd_ptr_bin;
    reg [ADDR_WIDTH:0] wr_ptr_gray, rd_ptr_gray;
    
    reg [ADDR_WIDTH:0] wr_ptr_bin_next, rd_ptr_bin_next;
    reg [ADDR_WIDTH:0] wr_ptr_gray_next, rd_ptr_gray_next;

    // Synchronized Read Pointer in Write Clock Domain
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
    always @(posedge wr_clk or negedge reset) begin
        if (!reset) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    // Synchronized Write Pointer in Read Clock Domain
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;
    always @(posedge rd_clk or negedge reset) begin
        if (!reset) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

    // Convert Gray to Binary for comparison
    function [ADDR_WIDTH:0] gray_to_bin(input [ADDR_WIDTH:0] gray);
        integer i;
        reg [ADDR_WIDTH:0] bin;
        begin
            bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
            for (i = ADDR_WIDTH-1; i >= 0; i = i - 1) begin
                bin[i] = bin[i+1] ^ gray[i];
            end
            gray_to_bin = bin;
        end
    endfunction

    // Compute Full and Empty Flags
    assign full  = (wr_ptr_gray == {~rd_ptr_gray_sync2[ADDR_WIDTH], rd_ptr_gray_sync2[ADDR_WIDTH-1:0]});
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);

    // Compute Next Write/Read Pointers inside always block
    always @(*) begin
        wr_ptr_bin_next = wr_ptr_bin + (wr_en && !full);
        rd_ptr_bin_next = rd_ptr_bin + (rd_en && !empty);

        // Convert Binary to Gray
        wr_ptr_gray_next = (wr_ptr_bin_next >> 1) ^ wr_ptr_bin_next;
        rd_ptr_gray_next = (rd_ptr_bin_next >> 1) ^ rd_ptr_bin_next;
    end

    // Write Logic
    always @(posedge wr_clk or negedge reset) begin
        if (!reset) begin
            wr_ptr_bin <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr_bin <= wr_ptr_bin_next;
            wr_ptr_gray <= wr_ptr_gray_next;
        end
    end

    // Read Logic
    always @(posedge rd_clk or negedge reset) begin
        if (!reset) begin
            rd_ptr_bin <= 0;
            rd_ptr_gray <= 0;
            rd_data <= 0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
            rd_ptr_bin <= rd_ptr_bin_next;
            rd_ptr_gray <= rd_ptr_gray_next;
        end
    end

endmodule
