//module declaration
module single_port_memory(
  clk,
  reset,
  en,
  addr,
  wr_data,
  rd_wr,
  rd_data,
  out_wr_data,
  out_wr_data_en,
  error,
  err_clr
);

  //parameters
  localparam        DEPTH                = 16;
  localparam        ADDR_WIDTH           = 4;
  localparam        DATA_WIDTH           = 16;
  localparam [1:0]  IDLE                 = 2'b00;
  localparam [1:0]  WRITE_TRANS          = 2'b01;
  localparam [1:0]  READ_TRANS           = 2'b10;
  localparam [1:0]  ERROR                = 2'b11;

  //inputs
  input                     clk;                           //synchrounous clk
  input                     reset;                         //reset
  input                     en;                            //enable signal
  input                     rd_wr;                         //Read or write control signal
  input                     err_clr;                       //Clear signal without reset
  input                     out_wr_data_en;                //loopback enable signal for write data
  input [ADDR_WIDTH-1 : 0]  addr;                          //Address
  input [DATA_WIDTH-1 : 0]  wr_data;                       //write data

  //outputs
  output error;                                            //Out of bounds error signal
  output [DATA_WIDTH-1 : 0] out_wr_data;                   //looped back write data
  output [DATA_WIDTH-1 : 0] rd_data;                       //Read data

  //regs and wires
  integer i;

  reg error;
  reg [DATA_WIDTH-1 : 0]    out_wr_data;
  reg [DATA_WIDTH-1 : 0]    rd_data;
  reg [DATA_WIDTH-1 : 0]    memory [0 : DEPTH-1];          //Memory arrray declaration
  reg [1:0]                 state;
  reg [1:0]                 nxt_state;
  reg                       nxt_error;
  reg [15 : 0]              nxt_out_wr_data;
  reg [15 : 0]              nxt_rd_data;
  reg [15 : 0]              nxt_memory[0 : 15];


  wire [DATA_WIDTH-1 : 0]   wr_data;
  wire [ADDR_WIDTH-1 : 0]   addr;
  wire                      out_wr_data_en;
  wire                      rd_wr;
  wire                      clk,reset,en,err_clr;

//combinational logic

  always @(*)
  begin

//default flop statements
    nxt_error                            = error;
    nxt_rd_data                          = rd_data;
    nxt_out_wr_data                      = out_wr_data;
    nxt_state                            = state;

    for(i =0; i< DEPTH; i=i+1)
    begin
      nxt_memory[i]                      = memory[i];
    end

//State Machine
    case (state)
      IDLE:
      begin
        if(addr>DEPTH)                                     //checking for out of bounds error
        begin
          nxt_error                      = 1;
          nxt_state                      = ERROR;
        end

        if(en&rd_wr)
        begin
          nxt_state                      = WRITE_TRANS;
        end


        if(en&!rd_wr)
        begin
          nxt_state                      = READ_TRANS;
        end
      end

      WRITE_TRANS :
      begin
        nxt_memory[addr]                 = wr_data [DATA_WIDTH-1 : 0];

        if (out_wr_data_en)
        begin
          nxt_out_wr_data                = wr_data [DATA_WIDTH-1 : 0];
        end

        nxt_state                        = IDLE;
      end

      READ_TRANS :
      begin
        nxt_rd_data                      = memory[addr] ;
        nxt_state                        = IDLE ;
      end

      ERROR   :
      begin
        if(err_clr)                                         // Clear without reset
        begin
          nxt_state                      = IDLE;
        end
      end
    endcase
  end

//Sequential Logic

  always @(posedge clk, negedge reset)
  begin
    if (!reset)                                             // Active low Reset
    begin
      out_wr_data                        <= 16'b0;
      state                              <= 2'b0;
      rd_data                            <= 16'b0;
      error                              <= 1'b0;

      for(i =0;i<DEPTH;i=i+1)
      begin
        memory[i]                        <=16'b0;
      end
    end
    else
    begin
      out_wr_data                        <= nxt_out_wr_data;
      state                              <= nxt_state;
      rd_data                            <= nxt_rd_data;
      error                              <= nxt_error;

      for(i =0;i<DEPTH;i=i+1)
      begin
        memory[i]                        <=nxt_memory[i];
      end
    end
  end
endmodule
 
