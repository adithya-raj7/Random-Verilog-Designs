//module declaration
module logic_gate_mux(
  clk,
  reset,
  en,
  gate_type,
  no_of_inp,
  op1,
  op2,
  op3,
  op4,
  op_ack_in_pulse,
  final_inp_ack,
  out,
  op_ack_out,
  time_lim_err,
  inp_num_err,
  err_clr
);

//Parameter decleratiom

  localparam [3:0] IDLE          = 4'b0000;
  localparam [3:0] GATE_SELECT   = 4'b0001;
  localparam [3:0] AND           = 4'b0010;
  localparam [3:0] OR            = 4'b0011;
  localparam [3:0] NOT           = 4'b0100;
  localparam [3:0] NAND          = 4'b0101;
  localparam [3:0] NOR           = 4'b0110;
  localparam [3:0] XOR           = 4'b0111;
  localparam [3:0] XNOR          = 4'b1000;
  localparam [3:0] ERROR         = 4'b1001;
  localparam [3:0] RESULT        = 4'b1010;

//Inputs
  input            clk;                                     //Synchornous clock
  input            reset;                                   //Synchronous reset
  input            en;                                      //Enable signal
  input  [3:0]     gate_type;                               //Gate selector line
  input  [1:0]     no_of_inp;                               //Number of Inputs selector line
  input            op1;                                     //Operand one
  input            op2;                                     //Operand two
  input            op3;                                     //Operand three
  input            op4;                                     //Operand four
  input            op_ack_in_pulse;                         //Ack pulse signal for every input entered.
  input            final_inp_ack;                           //Final input ack signal
  input            err_clr;                                 //Clear signal without reset

//Outputs
  output           out;                                     //Output of the mux
  output           time_lim_err;                            //Time out of bounds for operand input error
  output           op_ack_out;                              //Ack signal for sampling output
  output [1:0]     inp_num_err;                             //Number of inputs not equal to required error

//Registers and wires decleration
  reg    [3:0]     state;
  reg    [3:0]     nxt_state;
  reg              out;
  reg              nxt_out;
  reg              time_lim_err;
  reg              nxt_time_lim_err;
  reg              op_ack_out;
  reg              nxt_op_ack_out;
  reg    [3:0]     count;                                   //4 bit Counter for time out of bounds calculation
  reg    [3:0]     nxt_count;
  reg    [1:0]     inp_num_err;
  reg    [1:0]     nxt_inp_num_err;
  reg              cnt_en;                                  //Counter enable signal
  reg              nxt_cnt_en;

  wire   [3:0]     gate_type;
  wire   [1:0]     no_of_inp;
  wire             op1;
  wire             op2;
  wire             op3;
  wire             op4;
  wire             clk;
  wire             reset;
  wire             en;
  wire             op_ack_in;
  wire             final_inp_ack;
  wire             err_clr;

//Combinational Logic

  always @(*)
  begin
//Default flop statements

    nxt_state             = state;
    nxt_out               = out;
    nxt_count             = 4'd0;
    nxt_time_lim_err      = time_lim_err;
    nxt_op_ack_out        = op_ack_out;
    nxt_inp_num_err       = inp_num_err;
    nxt_cnt_en            = cnt_en;

    if(count==4'b1111)                                     //Counter
    begin
      nxt_time_lim_err    = 1'b1;                          //Time out of bounds error after counter counted 16 clk cycles
      nxt_count           = 4'd0;
    end
    else
    begin
      if(op_ack_in_pulse)                                  //Counter reset after every input entered
      begin
        nxt_count         = 4'd0;
      end
      else if(cnt_en)                                      //Counting only when enable signal is high
      begin
        nxt_count         = count + 1'b1;
      end
    end

    case (state)
      IDLE:
      begin
        if(en)
        begin
          nxt_state       = GATE_SELECT;
          nxt_cnt_en      = 1'b1;                          //Counter enabled
        end
      end

      GATE_SELECT :
      begin

        if (time_lim_err)                                  //Checkin for time out of bounds error
        begin
          nxt_state       = ERROR;
        end

        if (gate_type==AND&&final_inp_ack)                 //AND select line asserted
        begin
          nxt_state       = AND;
        end

        if (gate_type==OR&&final_inp_ack)                  //OR select line asserted
        begin
          nxt_state       = OR;
        end

        if (gate_type==NOT&&final_inp_ack)                 //NOT select line asserted
        begin
          nxt_state       = NOT;
        end

        if (gate_type==NAND&&final_inp_ack)                //NAND select line asserted
        begin
          nxt_state       = NAND;
        end

        if (gate_type==NOR&&final_inp_ack)                 //NOR select line asserted
        begin
          nxt_state       = NOR;
        end

        if (gate_type==XOR&&final_inp_ack)                 //XOR select line asserted
        begin
          nxt_state       = XOR;
        end

        if (gate_type==XNOR&&final_inp_ack)                //XNOR select line asserted
        begin
          nxt_state       = XNOR;
        end
      end

      AND :
      begin
        if(no_of_inp==2'b00)
        begin
          nxt_inp_num_err = 2'b10;                         //Less number of inputs than expected
          nxt_state       = ERROR;
        end

        if(no_of_inp==2'b01)
        begin
          nxt_out         = op1&op2;
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b10)
        begin
          nxt_out         = op1&op2&op3;
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b11)
        begin
          nxt_out         = op1&op2&op3&op4;
          nxt_state       = RESULT;
        end
      end

      OR :
      begin
        if(no_of_inp==2'b00)
        begin
          nxt_inp_num_err = 2'b10;
          nxt_state       = ERROR;
        end

        if(no_of_inp==2'b01)
        begin
          nxt_out         = op1|op2;
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b10)
        begin
          nxt_out         = op1|op2|op3;
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b11)
        begin
          nxt_out         = op1|op2|op3|op4;
          nxt_state       = RESULT;
        end
      end

      NOT :
      begin
        if(no_of_inp!=2'b00)
        begin
          nxt_inp_num_err = 2'b01;                         //More number of inputs than expected
          nxt_state       = ERROR;
        end
        else
        begin
          nxt_out         = ~op1;
          nxt_state       = RESULT;
        end
      end

      NAND :
      begin
        if(no_of_inp==2'b00)
        begin
          nxt_inp_num_err = 2'b10;
          nxt_state       = ERROR;
        end

        if(no_of_inp==2'b01)
        begin
          nxt_out         = ~(op1&op2);
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b10)
        begin
          nxt_out         = ~(op1&op2&op3);
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b11)
        begin
          nxt_out         = ~(op1&op2&op3&op4);
          nxt_state       = RESULT;
        end
      end

      NOR :
      begin
        if(no_of_inp==2'b00)
        begin
          nxt_inp_num_err = 2'b10;
          nxt_state       = ERROR;
        end

        if(no_of_inp==2'b01)
        begin
          nxt_out         = ~(op1|op2);
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b10)
        begin
          nxt_out         = ~(op1|op2|op3);
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b11)
        begin
          nxt_out         = ~(op1|op2|op3|op4);
          nxt_state       = RESULT;
        end
      end

      XOR :
      begin
        if(no_of_inp==2'b00)
        begin
          nxt_inp_num_err = 2'b10;
          nxt_state       = ERROR;
        end

        if(no_of_inp==2'b01)
        begin
          nxt_out         = op1^op2;
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b10)
        begin
          nxt_out         = op1^op2^op3;
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b11)
        begin
          nxt_out         = op1^op2^op3^op4;
          nxt_state       = RESULT;
        end
      end

      XNOR :
      begin
        if(no_of_inp==2'b00)
        begin
          nxt_inp_num_err = 2'b10;
          nxt_state       = ERROR;
        end

        if(no_of_inp==2'b01)
        begin
          nxt_out         = ~(op1^op2);
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b10)
        begin
          nxt_out         = ~(op1^op2^op3);
          nxt_state       = RESULT;
        end

        if(no_of_inp==2'b11)
        begin
          nxt_out         = ~(op1^op2^op3^op4);
          nxt_state       = RESULT;
        end
      end

      RESULT :
      begin
        nxt_op_ack_out    = 1'b1;                          //output ack signal for sampling output asserted
        nxt_cnt_en        = 1'b0;                          //Counter enable signal deasserted
      end

      ERROR  :
      begin
        nxt_cnt_en        = 1'b0;                          //Counter enable signal deasserted

        if(err_clr)
        begin
          nxt_state       = IDLE;
        end
      end
    endcase
  end

//Sequential Logic

  always @(posedge clk, negedge reset)
  begin
    if (!reset)
    begin
      state               <= IDLE;
      out                 <= 1'b0;
      count               <= 4'd0;
      time_lim_err        <= 1'b0;
      op_ack_out          <= 1'b0;
      inp_num_err         <= 2'b00;
      cnt_en              <= 1'b0;
    end
    else
    begin
      state               <= nxt_state;
      out                 <= nxt_out;
      count               <= nxt_count;
      time_lim_err        <= nxt_time_lim_err;
      op_ack_out          <= nxt_op_ack_out;
      inp_num_err         <= nxt_inp_num_err;
      cnt_en              <= nxt_cnt_en;
    end
  end
endmodule
