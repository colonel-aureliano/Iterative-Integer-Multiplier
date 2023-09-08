//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_ALT_V
`define LAB1_IMUL_INT_MUL_ALT_V

`include "vc/trace.v"
`include "vc/muxes.v"
`include "vc/regs.v"

// ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
// Define datapath and control unit here.
// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

// verilator lint_off WIDTHEXPAND

module lab1_imul_IntMulAlt
(
  input  logic        clk,
  input  logic        reset,

  input  logic        istream_val,
  output logic        istream_rdy,
  input  logic [63:0] istream_msg,

  output logic        ostream_val,
  input  logic        ostream_rdy,
  output logic [31:0] ostream_msg
);

  // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Instantiate datapath and control models here and then connect them
  // together.
  // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  logic [31:0] a;
  logic [31:0] b;

  assign  a = istream_msg[63:32];
  assign  b = istream_msg[31:0];

  // -----------------------------

  logic [5:0]   shift_bits;   // set by control unit

  logic [31:0]  b_shifted;
  logic         b_mux_sel;    // set by control unit
  logic [31:0]  b_mux_out;

  logic [31:0]  b_to_shift;   // for control unit use

  assign b_shifted = b_to_shift >> shift_bits;

  vc_Mux2 #(32) b_mux (
    .in0(b),
    .in1(b_shifted),
    .sel(b_mux_sel),
    .out(b_mux_out)
  );

  vc_ResetReg #(32) b_reg (
    .clk(clk),
    .reset(reset),
    .d(b_mux_out),    // input
    .q(b_to_shift)    // output
    // at posedge, q <= d
  );

  // -----------------------------

  logic [31:0]  a_shifted;
  logic         a_mux_sel;    // set by control unit
  logic [31:0]  a_mux_out;

  logic [31:0]  a_to_shift;

  assign a_shifted = a_to_shift << shift_bits;

  vc_Mux2 #(32) a_mux (
    .in0(a),
    .in1(a_shifted),
    .sel(a_mux_sel),
    .out(a_mux_out)
  );

  vc_ResetReg #(32) a_reg (
    .clk(clk),
    .reset(reset),
    .d(a_mux_out),
    .q(a_to_shift)
  );

  // -----------------------------

  logic         result_en;        // set by control unit
  logic         result_mux_sel;   // set by control unit
  logic [31:0]  result_mux_out;

  vc_Mux2 #(32) result_mux(
    .in0(0),
    .in1(add_mux_out),
    .sel(result_mux_sel),
    .out(result_mux_out)
  );

  vc_EnReg #(32) result_reg(
    .clk(clk),
    .reset(reset),
    .d(result_mux_out),
    .en(result_en),
    .q(ostream_msg)
  );

  logic [31:0]  a_plus_out;
  logic         add_mux_sel;      // set by control unit
  logic [31:0]  add_mux_out;

  assign a_plus_out = ostream_msg + a_to_shift;

  vc_Mux2 #(32) add_mux(
    .in0(ostream_msg),
    .in1(a_plus_out),
    .sel(add_mux_sel),
    .out(add_mux_out)
  );

  // -----------------------------

  control_alt control_unit(
    .clk            (clk),
    .reset          (reset),
    .istream_val    (istream_val),
    .ostream_rdy    (ostream_rdy),
    .b_to_shift     (b_to_shift),
    .ostream_val    (ostream_val),
    .istream_rdy    (istream_rdy),
    .b_mux_sel      (b_mux_sel),
    .a_mux_sel      (a_mux_sel),
    .result_mux_sel (result_mux_sel),
    .result_en      (result_en),
    .add_mux_sel    (add_mux_sel),
    .shift_bits     (shift_bits)
  );

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    $sformat( str, "%x", istream_msg );
    vc_trace.append_val_rdy_str( trace_str, istream_val, istream_rdy, str );

    vc_trace.append_str( trace_str, "(" );

    // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
    // Add additional line tracing using the helper tasks for
    // internal state including the current FSM state.
    // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", ostream_msg );
    vc_trace.append_val_rdy_str( trace_str, ostream_val, ostream_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

module control_alt
(
  input  logic        clk,
  input  logic        reset,

  input  logic        istream_val,
  input  logic        ostream_rdy,

  input  logic [31:0] b_to_shift,

  output logic        ostream_val,
  output logic        istream_rdy,

  output logic        b_mux_sel,
  output logic        a_mux_sel,
  output logic        result_mux_sel,
  output logic        result_en,
  output logic        add_mux_sel,

  output logic [5:0]  shift_bits
);

  typedef enum logic [$clog2(3)-1:0] {
    STATE_IDLE,
    STATE_CALC,
    STATE_DONE
  } state_t;

  logic [5:0] counter;
  state_t state;
  logic [5:0] next_counter;
  state_t next_state;

  // State Transition block
  always_comb begin 
    next_state = state;
    if(istream_rdy && istream_val && state == STATE_IDLE)begin
      next_state = STATE_CALC;
    end
    if(counter >= 32 && state == STATE_CALC) begin
      next_state = STATE_DONE;
    end
    if(ostream_rdy && state == STATE_DONE) begin
       next_state = STATE_IDLE; 
    end
  end

  // State Output block
  always_comb begin
    b_mux_sel = 0;
    a_mux_sel = 0;
    result_mux_sel = 0;
    result_en = 0;
    add_mux_sel = 0;
    istream_rdy = 0;
    ostream_val = 0;
    shift_bits = 1;

    case(state)
      STATE_IDLE: begin
        next_counter = 0;
        istream_rdy = 1;
        result_en = 1;
      end
      STATE_CALC: begin
        b_mux_sel = 1;
        a_mux_sel = 1;
        result_mux_sel = 1;
        if(b_to_shift[0] == 1) begin
          result_en = 1;
          add_mux_sel = 1;
        end else begin
          if(b_to_shift == 0)
            shift_bits = 32;
          else if(b_to_shift[30:0] == 0) 
            shift_bits = 31;
          else if(b_to_shift[29:0] == 0) 
            shift_bits = 30;
          else if(b_to_shift[28:0] == 0) 
            shift_bits = 29;
          else if(b_to_shift[27:0] == 0) 
            shift_bits = 28;
          else if(b_to_shift[26:0] == 0) 
            shift_bits = 27;
          else if(b_to_shift[25:0] == 0) 
            shift_bits = 26;
          else if(b_to_shift[24:0] == 0) 
            shift_bits = 25;
          else if(b_to_shift[23:0] == 0) 
            shift_bits = 24;
          else if(b_to_shift[22:0] == 0) 
            shift_bits = 23;
          else if(b_to_shift[21:0] == 0) 
            shift_bits = 22;
          else if(b_to_shift[20:0] == 0) 
            shift_bits = 21;
          else if(b_to_shift[19:0] == 0) 
            shift_bits = 20;
          else if(b_to_shift[18:0] == 0) 
            shift_bits = 19;
          else if(b_to_shift[17:0] == 0) 
            shift_bits = 18;
          else if(b_to_shift[16:0] == 0) 
            shift_bits = 17;
          else if(b_to_shift[15:0] == 0) 
            shift_bits = 16;
          else if(b_to_shift[14:0] == 0) 
            shift_bits = 15;
          else if(b_to_shift[13:0] == 0) 
            shift_bits = 14;
          else if(b_to_shift[12:0] == 0) 
            shift_bits = 13;
          else if(b_to_shift[11:0] == 0) 
            shift_bits = 12;
          else if(b_to_shift[10:0] == 0) 
            shift_bits = 11;
          else if(b_to_shift[9:0] == 0) 
            shift_bits = 10;
          else if(b_to_shift[8:0] == 0) 
            shift_bits = 9;
          else if(b_to_shift[7:0] == 0) 
            shift_bits = 8;
          else if(b_to_shift[6:0] == 0) 
            shift_bits = 7;
          else if(b_to_shift[5:0] == 0) 
            shift_bits = 6;
          else if(b_to_shift[4:0] == 0) 
            shift_bits = 5;
          else if(b_to_shift[3:0] == 0) 
            shift_bits = 4;
          else if(b_to_shift[2:0] == 0) 
            shift_bits = 3;
          else if(b_to_shift[1:0] == 0) 
            shift_bits = 2;
        end
        next_counter = counter + shift_bits;
      end
      STATE_DONE: begin
        ostream_val = 1;
      end
      default: begin
        $stop;
      end
    endcase
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      state <= STATE_IDLE;
      counter <= 0;
    end else begin
      state <= next_state;
      counter <= next_counter;
    end
  end

endmodule

// verilator lint_on WIDTHEXPAND

`endif /* LAB1_IMUL_INT_MUL_ALT_V */
