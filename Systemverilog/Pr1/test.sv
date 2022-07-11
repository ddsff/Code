`timescale=1ns/1ns
module test();
logic clk,rst_n,we,re,full,empty;
logic [7:0] din,dout;
initial begin
    clk=0;
end
always #10  clk=~clk;
initial begin
    rst_n=0;
    #18 rst_n=1;
    