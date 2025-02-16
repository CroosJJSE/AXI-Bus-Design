`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024
// Design Name: 
// Module Name: slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Slave module with split and master handling
// 
// Dependencies: memory, slave_interface
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ss_slave (
    input clk,                 // Clock input
    input reset,               // Reset input
    input [7:0] data_in,       // Data input for writing to memory
    input [13:0] addr,          // Address input (2-bit address for 4 locations)
    input slave_select,        // Slave select signal
    input wr_en,               // Write enable (1 = write, 0 = read)
    input [1:0] active_master, // Active master signal (2-bit)
    output [7:0] data_out,     // Data output for reading from memory
    output ack,                // Acknowledge signal
    output [1:0] req_split_master, // Request split for the master
    output split               // Split signal to handle transactions
);

    // Internal signals
    wire [7:0] mem_write_data;    // Data to be written to memory
    wire [7:0] mem_read_data;     // Data read from memory
    wire [13:0] mem_addr;          // Address for memory module
    wire mem_write_enable;        // Write enable for memory module
    wire mem_read_enable;         // Read enable for memory module
    wire slack;                   // Acknowledge from slave (memory)
    wire wait_signal;                    // wait signal from slave
    
    // Instantiate the memory module
    ss_memory mem_inst (
        .clk(clk),
        .reset(reset),
        .addr(mem_addr),
        .write_data(mem_write_data),
        .read_data(mem_read_data),
        .write_enable(mem_write_enable),
        .read_enable(mem_read_enable),
        .ack(slack),
        .wait_signal(wait_signal)
    );

    // Instantiate the slave interface module
    ss_slave_interface slave_if_inst (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .addr(addr),
        .slave_select(slave_select),
        .wr_en(wr_en),
        .data_out(data_out),
        .ack(ack),
        .mem_addr(mem_addr),
        .mem_write_enable(mem_write_enable),
        .mem_read_enable(mem_read_enable),
        .mem_write_data(mem_write_data),
        .mem_read_data(mem_read_data),
        .wait_signal(wait_signal),
        .slack(slack),
        .req_split_master(req_split_master),  // Connect the request for the split master
        .split(split),                        // Connect the split signal
        .master(active_master)                // Connect the active master input
    );

endmodule
