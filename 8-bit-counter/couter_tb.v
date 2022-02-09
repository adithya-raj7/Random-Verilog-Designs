module test;

  reg reset = 0;
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test);

    # 17 reset = 1;
    # 11 reset = 0;
    # 90  reset = 0;
    # 100 $finish;
  end

  reg clk = 0;
  always #1 clk =!clk;

  wire [7:0] value;
  counter c1 (value, clk, reset);

  initial
    $monitor("At time %t, value =%h (%0d)", $time, value, value);

endmodule
