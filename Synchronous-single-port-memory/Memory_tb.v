// Code your testbench here
// or browse Examples
module test;

  reg reset = 0;
  reg [15:0] wr_data = 16'hFFFF;
  reg [3:0] addr = 4'h0;
  reg en = 0;
  reg out_wr_data_en =1 ;
  reg rd_wr;

  reg err_clr = 0;
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test);

    # 17 reset = 0;
    # 11 reset = 1;
    # 1
    # 1 en = 1;
    # 1 rd_wr =1;
    # 3 en = 0;
    # 1 addr=4'h1;wr_data=16'h70ad;
    # 1  en   =1;
    # 3  en = 0;
    # 1  addr = 4'h3;wr_data =16'hABCD;
    # 1  en=1;
    # 3  en =0;
    # 1  addr = 4'h2;wr_data =16'hAB09;
    # 1  en =1;
    # 3  en =0;
    # 1  addr = 4'h4;wr_data =16'h010d;
    # 1  en =1;
    # 3  en =0;
    # 1  addr = 4'h7;wr_data =16'hAB0D;
    # 1  en =1;
    # 3  en =0;
    # 1  addr = 4'hC;wr_data =16'h2375;
    # 1  en =1;
    # 3  en =0;
    # 1  addr = 4'hA;wr_data =16'hAAAA;
    # 1  en =1;
    # 3  en =0;
    # 5  rd_wr=0;
    # 5  addr=4'h0;
    # 10 en=1;
    # 3  en=0;
    # 10 addr=4'hC;
    # 10 en =1;
    # 3 en=0;
    # 10 addr=4'hA;
    # 10 en =1;
    # 3 en=0;
    # 10 addr=4'h1;
    # 10 en =1;
    # 3 en=0;
    # 10 addr=4'h2;
    # 10 en =1;
    # 3 en=0;
    # 10 addr=4'h3;
    # 10 en =1;
    # 3 en=0;
    # 10 addr=4'h7;
    # 10 en =1;
    # 3 en=0;
    # 10 addr=4'h4;
    # 10 en =1;
    # 3 en=0;
    # 50  reset = 0;
    # 100 $finish;
  end

  reg clk = 0;
  always #1 clk =!clk;

  wire [15:0] out_wr_data;
  wire [15:0] rd_data;
  wire error;

  single_port_memory Mem
  (.out_wr_data(out_wr_data),
   .clk(clk),
   .reset(reset),
   .en(en),
   .addr(addr),
   .wr_data(wr_data),
   .rd_wr(rd_wr),
   .rd_data(rd_data),
   .out_wr_data_en(out_wr_data_en),
   .err_clr(err_clr),
   .error(error)
  );

  initial
    $monitor("At time %t, wr_data =%h (%0d), rd_data =%h (%0d) ", $time, out_wr_data, out_wr_data,rd_data,rd_data);

endmodule
