//========================================================================
// utb_ProcDpathAlu
//========================================================================
// A basic Verilog unit test bench for the Processor ALU module

`default_nettype none
`timescale 1ps/1ps

`include "ProcDpathAlu.v"
`include "vc/trace.v"

//------------------------------------------------------------------------
// Top-level module
//------------------------------------------------------------------------

module top(   input logic clk ,  input logic linetrace  );

  logic [31:0] in0;
  logic [31:0] in1;
  logic [ 3:0] fn;

  logic [31:0] out;
  logic        ops_eq;
  logic        ops_lt;
  logic        ops_ltu;

  // Instantiate the processor ALU
  lab2_proc_ProcDpathAlu
  DUT
  ( .*
  ); 

  //----------------------------------------------------------------------
  // Run the Test Bench
  //----------------------------------------------------------------------

  initial begin
  $display("Starting ALU Testbench");

  @(negedge clk);

  //======================================
  // Test ADD
  //======================================

  // Test 1
  in0 = 5;
  in1 = 3;
  fn  = 0;
  #1
  check_result(in0 + in1, "ADD");

  // Test 2
  in0 = 0;
  in1 = 1;
  fn  = 0;
  #1
  check_result(in0 + in1, "ADD");

  // Test 3
  in0 = 32'b11111111_11111111_11111111_11111111;
  in1 = 0;
  fn  = 0;
  #1
  check_result(in0 + in1, "ADD");

  // Test 4
  in0 = 'b11111111111111111111111111111111;
  in1 = 'b11111111111111111111111111111111;
  fn  = 0;
  #1
  check_result(in0 + in1, "ADD");

  // Test 5
  in0 = 'b0011010100;
  in1 = 'hDEADBEEF;
  fn  = 0;
  #1
  check_result(in0 + in1, "ADD");

  // Test 6
  in0 = 'd3047821;
  in1 = 'd928374298;
  fn  = 0;
  #1
  check_result(in0 + in1, "ADD");

  //======================================
  // Test SUB
  //======================================

  // Test 1
  in0 = 5;
  in1 = -8;
  fn  = 1;
  #1
  check_result(in0 - in1, "SUB");

  // Test 2
  in0 = 10;
  in1 = 0;
  fn  = 1;
  #1
  check_result(in0 - in1, "SUB");

  // Test 3
  in0 = 5;
  in1 = -8;
  fn  = 1;
  #1
  check_result(in0 - in1, "SUB");

  // Test 4
  in0 = 10;
  in1 = 0;
  fn  = 1;
  #1
  check_result(in0 - in1, "SUB");

  // Test 5
  in0 = -'d208130;
  in1 = 'd2736;
  fn  = 1;
  #1
  check_result(in0 - in1, "SUB");

  // Test 6
  in0 = 'hDEADBEEF;
  in1 = 'hFEEBDAED;
  fn  = 1;
  #1
  check_result(in0 - in1, "SUB");

  //======================================
  // Test AND
  //======================================

  // Test 1
  in0 = 15;
  in1 = -8;
  fn  = 2;
  #1
  check_result(in0 & in1, "AND");

  // Test 2
  in0 = 'b11111111111111111111;
  in1 = 0;
  fn  = 2;
  #1
  check_result(in0 & in1, "AND");

  // Test 3
  in0 = 'hDEADBEEF;
  in1 = 'hCAFFE000;
  fn  = 2;
  #1
  check_result(in0 & in1, "AND");

  // Test 4
  in0 = 'd210938;
  in1 = -'d83947;
  fn  = 2;
  #1
  check_result(in0 & in1, "AND");

  // Test 5
  in0 = -'d111111111;
  in1 = 'd99999999;
  fn  = 2;
  #1
  check_result(in0 & in1, "AND");

  // Test 6
  in0 = 'h334F9EA;
  in1 = 'b100010101010101;
  fn  = 2;
  #1
  check_result(in0 & in1, "AND");

  //======================================
  // Test OR
  //======================================

  // Test 1
  in0 = 15; 
  in1 = -8;  
  fn  = 3;
  #1
  check_result(32'hFFFFFFFF, "OR");

  // Test 2
  in0 = 'b11111111111111111111;
  in1 = 0;
  fn  = 3;
  #1
  check_result('b11111111111111111111, "OR");

  // Test 3
  in0 = 'hDEADBEEF;
  in1 = 'hCAFFE000;
  fn  = 3;
  #1
  check_result('hDEFFFEEF, "OR");

  // Test 4
  in0 = 'd210938;
  in1 = -'d83947;
  fn  = 3;
  #1
  check_result('hffffbfff, "OR");

  // Test 5
  in0 = -'d111111111;
  in1 = 'd99999999;
  fn  = 3;
  #1
  check_result('hFDF5F4FF, "OR");

  // Test 6
  in0 = 'h334F9EA;
  in1 = 'b100010101010101;
  fn  = 3;
  #1
  check_result('h0334fdff, "OR");

  //======================================
  // Test XOR
  //======================================

  // Test 1
  in0 = 'b0000101011101; 
  in1 = 'b1010101010100;  
  fn  = 4;
  #1
  check_result('b1010000001001, "XOR");

  // Test 2
  in0 = 0;
  in1 = 'b111111111111111111111;
  fn  = 4;
  #1
  check_result('b111111111111111111111, "XOR");

  // Test 3
  in0 = 'hEEFADDB;
  in1 = 'h4399CAF;
  fn  = 4;
  #1
  check_result('h0ad63174, "XOR");

  // Test 4
  in0 = 'h4399;
  in1 = -'hCC98;
  fn  = 4;
  #1
  check_result('hffff70f1, "XOR");

  // Test 5
  in0 = -'d111111111;
  in1 = 'd99999999;
  fn  = 4;
  #1
  check_result('hfc9574c6, "XOR");

  // Test 6
  in0 = 'h72F9EA;
  in1 = 'b11100010101010101;
  fn  = 4;
  #1
  check_result('h00733cbf, "XOR");

  //======================================
  // Test SLT
  //======================================

  // Test 1
  in0 = 'b0000101011101; 
  in1 = 'b1010101010100;  
  fn  = 5;
  #1
  check_result(1, "SLT");

  // Test 2
  in0 = 0;
  in1 = 'b111011;
  fn  = 5;
  #1
  check_result(1, "SLT");

  // Test 3
  in0 = 'hEEFADDB;
  in1 = 'h4399CAF;
  fn  = 5;
  #1
  check_result(0, "SLT");

  // Test 4
  in0 = 'h4399;
  in1 = -'h778;
  fn  = 5;
  #1
  check_result(0, "SLT");

  // Test 5
  in0 = 'd111111111;
  in1 = 'd99999999;
  fn  = 5;
  #1
  check_result(0, "SLT");

  // Test 6
  in0 = 'd111111;
  in1 = 'd999999;
  fn  = 5;
  #1
  check_result(1, "SLT");

  // Test 7
  in0 = 'b01111111_11111111_11111111_11111111; 
  in1 = 'b11111111_11111111_11111111_11111111;  
  fn  = 5;
  #1
  check_result(0, "SLT");

  //======================================
  // Test SLTU
  //======================================

  // Test 1
  in0 = 'b01111111_11111111_11111111_11111111; 
  in1 = 'b11111111_11111111_11111111_11111111;  
  fn  = 6;
  #1
  check_result(1, "SLTU");

  // Test 2
  in0 = 0;
  in1 = 'b111011;
  fn  = 6;
  #1
  check_result(1, "SLTU");

  // Test 3
  in0 = 'hEEFADDB;
  in1 = 'h4399CAF;
  fn  = 6;
  #1
  check_result(0, "SLTU");

  // Test 4
  in0 = 'h4399; 
  in1 = -'h778;
  fn  = 6;
  #1
  check_result(1, "SLTU");

  // Test 5
  in0 = 'd111111111;
  in1 = 'd99999999;
  fn  = 6;
  #1
  check_result(0, "SLTU");

  // Test 6
  in0 = 'hDEADBEEF;
  in1 = 'd999999;
  fn  = 6;
  #1
  check_result(0, "SLTU");

  //======================================
  // Test SRA
  //======================================

  // Test 1
  in0 = 'b01111111_11111111_11111111_11111111; 
  in1 = 'b11111111_11111111_11111111_11_00011;  
  fn  = 7;
  #1
  check_result('b00001111111_11111111_11111111_11111, "SRA");

  // Test 2
  in0 = 0;
  in1 = 'b1110111111;
  fn  = 7;
  #1
  check_result(0, "SRA");

  // Test 3
  in0 = 'b0010101010;
  in1 = 'b111111111111111111111111111_00000;
  fn  = 7;
  #1
  check_result('b0010101010, "SRA");

  // Test 4
  in0 = 'h4399;
  in1 = 'b011111110001111111111001111_01010;
  fn  = 7;
  #1
  check_result('b0000000000_0000_0000_0000_0000_0100_00, "SRA");

  // Test 5
  in0 = 'hFFFFFFFF;
  in1 = 'd99999999;
  fn  = 7;
  #1
  check_result('hFFFFFFFF, "SRA");

  // Test 6
  in0 = 'b10000000000000000000000010101011;
  in1 = 'd16;
  fn  = 7;
  #1
  check_result('b11111111111111111000000000000000, "SRA");

  //======================================
  // Test SRL
  //======================================

  // Test 1
  in0 = 'b01111111_11111111_11111111_11111111; 
  in1 = 'b11111111_11111111_11111111_11_00011;  
  fn  = 8;
  #1
  check_result('b00001111111_11111111_11111111_11111, "SRL");

  // Test 2
  in0 = 0;
  in1 = 'b1110111111;
  fn  = 8;
  #1
  check_result(0, "SRL");

  // Test 3
  in0 = 'b10000000000000000000000001000000;
  in1 = 'b111111111111111111111111111_00100;
  fn  = 8;
  #1
  check_result('b00001000000000000000000000000100, "SRL");

  // Test 4
  in0 = 'h4399;
  in1 = 'b011111110001111111111001111_01010;
  fn  = 8;
  #1
  check_result('b0000000000_0000_0000_0000_0000_0100_00, "SRL");

  // Test 5
  in0 = 'hFFFFFFFF;
  in1 = 'hFFFFFFFF;
  fn  = 8;
  #1
  check_result(1, "SRL");

  // Test 6
  in0 = 'b10000000000000000000000010101011;
  in1 = 'd16;
  fn  = 8;
  #1
  check_result('b01000000000000000, "SRL");

  //======================================
  // Test SLL
  //======================================

  // Test 1
  in0 = 'b01111111_11111111_11111111_11111111; 
  in1 = 'b11111111_11111111_11111111_11_00011;  
  fn  = 9;
  #1
  check_result('b11111111_11111111_11111111_11111000, "SLL");

  // Test 2
  in0 = 0;
  in1 = 'b111111111;
  fn  = 9;
  #1
  check_result(0, "SLL");

  // Test 3
  in0 = 'b10000001110000000000000001000000;
  in1 = 'b111111111111111111111111111_00100;
  fn  = 9;
  #1
  check_result('b00011100000000000000010000000000, "SLL");

  // Test 4
  in0 = 'h4399;
  in1 = 'b011111110001111111111001111_01010;
  fn  = 9;
  #1
  check_result('h010e6400, "SLL");

  // Test 5
  in0 = 'hFFFFFFFF;
  in1 = 'hFFFFFFFF;
  fn  = 9;
  #1
  check_result('b10000000000000000000000000000000, "SLL");

  // Test 6
  in0 = 'b10000000000000000000000010101011;
  in1 = 'd14;
  fn  = 9;
  #1
  check_result('b00000000001010101100000000000000, "SLL");

  //======================================
  // Test JALR
  //======================================

  // Test 1
  in0 = 'b01100010_11101011_1111000000110001; 
  in1 = 'b11111111_11111111_1111111111001010;
  fn  = 10;
  #1
  check_result('b01100010_11101011_1110111111111011 & 'hfffffffe, "JALR");

  // Test 2
  in0 = 0;
  in1 = 'b111111111;
  fn  = 10;
  #1
  check_result('h000001fe, "JALR");

  // Test 3
  in0 = 'b10000001110000000000000001000000;
  in1 = 'b111111111111111111111111111_00100;
  fn  = 10;
  #1
  check_result('h81c00024, "JALR");

  // Test 4
  in0 = 'h4399;
  in1 = 'b011111110001111111111001111_01010;
  fn  = 10;
  #1
  check_result('h7f203d82, "JALR");

  // Test 5
  in0 = 'hFFFFFFFF;
  in1 = 'hFFFFFFFF;
  fn  = 10;
  #1
  check_result('hfffffffe, "JALR");

  // Test 6
  in0 = 'b10000000000000000000000010101011;
  in1 = 'd14;
  fn  = 10;
  #1
  check_result('h800000b8, "JALR");

  //======================================
  // Test CP0
  //======================================

  // Test 1
  in0 = 'b01100010_11101011_1111000000110001; 
  in1 = 'b11111111_11111111_1111111111001010;
  fn  = 11;
  #1
  check_result('b01100010_11101011_1111000000110001, "CP0");

  // Test 2
  in0 = 0;
  in1 = 'b111111111;
  fn  = 11;
  #1
  check_result(0, "CP0");

  // Test 3
  in0 = 'b10000001110000000000000001000000;
  in1 = 'b111111111111111111111111111_00100;
  fn  = 11;
  #1
  check_result('b10000001110000000000000001000000, "CP0");

  // Test 4
  in0 = 'h4399;
  in1 = 'b011111110001111111111001111_01010;
  fn  = 11;
  #1
  check_result('h4399, "CP0");

  // Test 5
  in0 = 'hFFFFFFFF;
  in1 = 'hFFFFFFFF;
  fn  = 11;
  #1
  check_result('hFFFFFFFF, "CP0");

  // Test 6
  in0 = 'b10000000000000000000000010101011;
  in1 = 'd14;
  fn  = 11;
  #1
  check_result('b10000000000000000000000010101011, "CP0");

//======================================
  // Test CP1
  //======================================

  // Test 1
  in0 = 'b01100010_11101011_1111000000110001; 
  in1 = 'b11111111_11111111_1111111111001010;
  fn  = 12;
  #1
  check_result('b11111111_11111111_1111111111001010, "CP1");

  // Test 2
  in0 = 0;
  in1 = 'b111111111;
  fn  = 12;
  #1
  check_result('b111111111, "CP1");

  // Test 3
  in0 = 'b10000001110000000000000001000000;
  in1 = 'b111111111111111111111111111_00100;
  fn  = 12;
  #1
  check_result('b111111111111111111111111111_00100, "CP1");

  // Test 4
  in0 = 'h4399;
  in1 = 'b011111110001111111111001111_01010;
  fn  = 12;
  #1
  check_result('b011111110001111111111001111_01010, "CP1");

  // Test 5
  in0 = 'hFFFFFFFF;
  in1 = 'hFFFFFFFF;
  fn  = 12;
  #1
  check_result('hFFFFFFFF, "CP1");

  // Test 6
  in0 = 'b10000000000000000000000010101011;
  in1 = 'd14;
  fn  = 12;
  #1
  check_result('d14, "CP1");


  $finish();
  end

    task check_result(logic [31:0] expected, string operation);
    if(out == expected) begin
        $display("%s result is correct. Expected: %h, Actual: %h", operation, expected, out);
        pass();
    end else begin
        $display("%s result is incorrect. Expected: %h, Actual: %h", operation, expected, out);
        fail(); 
        $finish();
    end
    endtask


endmodule
