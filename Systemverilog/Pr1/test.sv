module test();
  logic clk,rst_n,we,re,full,empty;
  logic [7:0] din,dout;
  initial begin
    clk=0;
    rst_n=0;
    we=0;
    re=0;
    din=0;
    #28 rst_n=1'b1;
    we=1'b1;
    din=1;
    @(posedge clk);
    repeat(15) begin
      #18;
      din=din+1;
      @(posedge clk);
    end
  #18 din=din+1;
  @(posedge clk);
  #18 re=1;
  we=0;
  @(posedge clk);
  repeat(15) begin
  @(posedge clk);
end
#2 re=0;
    #4000 $finish;
  end
  always #10 clk=~clk;
  initial begin
    $fsdbDumpvars("+fsdbfile+test.fsdb");
    $fsdbDumpvars("+all");
  end
    sfifo inst(.clk(clk),.rst_n(rst_n),.we(we),.re(re),.full(full),.empty(empty),.din(din),.dout(dout));
  endmodule