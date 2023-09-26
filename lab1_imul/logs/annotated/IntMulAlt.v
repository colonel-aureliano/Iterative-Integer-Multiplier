//      // verilator_coverage annotation
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
 001617   input  logic        clk,
 000001   input  logic        reset,
        
 000006   input  logic [63:0] istream_msg,
 000024   output logic [31:0] ostream_msg,
        
 000112   input logic         b_mux_sel,
 000112   input logic         a_mux_sel,
 000112   input logic         result_mux_sel,
 000358   input logic         result_en,
 000284   input logic         add_mux_sel,
 000036   input logic   [5:0] shift_bits,
 000030   output logic [31:0] b_to_shift
        );
        
 000016   logic [31:0] a;
 000006   logic [31:0] b;
        
          assign  a = istream_msg[63:32];
          assign  b = istream_msg[31:0];
        
          // -----------------------------
        
 000088   logic [31:0]  b_shifted;
 000030   logic [31:0]  b_mux_out;
        
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
        
 000030   logic [31:0]  a_shifted;
 000056   logic [31:0]  a_mux_out;
        
 000056   logic [31:0]  a_to_shift;
        
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
        
 000024   logic [31:0]  result_mux_out;
        
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
        
 000056   logic [31:0]  a_plus_out;
 000014   logic [31:0]  add_mux_out;
        
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
 001617   input  logic        clk,
 000001   input  logic        reset,
        
 000002   input  logic        istream_val,
 000002   input  logic        ostream_rdy,
        
 000030   input  logic [31:0] b_to_shift,
        
 000112   output logic        ostream_val,
 000112   output logic        istream_rdy,
        
 000112   output logic        b_mux_sel,
 000112   output logic        a_mux_sel,
 000112   output logic        result_mux_sel,
 000358   output logic        result_en,
 000284   output logic        add_mux_sel,
        
 000036   output logic [5:0]  shift_bits
        );
        
          typedef enum logic [$clog2(3)-1:0] {
            STATE_IDLE,
            STATE_CALC,
            STATE_DONE
          } state_t;
        
 000082   logic [5:0] counter;
 000112   state_t state;
 000082   logic [5:0] next_counter;
 000112   state_t next_state;
        
          // State Transition block
 000808   always_comb begin 
 000808     next_state = state;
 000056     if(istream_rdy && istream_val && state == STATE_IDLE)begin
 000056       next_state = STATE_CALC;
            end
 000056     if(counter >= 31 && state == STATE_CALC) begin
 000056       next_state = STATE_DONE;
            end
 000056     if(ostream_rdy && state == STATE_DONE) begin
 000056        next_state = STATE_IDLE; 
            end
          end
        
          lab1_imul_IntMulHelper shift_helper(
            .b_to_shift   (b_to_shift),
            .shift_bits   (shift_bits)
          );
        
          // State Output block
 000808   always_comb begin
 000808     b_mux_sel = 0;
 000808     a_mux_sel = 0;
 000808     result_mux_sel = 0;
 000808     result_en = 0;
 000808     add_mux_sel = 0;
 000808     istream_rdy = 0;
 000808     ostream_val = 0;
        
 000808     case(state)
 000111       STATE_IDLE: begin
 000111         next_counter = 0;
 000111         istream_rdy = 1;
 000111         result_en = 1;
              end
 000641       STATE_CALC: begin
 000641         b_mux_sel = 1;
 000641         a_mux_sel = 1;
 000641         result_mux_sel = 1;
 000187         if(b_to_shift[0] == 1) begin
 000454           result_en = 1;
 000454           add_mux_sel = 1;
                end
 000641         next_counter = counter + shift_bits;
              end
 000056       STATE_DONE: begin
 000056         ostream_val = 1;
              end
              default: begin
                $stop;
              end
            endcase
          end
        
 000808   always_ff @(posedge clk) begin
 000004     if (reset) begin
 000004       state <= STATE_IDLE;
 000004       counter <= 0;
 000804     end else begin
 000804       state <= next_state;
 000804       counter <= next_counter;
            end
          end
        
        endmodule
        
        module lab1_imul_IntMulAlt
        (
 001617   input  logic        clk,
 000001   input  logic        reset,
        
 000002   input  logic        istream_val,
 000112   output logic        istream_rdy,
 000006   input  logic [63:0] istream_msg,
        
 000112   output logic        ostream_val,
 000002   input  logic        ostream_rdy,
 000024   output logic [31:0] ostream_msg
        );
        
          // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
          // Instantiate datapath and control models here and then connect them
          // together.
          // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        
 000030   logic [31:0]  b_to_shift;   // for control unit use
 000036   logic [5:0]   shift_bits;   // set by control unit
        
 000284   logic         add_mux_sel;      // set by control unit
 000358   logic         result_en;        // set by control unit
 000112   logic         result_mux_sel;   // set by control unit
 000112   logic         a_mux_sel;        // set by control unit
 000112   logic         b_mux_sel;        // set by control unit
        
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
        
