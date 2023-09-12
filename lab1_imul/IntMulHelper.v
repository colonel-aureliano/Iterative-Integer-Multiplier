//=========================================================================
// Integer Multiplier Variable-Latency Helper Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_HELPER
`define LAB1_IMUL_INT_MUL_HELPER

// verilator lint_off WIDTHEXPAND

module lab1_imul_IntMulHelper(
  input  logic [31:0] b_to_shift,
  output logic [5:0]  shift_bits
);

always_comb begin
  shift_bits = 1;
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

endmodule

// verilator lint_on WIDTHEXPAND

`endif /* LAB1_IMUL_INT_MUL_HELPER */
