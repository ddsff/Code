module sfifo(
    input logic clk,rst_n,we,re,
    output logic full,empty,
    input logic [7:0] din,
    output logic [7:0] dout
);