//========================================================================
// tb_IntMulUVM
//========================================================================
// A UVM-inspired Verilog test bench for the multiplier

`default_nettype none
`timescale 1ps/1ps

`ifndef DESIGN
  `define DESIGN IntMulBase
`endif

`include `"`DESIGN.v`"
`include "vc/TestRandDelaySource.v"
`include "vc/TestRandDelaySink.v"

//------------------------------------------------------------------------
// Testbench defines
//------------------------------------------------------------------------

localparam NUM_TESTS = 12;

localparam  INPUT_TEST_SIZE = 64;
localparam OUTPUT_TEST_SIZE = 32;

localparam MAX_SRC_DELAY = 32'b0;
localparam MAX_SNK_DELAY = 32'b0;

//------------------------------------------------------------------------
// Top-level module
//------------------------------------------------------------------------

module top( input logic clk ,  input logic linetrace );
  
  // DUT signals
  logic        reset;

  logic        istream_val;
  logic        istream_rdy;
  logic [63:0] istream_msg;

  logic        ostream_rdy;
  logic        ostream_val;
  logic [31:0] ostream_msg;

  // Source and sink messages

  logic [  INPUT_TEST_SIZE-1:0 ] src_msgs [ NUM_TESTS-1:0 ];
  logic [ OUTPUT_TEST_SIZE-1:0 ] snk_msgs [ NUM_TESTS-1:0 ];

  // Signals to indicate completion

  logic src_done;
  logic snk_done;
  
  //----------------------------------------------------------------------
  // Module instantiations
  //----------------------------------------------------------------------

  // Test source

  vc_TestRandDelaySource 
  #(
    .p_msg_nbits ( INPUT_TEST_SIZE ),
    .p_num_msgs  (       NUM_TESTS )
  ) src (
    .clk         (             clk ),
    .reset       (           reset ),

    .max_delay   (   MAX_SRC_DELAY ),

    .val         (     istream_val ),
    .rdy         (     istream_rdy ),
    .msg         (     istream_msg ),

    .done        (        src_done )
  );

  assign src.src.m = src_msgs;
  
  // DUT
  
  lab1_imul_`DESIGN dut
  (
    .clk         (       clk   ),
    .reset       (       reset ),

    // Input stream

    .istream_val ( istream_val ),
    .istream_rdy ( istream_rdy ),
    .istream_msg ( istream_msg ),

    // Output stream

    .ostream_val ( ostream_val ),
    .ostream_rdy ( ostream_rdy ),
    .ostream_msg ( ostream_msg )
  );

  // Test sink

  vc_TestRandDelaySink
  #(
    .p_msg_nbits ( OUTPUT_TEST_SIZE ),
    .p_num_msgs  (        NUM_TESTS )
  ) sink (
    .clk         (              clk ),
    .reset       (            reset ),

    .max_delay   (    MAX_SNK_DELAY ),

    .val         (      ostream_val ),
    .rdy         (      ostream_rdy ),
    .msg         (      ostream_msg ),

    .done        (         snk_done )
  );

  assign sink.sink.m = snk_msgs;

  //----------------------------------------------------------------------
  // Task for adding test cases
  //----------------------------------------------------------------------

  task test_case(
    input logic [  INPUT_TEST_SIZE-1:0 ] src_msg,
    input logic [ OUTPUT_TEST_SIZE-1:0 ] snk_msg
  );
  begin
    integer idx = 0;

    // Add messages to test arrays
    src_msgs[ idx ] = src_msg;
    snk_msgs[ idx ] = snk_msg;

    idx = idx + 1;
  end
  endtask

  //----------------------------------------------------------------------
  // Test cases
  //----------------------------------------------------------------------
  // Don't forget to change NUM_TESTS above when adding new tests!

  initial begin

    // Test cases

    test_case( { 32'd1, 32'd1 },  32'd1 );
    test_case( { 32'd2, 32'd2 },  32'd4 );
    test_case( { 32'd3, 32'd2 },  32'd6 );
    test_case( { 32'd20, 32'd30 },  32'd600 );

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Combinations of multiplying zero, one, and negative one
    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    $display("Combinations of multiplying zero, one, and negative one");
    test_case( {  32'd0,  32'd0 },  32'd0 );
    test_case( {  32'd0,  32'd1 },  32'd0 );
    test_case( { -32'd1, 32'd0 },   32'd0 );
    test_case( { -32'd1, 32'd7 },   -32'd7 );
    test_case( { -32'd1, 32'd2_147_483_647 }, -32'd2_147_483_647 );
    test_case( {  32'd1, 32'd2_147_483_647 }, 32'd2_147_483_647 );
    test_case( { -32'd1, 32'd2_147_483_647 }, -32'd2_147_483_647 );
    test_case( { -32'd1, 32'd2_147_483_648 }, -32'd2_147_483_648 );

    // test_case(1, -1);
    // test_case(-1, 7);
    // test_case(0, 2_147_483_647);
    // test_case(1, 2_147_483_647);
    // test_case(-1, 2_147_483_647);
    // test_case(-1, 2_147_483_648);

  end

  //----------------------------------------------------------------------
  // Run the Test Bench
  //----------------------------------------------------------------------

  initial begin

    $display( "Starting tb_IntMulBase_full..." );
    reset = 1;
    
    // Wait a bit, then de-assert reset on negedge
    #10 
    @( negedge clk );
    reset = 0;

    // Wait for the test to finish
    while( !snk_done ) @( negedge clk );

    // Check that the source is also done
    if( !src_done )
      $error( "Failed: Our sink received more messages than our source has!" );
    else
      $display( "Success: The testbench has passed!" );

    // Delay for a bit for a better waveform
    #100
    $finish;
  end

  //----------------------------------------------------------------------
  // Timeout
  //----------------------------------------------------------------------
  // This is to ensure that our test eventually finishes, even if the sink
  // isn't receiving messages

  initial begin
    for( integer i = 0; i < 1000000; i = i + 1 ) begin
      @( negedge clk );
    end

    $error( "TIMEOUT: Testbench didn't finish in time" );
    $finish;
  end

  //----------------------------------------------------------------------
  // Tracing
  //----------------------------------------------------------------------

  initial begin 
    while(1) begin
      @(negedge clk);  
      if (linetrace) begin
           dut.display_trace;
      end
    end 
    $stop;
  end

endmodule
