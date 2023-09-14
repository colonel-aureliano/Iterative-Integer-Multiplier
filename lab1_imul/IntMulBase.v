//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

`ifndef LAB1_IMUL_INT_MUL_BASE_V
`define LAB1_IMUL_INT_MUL_BASE_V

`include "vc/trace.v"
`include "vc/regs.v"
`include "vc/muxes.v"

module lab1_imul_ControlBase
(
  input  logic  clk,
  input  logic  reset,

  input  logic  istream_val,
  input  logic  ostream_rdy,

  input  logic  b_lsb,

  output logic  ostream_val,
  output logic  istream_rdy,

  output logic  a_mux_sel,
  output logic  b_mux_sel,
  output logic  result_mux_sel,
  output logic  result_en,
  output logic  add_mux_sel
);
  // Note: for all muxes, upper is 0, down is 1

  typedef enum logic [$clog2(3)-1:0]{
    IDLE,
    CALC,
    DONE
  } fsm_state;

  logic [4:0]  counter;
  logic [4:0]  next_counter;

  fsm_state current_state, next_state;

  always_ff @(posedge clk) begin
    if (reset) begin
      current_state <= IDLE;
      counter <= 5'b00000;
    end
    else begin
      current_state <= next_state;
      counter <= next_counter;
    end
  end

  // logic for transition to next_state
  always_comb begin
    next_state = current_state;
    next_counter = counter;
    case (current_state)
      IDLE: begin
        if (istream_val) begin
          next_state = CALC;
          next_counter = 5'b00000;
        end
      end
      CALC: begin
        next_counter = counter + 1;
        if (counter == 31)
          next_state = DONE;
      end
      DONE: begin
        if (ostream_rdy)
          next_state = IDLE;
      end
      default: $stop;
    endcase
  end
  
  // outputs from the control unit
  always_comb begin
    a_mux_sel      = 1;
    b_mux_sel      = 1;
    result_mux_sel = 1;
    result_en      = 0;
    add_mux_sel    = 1;
    istream_rdy    = 0;
    ostream_val    = 0;
    
    case (current_state)
      IDLE: begin
        istream_rdy = 1;
        result_en   = 1;
      end
      CALC: begin
        a_mux_sel      = 0;
        b_mux_sel      = 0;
        result_mux_sel = 0;
        result_en = 1;
        if (b_lsb == 1) begin
          add_mux_sel = 0;
        end
      end
      DONE: begin
        ostream_val = 1;
      end
      default: $stop;
    endcase
  end
endmodule

module lab1_imul_DataBase
(
  input  logic  clk,
  input  logic  reset,

  input  logic [63:0] istream_msg,

  input  logic        a_mux_sel,
  input  logic        b_mux_sel,
  input  logic        add_mux_sel,
  input  logic        result_mux_sel,
  input  logic        result_en,

  output logic        b_lsb,
  output logic [31:0] ostream_msg
);
  logic [31:0] a, b;
  
  assign a = istream_msg[63:32];
  assign b = istream_msg[31:0];

  //----------------------------------------------
  logic[31:0] a_shifted, a_mux_out, a_to_shift;

  vc_Mux2 #(32) a_mux (
    .in0(a_shifted),
    .in1(a),
    .sel(a_mux_sel),
    .out(a_mux_out)
  );

  vc_ResetReg #(32) a_reg (
    .clk(clk),
    .reset(reset),
    .q(a_to_shift),
    .d(a_mux_out)
  );

  assign a_shifted = a_to_shift << 1;

  //----------------------------------------------
  logic[31:0] b_shifted, b_mux_out, b_to_shift;

  vc_Mux2 #(32) b_mux (
    .in0(b_shifted),
    .in1(b),
    .sel(b_mux_sel),
    .out(b_mux_out)
  );

  vc_ResetReg #(32) b_reg (
    .clk(clk),
    .reset(reset),
    .q(b_to_shift),
    .d(b_mux_out)
  );

  assign b_lsb = b_to_shift[0];
  assign b_shifted = b_to_shift >> 1;

  //----------------------------------------------
  logic [31:0] add_mux_out, result_mux_out, result_reg_out;
  assign ostream_msg = result_reg_out;

  vc_Mux2 #(32) result_mux (
    .in0(add_mux_out),
    .in1(0),
    .sel(result_mux_sel),
    .out(result_mux_out)
  );

  vc_EnReg #(32) result_reg(
    .clk(clk),
    .reset(reset),
    .q(result_reg_out),
    .d(result_mux_out),
    .en(result_en)
  );

  logic [31:0] plus_out;

  assign plus_out = a_to_shift + result_reg_out;

  vc_Mux2 #(32) add_mux(
    .in0(plus_out),
    .in1(result_reg_out),
    .sel(add_mux_sel),
    .out(add_mux_out)
  );

endmodule
//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

module lab1_imul_IntMulBase
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
  
  // Internal signals for interconnecting control and data units
  logic b_lsb;
  logic a_mux_sel;
  logic b_mux_sel;
  logic result_mux_sel;
  logic result_en;
  logic add_mux_sel;

  lab1_imul_ControlBase control_base(
    .clk            (clk),
    .reset          (reset),
    .istream_val    (istream_val),
    .ostream_rdy    (ostream_rdy),
    .b_lsb          (b_lsb),
    .ostream_val    (ostream_val),
    .istream_rdy    (istream_rdy),
    .a_mux_sel      (a_mux_sel),
    .b_mux_sel      (b_mux_sel),
    .add_mux_sel    (add_mux_sel),
    .result_mux_sel (result_mux_sel),
    .result_en      (result_en)
  );

  lab1_imul_DataBase data_base(
    .clk            (clk),
    .reset          (reset),
    .istream_msg     (istream_msg),
    .a_mux_sel       (a_mux_sel), 
    .b_mux_sel       (b_mux_sel),
    .add_mux_sel     (add_mux_sel),
    .result_mux_sel  (result_mux_sel),
    .result_en       (result_en),
    .b_lsb           (b_lsb),
    .ostream_msg     (ostream_msg)
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
      $sformat( str, "%d", control_base.current_state );
      vc_trace.append_str( trace_str, str );

      $sformat( str, "%d", ostream_msg );
      vc_trace.append_str( trace_str, str );
    end
    else if (result_en && add_mux_sel == 1) begin
       $sformat( str, "%d + ", ostream_msg );
      vc_trace.append_str( trace_str, str );

      $sformat( str, "%d = ", data_base.a_to_shift );
      vc_trace.append_str( trace_str, str );

      $sformat( str, "%d", data_base.add_mux_out );
      vc_trace.append_str( trace_str, str );
    end else vc_trace.append_str( trace_str, "                              ") ;

    vc_trace.append_str( trace_str, ")" );

    vc_trace.append_val_rdy_str( trace_str, ostream_val, ostream_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LAB1_IMUL_INT_MUL_BASE_V */
