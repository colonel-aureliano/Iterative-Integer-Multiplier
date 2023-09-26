//      // verilator_coverage annotation
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
        
        localparam NUM_TESTS = 56;
        
        localparam  INPUT_TEST_SIZE = 64;
        localparam OUTPUT_TEST_SIZE = 32;
        
        localparam MAX_SRC_DELAY = 32'b1;
        localparam MAX_SNK_DELAY = 32'b1;
        
        //------------------------------------------------------------------------
        // Top-level module
        //------------------------------------------------------------------------
        
 000001 module top( input logic clk ,  input logic linetrace );
          
          // DUT signals
 000001   logic        reset;
        
 000002   logic        istream_val;
 000112   logic        istream_rdy;
 000006   logic [63:0] istream_msg;
        
 000002   logic        ostream_rdy;
 000112   logic        ostream_val;
 000024   logic [31:0] ostream_msg;
        
          // Source and sink messages
        
          logic [  INPUT_TEST_SIZE-1:0 ] src_msgs [ NUM_TESTS-1:0 ];
          logic [ OUTPUT_TEST_SIZE-1:0 ] snk_msgs [ NUM_TESTS-1:0 ];
        
          // Signals to indicate completion
        
 000001   logic src_done;
 000001   logic snk_done;
          
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
        
%000000   integer idx = 0;
        
%000000   task test_case(
            input logic [  INPUT_TEST_SIZE-1:0 ] src_msg,
            input logic [ OUTPUT_TEST_SIZE-1:0 ] snk_msg
          );
%000000   begin
        
            // Add messages to test arrays
%000000     src_msgs[ idx ] = src_msg;
%000000     snk_msgs[ idx ] = snk_msg;
        
%000000     idx = idx + 1;
          end
          endtask
        
%000000   task test_case_auto_calc_result(
              input logic [INPUT_TEST_SIZE-1:(INPUT_TEST_SIZE)/2] a,
              input logic [  (INPUT_TEST_SIZE)/2-1:0 ] b
              );
%000000   begin
        
            // Add messages to test arrays
%000000     src_msgs[ idx ] = {a,b};
%000000     snk_msgs[ idx ] = a * b;
        
%000000     idx = idx + 1;
          end
          endtask
        
%000000   task mask_test_case(
            input logic [  (INPUT_TEST_SIZE)/2-1:0 ] in_signal1, 
            input logic [  (INPUT_TEST_SIZE)/2-1:0 ] in_signal2,
            string position
            );
            logic [ OUTPUT_TEST_SIZE-1:0 ] masked_signal1;
            logic [ OUTPUT_TEST_SIZE-1:0 ] masked_signal2;
            logic [7:0] mask;
            logic [31:0] mask_32bit;
        
%000000     mask = 8'hFF;
            
%000000     if (position == "low") begin
%000000       mask_32bit = {24'b0, mask};
            end
%000000     else if (position == "middle") begin
%000000       mask_32bit = {16'b0, mask, 8'b0};
            end
%000000     else if (position == "high") begin
%000000       mask_32bit = {8'b0, mask, 16'b0};
            end
%000000     else begin 
%000000       mask_32bit = 32'b0;
            end
            
            // Inverting the 32-bit mask
%000000     mask_32bit = ~mask_32bit;
            
            // Applying the inverted mask to clear the corresponding bits in the 32-bit signal
%000000     masked_signal1 = in_signal1 & mask_32bit;
%000000     masked_signal2 = in_signal2 & mask_32bit;
        
%000000     src_msgs[ idx ] = { masked_signal1, masked_signal2 };
%000000     snk_msgs[ idx ] = masked_signal1 * masked_signal2;
        
%000000     idx = idx + 1;
          endtask
        
          //----------------------------------------------------------------------
          // Test cases
          //----------------------------------------------------------------------
          // Don't forget to change NUM_TESTS above when adding new tests!
        
%000000   initial begin
            logic [31:0] rd1;
            logic [31:0] rd2;
        
            // Alternative Design specific tests
            // Inputs designed to be of certain pattern
%000000     test_case_auto_calc_result(2938209, 32'b1000_0000_0001_0000_0001_0000_0000_0001);
%000000     test_case_auto_calc_result(-1, 32'b1000_0000_0000_0000_0100_0010_0000_0010);
%000000     test_case_auto_calc_result(8, 32'b0000_0000_0000_0000_0001_0000_0000_0000);
%000000     test_case_auto_calc_result(2,32'b0001_0000_0000_0000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(1,32'b0000_1000_0000_0000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(-10,32'b0000_0100_0000_0000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(-20,32'b0000_0010_0000_0000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(-5,32'b0000_0001_0000_0000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(1,32'b0000_0000_1000_0000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(2,32'b0000_0000_0100_0000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(3,32'b1000_0000_0010_0000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(1,32'b1000_0000_0001_0000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(2,32'b1000_0000_0000_1000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(-9,32'b1000_0000_0010_0100_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(-3,32'b1000_0000_0010_0010_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(1,32'b0010_0000_0000_0001_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(2,32'b1000_0000_0010_0000_1000_0000_0000_0000);
%000000     test_case_auto_calc_result(2,32'b0010_0000_0000_0000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(2,32'b1100_0000_0010_0000_0000_0000_0000_0000);
%000000     test_case_auto_calc_result(4,32'b1100_0000_0001_0000_0000_0000_0100_0000);
%000000     test_case_auto_calc_result(4,32'b1100_0000_0001_0000_0100_0000_0000_0000);
%000000     test_case_auto_calc_result(1,32'b1100_0000_0000_0000_0000_0000_0000_0000);
        
%000000     $display("Tests with some input bits masked off");
%000000     mask_test_case( 32'd46_340, -32'd46_343, "low" );
%000000     mask_test_case( 32'd782,     32'd613, "middle");
%000000     mask_test_case( 32'd0,      -32'd993, "high" );
%000000     mask_test_case( -32'd1,    -32'd933803, "low" );
%000000     mask_test_case( 32'd0,      32'd2837, "middle");
%000000     mask_test_case( -32'd1,      32'd64293, "high" );
        
            // Test cases
        
%000000     test_case( { 32'd1, 32'd1 },  32'd1 );
%000000     test_case( { 32'd2, 32'd2 },  32'd4 );
%000000     test_case( { 32'd3, 32'd2 },  32'd6 );
%000000     test_case( { 32'd20, 32'd30 },  32'd600 );
        
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Combinations of multiplying zero, one, and negative one
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%000000     $display("Combinations of multiplying zero, one, and negative one");
%000000     test_case( {  32'd0,  32'd0 },  32'd0 );
%000000     test_case( {  32'd0,  32'd1 },  32'd0 );
%000000     test_case( { -32'd1, 32'd0 },   32'd0 );
%000000     test_case( { -32'd1, 32'd7 },   -32'd7 );
%000000     test_case( { -32'd1, 32'd2_147_483_647 }, -32'd2_147_483_647 );
%000000     test_case( {  32'd1, 32'd2_147_483_647 }, 32'd2_147_483_647 );
%000000     test_case( { -32'd1, 32'd2_147_483_647 }, -32'd2_147_483_647 );
%000000     test_case( { -32'd1, 32'd2_147_483_648 }, -32'd2_147_483_648 );
        
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Small negative numbers × small positive numbers
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%000000     $display("Small negative numbers x small positive numbers");
%000000     test_case( { -32'd3, 32'd2 },  -32'd6 );
%000000     test_case( { -32'd19, 32'd4 }, -32'd76 );
%000000     test_case( { -32'd9, 32'd9 },  -32'd81 );
        
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Small negative numbers × small negative numbers
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%000000     $display("Small negative numbers x small negative numbers");
%000000     test_case( { -32'd3, -32'd4 }, 32'd12 );
%000000     test_case( { -32'd18, -32'd3 }, 32'd54 );
%000000     test_case( { -32'd2, -32'd2 },  32'd4 );
        
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Large positive numbers × large positive numbers
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%000000     $display("Large positive numbers x large positive numbers");
%000000     test_case( { 32'd9_999, 32'd9_999 }, 32'd99_980_001 );
%000000     test_case( { 32'd46_340, 32'd46_341 }, 32'd2_147_441_940 );
%000000     test_case( { 32'd23_872, 32'd35_269 }, 32'd841_941_568 );
        
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Large positive numbers × large negative numbers
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%000000     $display("Large positive numbers x large negative numbers");
%000000     test_case( { -32'd9999, 32'd77777 },  -32'd777_692_223 );
%000000     test_case( { 32'd29381, -32'd63289 }, -32'd1_859_494_109 );
        
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Random numbers x randon numbers
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%000000     $display("Random numbers x random numbers");
%000000     rd1[31:0] = $random;
%000000     rd2[31:0] = $random;
%000000     test_case( { rd1, rd2 },  rd1 * rd2 );
        
%000000     rd1[31:0] = $random;
%000000     rd2[31:0] = $random;
%000000     test_case( { rd1, rd2 },  rd1 * rd2 );
        
%000000     rd1[31:0] = $random;
%000000     rd2[31:0] = $random;
%000000     test_case( { rd1, rd2 },  rd1 * rd2 );
        
%000000     rd1[31:0] = $random;
%000000     rd2[31:0] = $random;
%000000     test_case( { rd1, rd2 },  rd1 * rd2 );
        
%000000     rd1[31:0] = $random;
%000000     rd2[31:0] = $random;
%000000     test_case( { rd1, rd2 },  rd1 * rd2 );
        
          end
        
          //----------------------------------------------------------------------
          // Run the Test Bench
          //----------------------------------------------------------------------
        
 000001   initial begin
 000001     $display( "Starting testing" );
 000001     reset = 1;
            
            // Wait a bit, then de-assert reset on negedge
 000001     #10 
 000001     @( negedge clk );
 000001     reset = 0;
        
            // Wait for the test to finish
 000754     while( !snk_done ) @( negedge clk );
        
            // Check that the source is also done
 000001     if( !src_done )
              $error( "Failed: Our sink received more messages than our source has!" );
            else
 000001       $display( "Success: The testbench has passed!" );
        
            // Delay for a bit for a better waveform
 000001     #100
 000001     $finish;
          end
        
          //----------------------------------------------------------------------
          // Timeout
          //----------------------------------------------------------------------
          // This is to ensure that our test eventually finishes, even if the sink
          // isn't receiving messages
        
          initial begin
 000809     for( integer i = 0; i < 1000000; i = i + 1 ) begin
 000809       @( negedge clk );
            end
        
            $error( "TIMEOUT: Testbench didn't finish in time" );
            $finish;
          end
        
          //----------------------------------------------------------------------
          // Tracing
          //----------------------------------------------------------------------
        
          initial begin 
 000809     while(1) begin
 000809       @(negedge clk);  
 000001       if (linetrace) begin
 000808            dut.display_trace;
              end
            end 
            $stop;
          end
        
        endmodule
        
