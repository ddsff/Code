module sfifo(
  input logic rst_n,clk,we,re,
  output logic full,empty,
  input logic[7:0] din,
  output logic [7:0] dout
);
logic [3:0] wptr,rptr;
logic [4:0] cnt;
logic [7:0] ram[0:15];

always@(posedge clk or negedge rst_n)begin
  if(!rst_n)
    rptr<=0;
  else if((!empty)&re)
    rptr<=rptr+1;
end
always@(posedge clk or negedge rst_n)begin
  if(!rst_n)
    dout<=8'bzzzzzzzz;
  else if((!empty)&re)
    dout<=ram[rptr];
  else
    dout<=8'bzzzzzzz;
end
always@(posedge clk or negedge rst_n)begin
  if(!rst_n)
    wptr<=0;
  else if((!full)&we)
    wptr<=wptr+1;
end
always@(posedge clk)begin
  if((!full)&we)
    ram[wptr]<=din;
end
always@(posedge clk or negedge rst_n)begin
  if(!rst_n)
    cnt<=0;
  else if((we)&(!re)&(!full))
    cnt<=cnt+1;
  else if((re)&(!we)&(!empty))
    cnt<=cnt-1;
end
assign full=(cnt==16)?1:0;
assign empty=(cnt==0)?1:0;
endmodule
