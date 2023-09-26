//      // verilator_coverage annotation
        //=========================================================================
        // Integer Multiplier Variable-Latency Helper Implementation
        //=========================================================================
        
        `ifndef LAB1_IMUL_INT_MUL_HELPER
        `define LAB1_IMUL_INT_MUL_HELPER
        
        // verilator lint_off WIDTHEXPAND
        
        module lab1_imul_IntMulHelper(
 000030   input  logic [31:0] b_to_shift,
 000036   output logic [5:0]  shift_bits
        );
        
 000808 always_comb begin
 000808   shift_bits = 1;
 000178   if(b_to_shift == 0)
 000178     shift_bits = 32;
 000002   else if(b_to_shift[30:0] == 0) 
 000002     shift_bits = 31;
 000002   else if(b_to_shift[29:0] == 0) 
 000002     shift_bits = 30;
 000002   else if(b_to_shift[28:0] == 0) 
 000002     shift_bits = 29;
 000002   else if(b_to_shift[27:0] == 0) 
 000002     shift_bits = 28;
 000002   else if(b_to_shift[26:0] == 0) 
 000002     shift_bits = 27;
 000002   else if(b_to_shift[25:0] == 0) 
 000002     shift_bits = 26;
 000002   else if(b_to_shift[24:0] == 0) 
 000002     shift_bits = 25;
 000002   else if(b_to_shift[23:0] == 0) 
 000002     shift_bits = 24;
 000002   else if(b_to_shift[22:0] == 0) 
 000002     shift_bits = 23;
 000002   else if(b_to_shift[21:0] == 0) 
 000002     shift_bits = 22;
 000004   else if(b_to_shift[20:0] == 0) 
 000004     shift_bits = 21;
 000002   else if(b_to_shift[19:0] == 0) 
 000002     shift_bits = 20;
 000002   else if(b_to_shift[18:0] == 0) 
 000002     shift_bits = 19;
 000002   else if(b_to_shift[17:0] == 0) 
 000002     shift_bits = 18;
 000002   else if(b_to_shift[16:0] == 0) 
 000002     shift_bits = 17;
 000003   else if(b_to_shift[15:0] == 0) 
 000003     shift_bits = 16;
 000002   else if(b_to_shift[14:0] == 0) 
 000002     shift_bits = 15;
 000004   else if(b_to_shift[13:0] == 0) 
 000004     shift_bits = 14;
 000001   else if(b_to_shift[12:0] == 0) 
 000001     shift_bits = 13;
 000003   else if(b_to_shift[11:0] == 0) 
 000003     shift_bits = 12;
 000002   else if(b_to_shift[10:0] == 0) 
 000002     shift_bits = 11;
 000002   else if(b_to_shift[9:0] == 0) 
 000002     shift_bits = 10;
 000008   else if(b_to_shift[8:0] == 0) 
 000008     shift_bits = 9;
 000002   else if(b_to_shift[7:0] == 0) 
 000002     shift_bits = 8;
 000002   else if(b_to_shift[6:0] == 0) 
 000002     shift_bits = 7;
 000002   else if(b_to_shift[5:0] == 0) 
 000002     shift_bits = 6;
 000005   else if(b_to_shift[4:0] == 0) 
 000005     shift_bits = 5;
 000005   else if(b_to_shift[3:0] == 0) 
 000005     shift_bits = 4;
 000013   else if(b_to_shift[2:0] == 0) 
 000013     shift_bits = 3;
 000029   else if(b_to_shift[1:0] == 0) 
 000029     shift_bits = 2;
        end
        
        endmodule
        
        // verilator lint_on WIDTHEXPAND
        
        `endif /* LAB1_IMUL_INT_MUL_HELPER */
        
