`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:04:19 02/14/2016 
// Design Name: 
// Module Name:    Single_Cycle_Processor 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`include "pc_block.v"
`include "fetch.v"
`include "adder.v"
`include "reg_file.v"
`include "sz_ex.v"
`include "ctrl.v"
`include "Exec.v"
// `include "ram.v"

`define REG1_MSB 19
`define REG1_LSB 15
`define REG2_MSB 24
`define REG2_LSB 20
`define DST_REG_MSB 11
`define DST_REG_LSB 7
`define DATA_MEM_WORD_SIZE 8 // 16, 32 etc
module Single_Cycle_Processor(
    input rst_t,
    input clk_t
    );
	 
	 // Instantiation of PC_BLOCK
    wire [`REGISTER_WIDTH-1:0] next_addr_t ;
    reg [`REGISTER_WIDTH-1:0] curr_addr_t ;
	 
    pc_block  pc_bloc_t ( .rst_t(rst), .clk_t(clk) ,
                       .next_addr_t(next_addr) , .curr_addr_t(curr_addr));
  
    //Instantiation of fetch module
    reg [`REGISTER_WIDTH-1:0] Instruction ;
	 
	 rom rom_t ( .clk_t(clk) , .rst_t(rst) , .curr_addr_t(ProgramCounter) ,
	             .Instruction(InstructionRegister));
 
    //Instantiation of adder
	 reg [`REGISTER_WIDTH-1:0] val_2_PC_adder = 32'd4;
	 reg [`REGISTER_WIDTH-1:0] Add_4_Out_t;
	 
	 adder adder_t (. curr_addr_t( val_1) , .val_2_PC_adder(val_2) , .Add_4_Out_t(out));


    //Instantiation of Control Unit 
    reg [(`ALU_CTRL_WIDTH-1):0] alu_ctrl_t ;	
    reg reg_file_wr_en_t , d_mem_rd_en_t , alu_op2_sel_t , d_mem_wr_en_t;
    reg [1:0] reg_file_wr_back_sel_t ;
	 reg [2:0] d_mem_size_t;
	 reg jal_t , jalr_t ;
	 
	 ctrl ctrl_t ( .Instruction(inst) , .jal_t(jal) , .jalr_t(jalr_t) , .d_mem_size_t(d_mem_size) ,
	               .reg_file_wr_back_sel_t(reg_file_wr_back_sel) , .d_mem_wr_en_t(d_mem_wr_en) ,
		       .alu_op2_sel_t(alu_op2_sel) , .d_mem_rd_en_t(d_mem_rd_en) , .reg_file_wr_en_t(reg_file_wr_en),
		       .alu_ctrl_t(alu_ctrl) ) ;
						
						
    //Instantiation of register file 
	 reg [`REGISTER_WIDTH-1:0] reg_data_1_t , reg_data_2_t , wr_reg_data_t;
	 //wire wr_en_t ==  reg_file_wr_en_t ;
	 wire [(`REG_INDEX_WIDTH-1):0] rd_reg_index_1_t = Instruction[`REG1_MSB :`REG1_LSB] ;
	 wire [(`REG_INDEX_WIDTH-1):0] rd_reg_index_2_t= Instruction[`REG2_MSB :`REG2_LSB] ;
	 wire [(`REG_INDEX_WIDTH-1):0] wr_reg_index_t = Instruction[`DST_REG_MSB :`DST_REG_LSB] ;
	 
	 reg_file reg_file_t ( .reg_data_1_t(reg_data_1) , .reg_data_2_t(reg_data_2) ,
                               .rst_t(rst) , .clk_t(clk) , .reg_file_wr_en_t(wr_en) ,.rd_reg_index_1_t(rd_reg_index_1) ,
                               .rd_reg_index_2_t(rd_reg_index_2) , .wr_reg_index_t(wr_reg_index) , 
                               .wr_reg_data_t(wr_reg_data));	
								 
								 
	 // Instantiation of sign extend module
	 reg [(`OPERAND_WIDTH - 1):0] sz_ex_val_t ;
	 
    sz_ex sz_ex_t ( .Instruction(inst) , .sz_ex_val_t(sz_ex_val));
	 
	 
	  // Implementation of 2:1 MUX 
	 
	 reg [`REGISTER_WIDTH : 0] Operand2_t, Operand1_t ;
	 always @ (alu_op2_sel_t)
	  begin 
	     case (alu_op2_sel_t )
		   1'b0 : Operand2_t = reg_data_2_t ;
	           1'b1 : Operand2_t = sz_ex_val_t ;
	     endcase
	  end
	 
	 // Implementation OF ALU 
	 reg [`REGISTER_WIDTH :0 ] ALU_Out_t;
	 reg bcond_t ;
	 Exec Exec_t ( .Operand1_t(Operand1) , .Operand2_t(Operand2) , .ALU_Out_t(Out) , 
	               .alu_ctrl_t(Operation) ,.bcond_t(bcond) );
	 
	 // Implementation of 2:4 mux 
	 
	 always @ ( reg_file_wr_back_sel_t )
	  begin 
	   case ( reg_file_wr_back_sel_t )
		 
		   2'b00 : wr_reg_data_t = ALU_Out_t ;
		   2'b01 : wr_reg_data_t = d_mem_rd_data_t ; ///Should define
		   2'b10 : wr_reg_data_t = Add_4_Out_t ;
		   2'b11 : wr_reg_data_t = Add_Out_t ;
			
		endcase
	  end
    
	// Implementation of simple adder 
	reg [`REGISTER_WIDTH-1:0] Add_Out_t;
	adder adder_1_t (.curr_addr_t( val_1) , .sz_ex_val_t(val_2) , .Add_Out_t(out) );
	
	//Implementation of OR gate 
	wire pc_mux1_sel_t  ;
	or or1 ( pc_mux1_sel_t , jal_t , bcond_t );
	
	 //Implemantation of pc_mux_1
	 reg [`REGISTER_WIDTH : 0 ] pc_mux1_Out_t ;
	 always @( pc_mux1_sel_t )
	   begin
		   case ( pc_mux1_sel_t)
			   1'b0 :  pc_mux1_Out_t = Add_4_Out_t;
		           1'b1 :  pc_mux1_Out_t = Add_Out_t ;
		   endcase
		end
		
	 //Implementation of pc_mux_2	
	 reg pc_mux2_Out_t ;
	 //pc_mux2_sel_t = jalr_t ;
	 always @( jalr_t )
	   begin
		   case ( jalr_t)
			   1'b0 :  pc_mux2_Out_t = pc_mux1_Out_t;
			   1'b1 :  pc_mux2_Out_t = ALU_Out_t ;
		   endcase
		end
		
		
		assign next_addr_t = pc_mux2_Out_t ;
	
	  
	 // Implementation of Data Memory module 
	 reg d_mem_rd_t , d_mem_wr_t ;
	 //reg [2:0] d_mem_size_t ; declared already in cu
	 //reg [`REGISTER_WIDTH : 0]  d_mem_wr_data_t == ALU_Out_t;
	 reg [`DATA_MEM_WORD_SIZE : 0 ] d_mem_rd_data_t;
         ram ram_t( .d_mem_rd_en_t(d_mem_rd) , .d_mem_wr_en_t(d_mem_wr) , .d_mem_size_t(d_mem_size),
                    .ALU_Out_t(d_mem_addr) ,.reg_data_2_t(d_mem_wr_data) , .d_mem_rd_data_t(d_mem_rd_data) ,
	            . rst_t(rst) , .clk_t(clk) );
	 endmodule
