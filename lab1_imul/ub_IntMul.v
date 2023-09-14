//========================================================================
// ub_IntMul
//========================================================================
// A basic Verilog test bench for the multiplier

// TYPE = Random / Alt
// Where Random means to test the module on 100 random inputs
// Alt means to generate inputs that target the alternative design
// and aims to exhibit the better performance of the alternative
// design relative to the baseline design.

`default_nettype none
`timescale 1ps/1ps

`ifndef DESIGN
  `define DESIGN IntMulBase
`endif

`ifndef TYPE
  `define TYPE Random
`endif

`include `"`DESIGN.v`"
`include "vc/trace.v"

//------------------------------------------------------------------------
// Top-level module
//------------------------------------------------------------------------

module top(  input logic clk, input logic linetrace );

  // DUT signals
  logic        reset;

  logic        istream_val;
  logic        istream_rdy;
  logic [63:0] istream_msg;

  logic        ostream_rdy;
  logic        ostream_val;
  logic [31:0] ostream_msg;

  // Testbench signals
  logic        istream_val_f;
  logic        ostream_rdy_f;

  logic [31:0] istream_msg_a;
  logic [31:0] istream_msg_b;

  // Form istream_msg
  always_comb begin
    istream_msg[63:32] = istream_msg_a;
    istream_msg[31: 0] = istream_msg_b;
  end

  //----------------------------------------------------------------------
  // Module instantiations
  //----------------------------------------------------------------------
  
  // Instantiate the multiplier

  lab1_imul_`DESIGN imul
  (
    .clk   (clk),
    .reset (reset),
    .istream_val(istream_val),
    .istream_rdy(istream_rdy),
    .istream_msg(istream_msg),
    .ostream_val   (ostream_val),
    .ostream_rdy   (ostream_rdy),
    .ostream_msg   (ostream_msg)
  );

  initial begin 
    while(1) begin
      @(negedge clk);  
      if (linetrace) begin
           imul.display_trace;
      end
    end 
    $stop;
   end

  //----------------------------------------------------------------------
  // Run the Test Bench
  //----------------------------------------------------------------------

  initial begin

    $display("Start of Testbench");
    // Send reset and init values of all signals
    reset         = 1;
    istream_msg_a = 0;
    istream_msg_b = 0;
    istream_val   = 0;

    // After a moment, de-assert reset
    #10 
    reset = 0;

    if (`"`TYPE`" == "Random") begin
      $display("Random Test"); // Random Micro-benchmark
      for( integer x = 0; x < 100; x++ ) begin
        test_task( $random, $random );
      end
    end else begin
      $display("Alternative Design Targeted Test"); 
      // Designed to accentuate the performance of alternative design
      // over baseline design
      test_task(7,32'b10);
      test_task(16,32'b10);
      test_task(8,32'b10);
      test_task(8,32'b1);
      test_task(3,32'b1);
      test_task(7,32'b100000000000000000000);
      test_task(23,32'b10);
      test_task(13,32'b10000);
      test_task(0,32'b100000000000000000000000);
      test_task(13,32'b10000000);
      test_task(19,32'b10000000000000000000000000000000);
      test_task(23,32'b100000000000000);
      test_task(4,32'b10);
      test_task(18,32'b10000000);
      test_task(4,32'b1);
      test_task(16,32'b10000000000000000000000000000000);
      test_task(3,32'b10000000000000000000000000000);
      test_task(13,32'b100000000000000000);
      test_task(5,32'b100000);
      test_task(4,32'b10000000000000000000000000);
      test_task(10,32'b100000000000000000000000000000);
      test_task(22,32'b1000000);
      test_task(24,32'b10000000000000);
      test_task(28,32'b10000000000000000);
      test_task(19,32'b1000000000000000000000000);
      test_task(5,32'b1);
      test_task(3,32'b10000000000000000000000);
      test_task(26,32'b1000000000000000);
      test_task(20,32'b1000000000000000000);
      test_task(27,32'b1000000);
      test_task(10,32'b1000000000000);
      test_task(13,32'b100000000000000000000000);
      test_task(4,32'b100000000000000000000000000000);
      test_task(1,32'b1000);
      test_task(21,32'b10000000000);
      test_task(9,32'b1000000000000000000000);
      test_task(11,32'b10000000000000000);
      test_task(10,32'b10000000000000000000000000000000);
      test_task(1,32'b100000000000000);
      test_task(18,32'b100000000000000000000000000000);
      test_task(23,32'b10000000000000000000000000);
      test_task(1,32'b1);
      test_task(11,32'b1000000000000000);
      test_task(28,32'b100000000000000);
      test_task(27,32'b100000000);
      test_task(7,32'b1000000);
      test_task(12,32'b10000000000000000000000);
      test_task(14,32'b1000);
      test_task(27,32'b1);
      test_task(24,32'b10000000000000);
      test_task(7,32'b1000000000000000000000000000);
      test_task(5,32'b100000000000000000000);
      test_task(13,32'b100);
      test_task(25,32'b10000000);
      test_task(23,32'b10000000000000);
      test_task(28,32'b1000000000000);
      test_task(15,32'b10);
      test_task(25,32'b100000000000000000000000000000);
      test_task(11,32'b10000000000000000000000000000000);
      test_task(0,32'b1000000000000000000000000000);
      test_task(21,32'b100000000000000000000000000000);
      test_task(5,32'b10000000000000000000000000);
      test_task(14,32'b1000000000000000000000000000000);
      test_task(20,32'b10000000000000000000000000);
      test_task(17,32'b10000000000000000000000000000000);
      test_task(10,32'b100000000000000000000000000000);
      test_task(4,32'b100000);
      test_task(21,32'b10000000000000);
      test_task(1,32'b100000000000);
      test_task(20,32'b100000000000000000000000000);
      test_task(18,32'b100000);
      test_task(2,32'b10000000000000000000000);
      test_task(19,32'b100000000000000000000);
      test_task(5,32'b10000000000000000000000000000);
      test_task(12,32'b1);
      test_task(28,32'b10000000000000000000);
      test_task(18,32'b100000000000000000000000000);
      test_task(4,32'b100000000000000);
      test_task(10,32'b10000000000000000000000000);
      test_task(12,32'b10);
      test_task(11,32'b1000);
      test_task(8,32'b1000000000000000000000000000);
      test_task(15,32'b1000000000000000000000000000000);
      test_task(1,32'b1000000000000000000000000000000);
      test_task(21,32'b100000000000000000000);
      test_task(18,32'b1000000000000000);
      test_task(22,32'b1000000000000000000000);
      test_task(20,32'b1000000000000000);
      test_task(10,32'b1000000000000000000000000000000);
      test_task(1,32'b1000000000000000000000000000);
      test_task(4,32'b10000000000000000000000000000);
      test_task(19,32'b100000);
      test_task(15,32'b1000000);
      test_task(15,32'b10000000000000000000000000000);
      test_task(9,32'b10000000000000000000000000000000);
      test_task(9,32'b10000000000000000000000);
      test_task(22,32'b1000000000000000000000000000000);
      test_task(0,32'b100000000000000000000000000000);
      test_task(17,32'b100);
      test_task(13,32'b1000000000000000000000000);
      end
    // Finish the testbench
    
    @(negedge clk);
    $display("Testbench finished at %d cycles", ($time()-10)/2 );
    
    // Delay for a better waveform
    #10;
    $finish;

  end

  //--------------------------------------------------------------------
  // test_task definition
  //--------------------------------------------------------------------
  // Here is a tasks that test the DUT when given 2 numbers a and b 
  //

  task test_task( [31:0] a,  [31:0] b );
  begin

    // Change inputs at the negedge
    @(negedge clk);

    // Set inputs
    istream_msg_a = a;
    istream_msg_b = b;
    istream_val   = 1'b1;
    ostream_rdy   = 1'b0;

    while(!istream_rdy) @(negedge clk); // Wait until ready is asserted
    @(negedge clk); // Move to next cycle.
    
    istream_val = 1'b0; // No more ready input
    ostream_rdy = 1'b1; // Ready for output

    if(!ostream_val) @(ostream_val);// Wait for response
    
    // Check the result
    assert ( (a * b) == ostream_msg) begin
      pass(); // Book keeping
      $display( "OK: in0 = %d, in1 = %d, out = %d", a, b, ostream_msg );
    end
    else begin
      fail(); // Book keeping
      $error( "Failed: in0 = %d, in1 = %d, out = %d", a, b, ostream_msg );
    end

    @(negedge clk);
  end
  endtask
endmodule
