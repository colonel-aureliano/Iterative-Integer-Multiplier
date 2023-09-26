//      // verilator_coverage annotation
        //========================================================================
        // Verilog Components: Registers
        //========================================================================
        
        // Note that we place the register output earlier in the port list since
        // this is one place we might actually want to use positional port
        // binding like this:
        //
        //  logic [p_nbits-1:0] result_B;
        //  vc_Reg#(p_nbits) result_AB( clk, result_B, result_A );
        
        `ifndef VC_REGS_V
        `define VC_REGS_V
        
        //------------------------------------------------------------------------
        // Postive-edge triggered flip-flop
        //------------------------------------------------------------------------
        
        module vc_Reg
        #(
          parameter p_nbits = 1
        )(
          input  logic               clk, // Clock input
          output logic [p_nbits-1:0] q,   // Data output
          input  logic [p_nbits-1:0] d    // Data input
        );
        
          always_ff @( posedge clk )
            q <= d;
        
        endmodule
        
        //------------------------------------------------------------------------
        // Postive-edge triggered flip-flop with reset
        //------------------------------------------------------------------------
        
        module vc_ResetReg
        #(
          parameter p_nbits       = 1,
          parameter p_reset_value = 0
        )(
 003234   input  logic               clk,   // Clock input
 000002   input  logic               reset, // Sync reset input
 000158   output logic [p_nbits-1:0] q,     // Data output
 000158   input  logic [p_nbits-1:0] d      // Data input
        );
        
 001616   always_ff @( posedge clk )
 001616     q <= reset ? p_reset_value : d;
        
        endmodule
        
        //------------------------------------------------------------------------
        // Postive-edge triggered flip-flop with enable
        //------------------------------------------------------------------------
        
        module vc_EnReg
        #(
          parameter p_nbits = 1
        )(
 001617   input  logic               clk,   // Clock input
 000001   input  logic               reset, // Sync reset input
 000024   output logic [p_nbits-1:0] q,     // Data output
 000024   input  logic [p_nbits-1:0] d,     // Data input
 000358   input  logic               en     // Enable input
        );
        
 000808   always_ff @( posedge clk )
 000243     if ( en )
 000565       q <= d;
        
          // Assertions
        
          `ifndef SYNTHESIS
        
          /*
          always_ff @( posedge clk )
            if ( !reset )
              `VC_ASSERT_NOT_X( en );
          */
        
          `endif /* SYNTHESIS */
        
        endmodule
        
        //------------------------------------------------------------------------
        // Postive-edge triggered flip-flop with enable and reset
        //------------------------------------------------------------------------
        
        module vc_EnResetReg
        #(
          parameter p_nbits       = 1,
          parameter p_reset_value = 0
        )(
 003234   input  logic               clk,   // Clock input
 000002   input  logic               reset, // Sync reset input
 000002   output logic [p_nbits-1:0] q,     // Data output
 000002   input  logic [p_nbits-1:0] d,     // Data input
 000110   input  logic               en     // Enable input
        );
        
 001616   always_ff @( posedge clk )
 000063     if ( reset || en )
 000063       q <= reset ? p_reset_value : d;
        
          // Assertions
        
          `ifndef SYNTHESIS
        
          /*
          always_ff @( posedge clk )
            if ( !reset )
              `VC_ASSERT_NOT_X( en );
          */
        
          `endif /* SYNTHESIS */
        
        endmodule
        
        `endif /* VC_REGS_V */
        
        
