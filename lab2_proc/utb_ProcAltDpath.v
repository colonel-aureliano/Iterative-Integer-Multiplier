//========================================================================
// utb_ProcAltDpath
//========================================================================
// A basic Verilog unit test bench for the Processor Alternative Datapath module

`default_nettype none
`timescale 1ps/1ps


`include "ProcAltDpath.v"
`include "vc/trace.v"

//------------------------------------------------------------------------
// Top-level module
//------------------------------------------------------------------------

module top(  input logic clk, input logic linetrace );

  logic         reset;

  // Instruction Memory Port

  logic [31:0]  imem_reqstream_msg_addr;
  mem_resp_4B_t imem_respstream_msg;

  // Data Memory Port

  logic [31:0]  dmem_reqstream_msg_addr;
  logic [31:0]  dmem_reqstream_msg_data;
  logic [31:0]  dmem_respstream_msg_data;

  // mngr communication ports

  logic [31:0]  mngr2proc_data;
  logic [31:0]  proc2mngr_data;

  // control signals (ctrl->dpath)
  logic         imem_respstream_drop;
  logic         reg_en_F;
  logic [1:0]   pc_sel_F;

  logic         reg_en_D;
  logic         op1_sel_D;
  logic [1:0]   op2_sel_D;
  logic [1:0]   csrr_sel_D;
  logic [2:0]   imm_type_D;
  logic         imul_istream_val_D;

  logic         reg_en_X;
  logic [3:0]   alu_fn_X;
  logic [1:0]   ex_result_sel_X;
  logic         imul_ostream_rdy_X;

  logic         reg_en_M;
  logic         wb_result_sel_M;

  logic         reg_en_W;
  logic [4:0]   rf_waddr_W;
  logic         rf_wen_W;
  logic         stats_en_wen_W;

  // status signals (dpath->ctrl)

  logic [31:0]  inst_D;
  logic         imul_istream_rdy_D;

  logic         imul_ostream_val_X;
  logic         br_cond_eq_X;
  logic         br_cond_lt_X;
  logic         br_cond_ltu_X;

  // extra ports

  logic [31:0]  core_id;
  logic         stats_en;


  //----------------------------------------------------------------------
  // Module instantiations
  //----------------------------------------------------------------------
  
  // Instantiate the processor datapath
  lab2_proc_ProcAltDpath 
  #(
    .p_num_cores( 1)
  )
  DUT
  ( .*
  ); 

  //----------------------------------------------------------------------
  // Run the Test Bench
  //----------------------------------------------------------------------

  initial begin

    $display("Start of Testbench");
    // Initalize all the signal inital values.
    imem_respstream_msg.type_ = `VC_MEM_RESP_MSG_TYPE_READ;
    imem_respstream_msg.opaque = 8'b0;
    imem_respstream_msg.test = 2'b0;
    imem_respstream_msg.len    = 2'd0;
    imem_respstream_msg.data   = 'hDEADBEEF;
    dmem_respstream_msg_data = '0;
    mngr2proc_data= '0;
    imem_respstream_drop = '0;
    reg_en_F = 1;
    pc_sel_F = '0;
    reg_en_D = 1;
    op1_sel_D = 0;
    op2_sel_D = '0;
    csrr_sel_D = '0;
    imm_type_D = '0;
    imul_istream_val_D = '0;
    reg_en_X =1;
    alu_fn_X =0;
    ex_result_sel_X =0;
    imul_ostream_rdy_X =0;
    reg_en_M =1;
    wb_result_sel_M =0;
    reg_en_W =1;
    rf_waddr_W ='0;
    rf_wen_W = '0;
    stats_en_wen_W =0;
    core_id = '0;
    reset = 1;
    #10

    //--------------------------------------------------------------------
    // Unit Testing #1  If PC is working correctly across the pipeline + a JAL
    //--------------------------------------------------------------------
    // Align test bench with negedge so that it looks better
    @(negedge clk); 
    reset = 0;
    @(negedge clk); 
    $display( "Advancing time");
    // Checking F stage D/X stages are invalid
    assert(DUT.pc_F == 'h200) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_F); fail(); $finish();
    end 
    //Advancing time
    $display( "Advancing time");
    @(negedge clk); 
    // Checking F/D stage X stage is invalid
    assert(DUT.pc_F == 'h204) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_F);pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h200) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_D);pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_D); fail(); $finish();
    end 
    //Advancing time
    $display( "Advancing time");
    @(negedge clk); 
     // Checking F/D/X stage 
    assert(DUT.pc_F == 'h208) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h208,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h208,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h204) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_D);  pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_D); fail(); $finish();
    end 
    assert(DUT.pc_X == 'h200) begin
      $display("pc_X is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_X);  pass();
    end else begin
      $display("pc_X is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_X); fail(); $finish();
    end 
    // Setting Branch 
    imm_type_D = 4; // J-type imm-type
    pc_sel_F = 2; // J-type imm-type
    
    //Advancing time
    $display( "Advancing time with J imm jump on D stage");
    @(negedge clk); 
     // Checking F/D/X stage 
    assert(DUT.pc_F == 'hfffdb7ee) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'hfffdb7ee,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'hfffdb7ee,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h208) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h208,DUT.pc_D);  pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h208,DUT.pc_D); fail(); $finish();
    end 
    assert(DUT.pc_X == 'h204) begin
      $display("pc_X is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_X);  pass();
    end else begin
      $display("pc_X is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_X); fail(); $finish();
    end 

    #50

    $display("ADDI instruction testing");
    // Initalize all the signal inital values.
    imem_respstream_msg.type_ = `VC_MEM_RESP_MSG_TYPE_READ;
    imem_respstream_msg.opaque = 8'b0;
    imem_respstream_msg.test = 2'b0;
    imem_respstream_msg.len    = 2'd0;
    imem_respstream_msg.data   = 32'b000000000001_00001_000_00010_0010011;
    dmem_respstream_msg_data = '0;
    mngr2proc_data= '0;
    imem_respstream_drop = '0;
    reg_en_F = 1;
    pc_sel_F = '0;
    reg_en_D = 1;
    op1_sel_D = 0;
    op2_sel_D = '0;
    csrr_sel_D = '0;
    imm_type_D = '0;
    imul_istream_val_D = '0;
    reg_en_X =1;
    alu_fn_X =0;
    ex_result_sel_X =0;
    imul_ostream_rdy_X =0;
    reg_en_M =1;
    wb_result_sel_M =0;
    reg_en_W =1;
    rf_waddr_W ='0;
    rf_wen_W = '0;
    stats_en_wen_W =0;
    core_id = '0;
    reset = 1;
    #10

    //--------------------------------------------------------------------
    // Unit Testing #2  If PC is working correctly across the pipeline + an ADDI
    //--------------------------------------------------------------------
    // Align test bench with negedge so that it looks better
    @(negedge clk); 
    reset = 0;
    @(negedge clk); 
    $display( "Advancing time");
    // Checking F stage D/X stages are invalid
    assert(DUT.pc_F == 'h200) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_F); fail(); $finish();
    end 
    //Advancing time
    $display( "Advancing time");
    @(negedge clk); 
    // Checking F/D stage X stage is invalid
    assert(DUT.pc_F == 'h204) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_F);pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h200) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_D);pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_D); fail(); $finish();
    end 
    assert(DUT.inst_rd_D == 5'b00010) begin
      $display("inst_rd_D is correct.  Expected: %b, Actual: %b", 5'b00010,DUT.inst_rd_D);pass();
    end else begin
      $display("inst_rd_D is incorrect.  Expected: %b, Actual: %b", 'b00010,DUT.inst_rd_D); fail(); $finish();
    end 
    assert(DUT.imm_D == 32'b01) begin
      $display("imm_D is correct.  Expected: %b, Actual: %b", 'b01,DUT.imm_D);pass();
    end else begin
      $display("imm_D is incorrect.  Expected: %b, Actual: %b", 'b01,DUT.imm_D); fail(); $finish();
    end 
    //Advancing time
    $display( "Advancing time");
    @(negedge clk); 
     // Checking F/D/X stage 
    assert(DUT.pc_F == 'h208) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h208,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h208,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h204) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_D);  pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_D); fail(); $finish();
    end 
    assert(DUT.pc_X == 'h200) begin
      $display("pc_X is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_X);  pass();
    end else begin
      $display("pc_X is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_X); fail(); $finish();
    end 

    op2_sel_D  = 2'b01; // choose sext(imm)
    imm_type_D = '0; // I-type imm-type
    
    //Advancing time
    $display( "Advancing time with J imm jump on D stage");
    @(negedge clk); 
     // Checking F/D/X stage 
    assert(DUT.pc_F == 'h20c) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'hfffdb7ee,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'hfffdb7ee,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h208) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h208,DUT.pc_D);  pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h208,DUT.pc_D); fail(); $finish();
    end 
    assert(DUT.pc_X == 'h204) begin
      $display("pc_X is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_X);  pass();
    end else begin
      $display("pc_X is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_X); fail(); $finish();
    end 
    assert(DUT.ex_result_X == 'b1) begin
      $display("ex_result_X is correct.  Expected: %b, Actual: %b", 'b1,DUT.ex_result_X); pass();
    end else begin
      $display("ex_result_X is incorrect.  Expected: %h, Actual: %h", 'b1,DUT.ex_result_X); fail(); $finish();
    end 
    assert(DUT.op1_X == 'b0) begin
      $display("op1_X is correct.  Expected: %b, Actual: %b", 'b0,DUT.op1_X);pass();
    end else begin
      $display("op1_X is incorrect.  Expected: %b, Actual: %b", 'b0,DUT.op1_X); fail(); $finish();
    end

    //Advancing time
    $display( "Advancing time with write back");
    @(negedge clk); 
    @(negedge clk);
    // Checking W stage 
    assert(DUT.rf_wdata_W == 'b1) begin
      $display("rf_wdata_W is correct.  Expected: %b, Actual: %b", 'b1,DUT.rf_wdata_W);pass();
    end else begin
      $display("rf_wdata_W is incorrect.  Expected: %b, Actual: %b", 'b1,DUT.rf_wdata_W); fail(); $finish();
    end

    #50

    $display("ANDI instruction testing");
    // Initalize all the signal inital values.
    imem_respstream_msg.type_ = `VC_MEM_RESP_MSG_TYPE_READ;
    imem_respstream_msg.opaque = 8'b0;
    imem_respstream_msg.test = 2'b0;
    imem_respstream_msg.len    = 2'd0;
    imem_respstream_msg.data   = 32'b010101010101_00001_111_00010_0010011;
    dmem_respstream_msg_data = '0;
    mngr2proc_data= '0;
    imem_respstream_drop = '0;
    reg_en_F = 1;
    pc_sel_F = '0;
    reg_en_D = 1;
    op1_sel_D = 0;
    op2_sel_D = '0;
    csrr_sel_D = '0;
    imm_type_D = '0;
    imul_istream_val_D = '0;
    reg_en_X =1;
    alu_fn_X =0;
    ex_result_sel_X =0;
    imul_ostream_rdy_X =0;
    reg_en_M =1;
    wb_result_sel_M =0;
    reg_en_W =1;
    rf_waddr_W ='0;
    rf_wen_W = '0;
    stats_en_wen_W =0;
    core_id = '0;
    reset = 1;
    
    #10

    //--------------------------------------------------------------------
    // Unit Testing #3 ANDI
    //--------------------------------------------------------------------
    // Align test bench with negedge so that it looks better
    @(negedge clk); 
    reset = 0;
    @(negedge clk); 
    $display( "Advancing time");
    // Checking F stage D/X stages are invalid
    assert(DUT.pc_F == 'h200) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_F); fail(); $finish();
    end 
    //Advancing time
    $display( "Advancing time");
    @(negedge clk); 
    // Checking F/D stage X stage is invalid
    assert(DUT.pc_F == 'h204) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_F);pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h200) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_D);pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_D); fail(); $finish();
    end 
    assert(DUT.inst_rd_D == 5'b00010) begin
      $display("inst_rd_D is correct.  Expected: %b, Actual: %b", 5'b00010,DUT.inst_rd_D);pass();
    end else begin
      $display("inst_rd_D is incorrect.  Expected: %b, Actual: %b", 'b00010,DUT.inst_rd_D); fail(); $finish();
    end 
    assert(DUT.imm_D == 32'b010101010101) begin
      $display("imm_D is correct.  Expected: %b, Actual: %b", 'b010101010101,DUT.imm_D);pass();
    end else begin
      $display("imm_D is incorrect.  Expected: %b, Actual: %b", 'b010101010101,DUT.imm_D); fail(); $finish();
    end 
    //Advancing time
    $display( "Advancing time");
    @(negedge clk); 
     // Checking F/D/X stage 
    assert(DUT.pc_F == 'h208) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h208,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h208,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h204) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_D);  pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_D); fail(); $finish();
    end 
    assert(DUT.pc_X == 'h200) begin
      $display("pc_X is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_X);  pass();
    end else begin
      $display("pc_X is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_X); fail(); $finish();
    end 

    op2_sel_D  = 2'b01; // choose sext(imm)
    imm_type_D = '0; // I-type imm-type
    alu_fn_X   = 4'd2;   // ALU AND
    
    //Advancing time
    $display( "Advancing time with J imm jump on D stage");
    @(negedge clk); 
     // Checking F/D/X stage 
    assert(DUT.pc_F == 'h20c) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'hfffdb7ee,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'hfffdb7ee,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h208) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h208,DUT.pc_D);  pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h208,DUT.pc_D); fail(); $finish();
    end 
    assert(DUT.pc_X == 'h204) begin
      $display("pc_X is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_X);  pass();
    end else begin
      $display("pc_X is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_X); fail(); $finish();
    end 
    assert(DUT.ex_result_X == 'b0) begin
      $display("ex_result_X is correct.  Expected: %b, Actual: %b", 'b1,DUT.ex_result_X); pass();
    end else begin
      $display("ex_result_X is incorrect.  Expected: %h, Actual: %h", 'b1,DUT.ex_result_X); fail(); $finish();
    end 

    //Advancing time
    $display( "Advancing time with write back");
    @(negedge clk); 
    @(negedge clk);
    // Checking W stage 
    assert(DUT.rf_wdata_W == 'b0) begin
      $display("rf_wdata_W is correct.  Expected: %b, Actual: %b", 'b0,DUT.rf_wdata_W);pass();
    end else begin
      $display("rf_wdata_W is incorrect.  Expected: %b, Actual: %b", 'b0,DUT.rf_wdata_W); fail(); $finish();
    end

    #50

    $display("ORI instruction testing");
    // Initalize all the signal inital values.
    imem_respstream_msg.type_ = `VC_MEM_RESP_MSG_TYPE_READ;
    imem_respstream_msg.opaque = 8'b0;
    imem_respstream_msg.test = 2'b0;
    imem_respstream_msg.len    = 2'd0;
    imem_respstream_msg.data   = 32'b101010101001_00001_110_00010_0010011;
    dmem_respstream_msg_data = '0;
    mngr2proc_data= '0;
    imem_respstream_drop = '0;
    reg_en_F = 1;
    pc_sel_F = '0;
    reg_en_D = 1;
    op1_sel_D = 0;
    op2_sel_D = '0;
    csrr_sel_D = '0;
    imm_type_D = '0;
    imul_istream_val_D = '0;
    reg_en_X =1;
    alu_fn_X =0;
    ex_result_sel_X =0;
    imul_ostream_rdy_X =0;
    reg_en_M =1;
    wb_result_sel_M =0;
    reg_en_W =1;
    rf_waddr_W ='0;
    rf_wen_W = '0;
    stats_en_wen_W =0;
    core_id = '0;
    reset = 1;
    #10

    //--------------------------------------------------------------------
    // Unit Testing #4 ORI
    //--------------------------------------------------------------------
    // Align test bench with negedge so that it looks better
    @(negedge clk); 
    reset = 0;
    @(negedge clk); 
    $display( "Advancing time");
    // Checking F stage D/X stages are invalid
    assert(DUT.pc_F == 'h200) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_F); fail(); $finish();
    end 
    
    //Advancing time
    $display( "Advancing time");
    @(negedge clk); 
    // Checking F/D stage X stage is invalid
    assert(DUT.pc_F == 'h204) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_F);pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h200) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_D);pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_D); fail(); $finish();
    end 
    assert(DUT.inst_rd_D == 5'b00010) begin
      $display("inst_rd_D is correct.  Expected: %b, Actual: %b", 5'b00010,DUT.inst_rd_D);pass();
    end else begin
      $display("inst_rd_D is incorrect.  Expected: %b, Actual: %b", 'b00010,DUT.inst_rd_D); fail(); $finish();
    end 
    assert(DUT.imm_D == 'b11111111111111111111101010101001) begin
      $display("imm_D is correct.  Expected: %b, Actual: %b", 'b11111111111111111111101010101001,DUT.imm_D);pass();
    end else begin
      $display("imm_D is incorrect.  Expected: %b, Actual: %b", 'b11111111111111111111101010101001,DUT.imm_D); fail(); $finish();
    end 

    //Advancing time
    $display( "Advancing time");
    @(negedge clk); 
    // Checking F/D/X stage 
    assert(DUT.pc_F == 'h208) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h208,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'h208,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h204) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_D);  pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_D); fail(); $finish();
    end 
    assert(DUT.pc_X == 'h200) begin
      $display("pc_X is correct.  Expected: %h, Actual: %h", 'h200,DUT.pc_X);  pass();
    end else begin
      $display("pc_X is incorrect.  Expected: %h, Actual: %h", 'h200,DUT.pc_X); fail(); $finish();
    end 
    
    op2_sel_D  = 2'b01; // choose sext(imm)
    imm_type_D = '0; // I-type imm-type
    alu_fn_X   = 4'd3;   // ALU ORI

    //Advancing time
    $display( "Advancing time");
    @(negedge clk); 
     // Checking F/D/X stage 
    assert(DUT.pc_F == 'h20c) begin
      $display("pc_F is correct.  Expected: %h, Actual: %h", 'h20c,DUT.pc_F); pass();
    end else begin
      $display("pc_F is incorrect.  Expected: %h, Actual: %h", 'hfffdb7ee,DUT.pc_F); fail(); $finish();
    end 
    assert(DUT.pc_D == 'h208) begin
      $display("pc_D is correct.  Expected: %h, Actual: %h", 'h208,DUT.pc_D);  pass();
    end else begin
      $display("pc_D is incorrect.  Expected: %h, Actual: %h", 'h208,DUT.pc_D); fail(); $finish();
    end 
    assert(DUT.pc_X == 'h204) begin
      $display("pc_X is correct.  Expected: %h, Actual: %h", 'h204,DUT.pc_X);  pass();
    end else begin
      $display("pc_X is incorrect.  Expected: %h, Actual: %h", 'h204,DUT.pc_X); fail(); $finish();
    end 
    assert(DUT.ex_result_X == 'b11111111111111111111101010101001) begin
      $display("ex_result_X is correct.  Expected: %b, Actual: %b", 'b11111111111111111111101010101001,DUT.ex_result_M); pass();
    end else begin
      $display("ex_result_X is incorrect.  Expected: %h, Actual: %h", 'b11111111111111111111101010101001,DUT.ex_result_M); fail(); $finish();
    end 

    //Advancing time
    $display( "Advancing time");
    @(negedge clk);
    // assert(DUT.rf_wdata_W == 'b11111111111111111111101010101001) begin
    //   $display("rf_wdata_W is correct.  Expected: %b, Actual: %b", 'b11111111111111111111101010101001,DUT.rf_wdata_W); pass();
    // end else begin
    //   $display("rf_wdata_W is incorrect.  Expected: %h, Actual: %h", 'b11111111111111111111101010101001,DUT.rf_wdata_W); fail(); $finish();
    // end 
  
    $finish();

  end

endmodule
