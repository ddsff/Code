module sfifo(
    input logic clk,rst_n,we,re,
    output logic full,empty,
    input logic [7:0] din,
    output logic [7:0] dout
);
logic [7:0] ram[0:15];
logic [3:0] wptr;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        {full,empty}<=2'b01;
        wptr<=4'b0000;
    end
    else if((wptr==15)&&(full==1)&&we)begin
        full<=1;
    end
    else if((wptr==15)&&(full)&&we)begin
        full<=1;
        ram[wptr]<=din;
    end
    else if((wptr!=15)&&we)begin
        ram[wptr]<=din;
        wptr++;
    end
    else if((wptr!=0)&&re)begin
        ram<={ram[1:15],1'bz};
        wptr--;
    end
    else if((wptr==0)&&re)begin
        empty<=1;
    end
end
always@(posedge clk)begin
    if(we)
        empty<=0;
    if(re)
        full<=0;
end
always@(posedge clk)begin
    if(!rst_n)
        dout<=8'bzzzzzzzz;
    else
        dout<=ram[wptr];
end
endmodule