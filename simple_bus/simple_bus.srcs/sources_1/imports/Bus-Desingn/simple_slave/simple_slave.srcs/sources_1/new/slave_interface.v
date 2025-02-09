`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 10:22:51 PM
// Design Name: 
// Module Name: slave_interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module slave_interface #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 2
)(
    input clk,                 // Clock input
    input reset,               // Reset input
    input [DATA_WIDTH-1:0] data_in,       // Data input for writing to memory
    input [ADDR_WIDTH-1:0] addr,          // Address input (2-bit address for 4 locations)
    input slave_select,        // Slave select signal
    input wr_en,               // Write enable (1 = write, 0 = read)
    output [DATA_WIDTH-1:0] data_out,     // Data output for reading from memory
    output reg ack,            // Acknowledge signal
    output [ADDR_WIDTH-1:0] mem_addr,     // Address for memory module
    output mem_write_enable,   // Write enable for memory module
    output mem_read_enable,    // Read enable for memory module
    output [DATA_WIDTH-1:0] mem_write_data, // Write data to memory module
    input [DATA_WIDTH-1:0] mem_read_data,  // Data read from memory module
    input slack                // ack from slave(memomry module)
);

    // State encoding
    localparam IDLE    = 1'b0;
    localparam SERVING = 1'b1;

    // State register
    reg current_state, next_state;
    reg slack_reg;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Combinational logic for next state and outputs
    always @(*) begin
        // Default values
        ack = 0;
        next_state = current_state;

        case (current_state)
            IDLE: begin
                ack = 0;
                slack_reg = 0;
                // Wait for slave select to go high
                if (slave_select) begin
                    next_state = SERVING;
                end
            end

            SERVING: begin
                // Provide memory access signals
                if (wr_en) begin
                    // Write operation
                    ack = 1;
                    slack_reg = slack;
                end else begin
                    // Read operation
                    ack = 1;
                    slack_reg = slack;
                end
                // Go back to IDLE after operation
                next_state = IDLE;
            end
        endcase
    end

    // Connect memory control signals
    assign mem_addr = addr;
    assign mem_write_enable = wr_en && slave_select;
    assign mem_read_enable = !wr_en && slave_select;
    assign mem_write_data = data_in;
    assign data_out = mem_read_data;

endmodule

