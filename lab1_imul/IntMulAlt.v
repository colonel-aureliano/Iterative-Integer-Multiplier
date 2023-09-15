//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_ALT_V
`define LAB1_IMUL_INT_MUL_ALT_V

`include "vc/trace.v"
`include "vc/muxes.v"
`include "vc/regs.v"
`include "IntMulHelper.v"

// verilator lint_off WIDTHEXPAND

module dpath_Alt
(
  input  logic        clk,
  input  logic        reset,

  input  logic [63:0] istream_msg,
  output logic [31:0] ostream_msg,

  input logic         b_mux_sel,
  input logic         a_mux_sel,
  input logic         result_mux_sel,
  input logic         result_en,
  input logic         add_mux_sel,
  input logic   [5:0] shift_bits,
  output logic [31:0] b_to_shift
);

  logic [31:0] a;
  logic [31:0] b;

  assign  a = istream_msg[63:32];
  assign  b = istream_msg[31:0];

  // -----------------------------

  logic [31:0]  b_shifted;
  logic [31:0]  b_mux_out;

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
  logic [31:0]  add_mux_out;

  assign a_plus_out = ostream_msg + a_to_shift;

  vc_Mux2 #(32) add_mux(
    .in0(ostream_msg),
    .in1(a_plus_out),
    .sel(add_mux_sel),
    .out(add_mux_out)
  );

endmodule

module control_Alt
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
    if(counter >= 31 && state == STATE_CALC) begin
      next_state = STATE_DONE;
    end
    if(ostream_rdy && state == STATE_DONE) begin
       next_state = STATE_IDLE; 
    end
  end

  lab1_imul_IntMulHelper shift_helper(
    .b_to_shift   (b_to_shift),
    .shift_bits   (shift_bits)
  );

  // State Output block
  always_comb begin
    b_mux_sel = 0;
    a_mux_sel = 0;
    result_mux_sel = 0;
    result_en = 0;
    add_mux_sel = 0;
    istream_rdy = 0;
    ostream_val = 0;

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

  logic [31:0]  b_to_shift;   // for control unit use
  logic [5:0]   shift_bits;   // set by control unit

  logic         add_mux_sel;      // set by control unit
  logic         result_en;        // set by control unit
  logic         result_mux_sel;   // set by control unit
  logic         a_mux_sel;        // set by control unit
  logic         b_mux_sel;        // set by control unit

  dpath_Alt datapath(
    .clk            (clk),
    .reset          (reset),
    .istream_msg    (istream_msg),
    .ostream_msg    (ostream_msg),
    .b_mux_sel      (b_mux_sel),
    .a_mux_sel      (a_mux_sel),
    .result_mux_sel (result_mux_sel),
    .result_en      (result_en),
    .add_mux_sel    (add_mux_sel),
    .shift_bits     (shift_bits),
    .b_to_shift     (b_to_shift)
  ); 

  // -----------------------------

  control_Alt control_unit(
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
    if (ostream_val) begin
      $sformat( str, "%d", control_unit.state );
      vc_trace.append_str( trace_str, str );

      $sformat( str, "%d", ostream_msg );
      vc_trace.append_str( trace_str, str );
    end
    else if (result_en && add_mux_sel == 1) begin
       $sformat( str, "%d + ", ostream_msg );
      vc_trace.append_str( trace_str, str );

      $sformat( str, "%d = ", datapath.a_to_shift );
      vc_trace.append_str( trace_str, str );

      $sformat( str, "%d", datapath.add_mux_out );
      vc_trace.append_str( trace_str, str );
    end else vc_trace.append_str( trace_str, "                              ") ;

    vc_trace.append_str( trace_str, ")" );

    vc_trace.append_val_rdy_str( trace_str, ostream_val, ostream_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

// verilator lint_on WIDTHEXPAND

`endif /* LAB1_IMUL_INT_MUL_ALT_V */
