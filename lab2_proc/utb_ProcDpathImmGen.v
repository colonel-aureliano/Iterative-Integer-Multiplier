//========================================================================
// utb_ProcDpathImmGen
//========================================================================
// A basic Verilog unit test bench for the Processor ImmGen module

`default_nettype none
`timescale 1ps/1ps

`include "ProcDpathImmGen.v"
`include "vc/trace.v"

//------------------------------------------------------------------------
// Top-level module
//------------------------------------------------------------------------

module top(   input logic clk ,  input logic linetrace  );

  logic [ 2:0] imm_type;
  logic [31:0] inst;

  logic [31:0] imm;

  // Instantiate the processor ALU
  lab2_proc_ProcDpathImmGen
  DUT
  ( .*
  ); 

  //----------------------------------------------------------------------
  // Run the Test Bench
  //----------------------------------------------------------------------

  initial begin
    @(negedge clk);
    
    //======================================
    // Test I-type
    //======================================

    // 1. ADDI 
    // Set inputs
    imm_type = 0;
    inst     = 'b100101010101_01010_000_10101_0010011;

    #1

    // Check the result
    check_result('b11111111111111111111_100101010101, "I-type");

    // 2. ANDI
    imm_type = 0;
    inst     = 'b000101010101_01010_111_10101_0010011;

    #1

    // Check the result
    check_result('b000101010101, "I-type"); 

    // 3. ORI
    imm_type = 0;
    inst     = 'b111111111111_01010_110_10101_0010011;

    #1

    // Check the result
    check_result('b11111111111111111111_111111111111, "I-type"); 

    // 4. XORI
    imm_type = 0;
    inst     = 'b110000000001_01010_100_10101_0010011;

    #1

    // Check the result
    check_result('b11111111111111111111_110000000001, "I-type");

    // 5. SLTI
    imm_type = 0;
    inst     = 'b00000000011_01010_100_10101_0010011;

    #1

    // Check the result
    check_result('b00000000011, "I-type"); 

    // 6. SLTI
    imm_type = 0;
    inst     = 'b00001000011_01010_010_10101_0010011;

    #1

    // Check the result
    check_result('b00001000011, "I-type"); 

    // 7. SLTIU
    imm_type = 0;
    inst     = 'b111111000011_01010_011_10101_0010011;

    #1

    // Check the result
    check_result('b11111111111111111111_111111000011, "I-type");

    // 8. SRAI
    imm_type = 0;
    inst     = 'b0100000_01001_01010_101_10101_0010011;

    #1

    // Check the result
    check_result('b000000000000000000000_100000_01001, "I-type");  

    // 9. SRLI
    imm_type = 0;
    inst     = 'b0000000_10101_01010_101_10101_0010011;

    #1

    // Check the result
    check_result('b0000000_10101, "I-type");  

    // 10. SLLI
    imm_type = 0;
    inst     = 'b0000000_00101_01010_001_10101_0010011;

    #1

    // Check the result
    check_result('b0000000_00101, "I-type"); 

    // 11. LW
    imm_type = 0;
    inst     = 'b111111001001_10101_010_10101_0000011;

    #1

    // Check the result
    check_result('b11111111111111111111_111111001001, "I-type"); 

    // TODO: 12. JALR
  
    $finish();

  end

  task check_result(logic [31:0] expected, string immType);
    if (imm == expected) begin
      $display("%s immediate result is correct. Expected: %h, Actual: %h", immType, expected, imm); 
      pass();
    end else begin
      $display("%s immediate result is incorrect. Expected: %h, Actual: %h", immType, expected, imm); 
      fail(); 
      $finish();
    end
  endtask

endmodule
