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
`include "Dist_RAM.v"
`include "adder.v"
`include "dist_ROM.v"
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
`define DATA_MEM_WORD_SIZE 16 // 8,16, 32 etc
module Single_Cycle_Processor(
    input rst_t,
    input clk_t
    );
	 
	 // Instantiation of PC_BLOCK
    wire [`REGISTER_WIDTH-1:0] next_addr_t ;
    wire [`REGISTER_WIDTH-1:0] curr_addr_t ;
	 
    pc_block  pc_bloc_t ( .rst(rst_t), .clk(clk_t) ,
                       .next_addr(next_addr_t) , .curr_addr(curr_addr_t));
  
    //Instantiation of fetch module
   // reg [`REGISTER_WIDTH-1:0] Instruction ;
	 
//	 rom rom_t ( .clk_t(clk) , .rst_t(rst) , .curr_addr_t(ProgramCounter) ,
//	             .Instruction(InstructionRegister));

//Instantiation of distributed ROM 
   wire [`REGISTER_WIDTH-1:0] Instruction ;
   dist_ROM dist_ROM_t (.a(curr_addr_t), . spo(Instruction));
 
    //Instantiation of adder
	 reg [`REGISTER_WIDTH-1:0] val_2_PC_adder = 32'd4;
	 wire [`REGISTER_WIDTH-1:0] Add_4_Out_t;
	 
	 adder adder_t (. val_1(curr_addr_t) , .val_2(val_2_PC_adder) , .out(Add_4_Out_t));


    //Instantiation of Control Unit 
    wire [(`ALU_CTRL_WIDTH-1):0] alu_ctrl_t ;	
    wire reg_file_wr_en_t , d_mem_rd_en_t  , d_mem_wr_en_t;
    wire [1:0] reg_file_wr_back_sel_t ;
	 wire [1:0] d_mem_size_t;
	 wire jal_t , jalr_t , alu_op2_sel_t;
	 
	 ctrl ctrl_t ( .inst(Instruction) , .jal(jal_t) , .jalr(jalr_t) , .d_mem_size(d_mem_size_t) ,
	               .reg_file_wr_back_sel(reg_file_wr_back_sel_t) , .d_mem_wr_en(d_mem_wr_en_t) ,
		       .alu_op2_sel(alu_op2_sel_t) , .d_mem_rd_en(d_mem_rd_en_t) , .reg_file_wr_en(reg_file_wr_en_t),
		       .alu_ctrl(alu_ctrl_t) ) ;
						
						
    //Instantiation of register file 
	 wire [`REGISTER_WIDTH-1:0] reg_data_1_t , reg_data_2_t ;
    reg	[`REGISTER_WIDTH-1:0] wr_reg_data_t;
	 //wire wr_en_t ==  reg_file_wr_en_t ;
	 wire [(`REG_INDEX_WIDTH-1):0] rd_reg_index_1_t = Instruction[`REG1_MSB :`REG1_LSB] ;
	 wire [(`REG_INDEX_WIDTH-1):0] rd_reg_index_2_t= Instruction[`REG2_MSB :`REG2_LSB] ;
	 wire [(`REG_INDEX_WIDTH-1):0] wr_reg_index_t = Instruction[`DST_REG_MSB :`DST_REG_LSB] ;
	 
	 reg_file reg_file_t ( .reg_data_1(reg_data_1_t) , .reg_data_2(reg_data_2_t) ,
                               .rst(rst_t) , .clk(clk_t) , .wr_en(reg_file_wr_en_t) ,.rd_reg_index_1(rd_reg_index_1_t) ,
                               .rd_reg_index_2(rd_reg_index_2_t) , .wr_reg_index(wr_reg_index_t) , 
                               .wr_reg_data(wr_reg_data_t));	
								 
								 
	 // Instantiation of sign extend module
	 wire [(`OPERAND_WIDTH - 1):0] sz_ex_val_t ;
	 
    sz_ex sz_ex_t ( .inst(Instruction) , .sz_ex_val(sz_ex_val_t));
	 
	 
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
	 wire [`REGISTER_WIDTH :0 ] ALU_Out_t;
	 wire bcond_t ;
	 Exec Exec_t ( .Operand1(Operand1_t) , .Operand2(Operand2_t) , .Out(ALU_Out_t) , 
	               .Operation(alu_ctrl_t) ,.bcond(bcond_t) );
	 
	 // Implementation of 2:4 mux 
	 
	 always @ ( reg_file_wr_back_sel_t )
	  begin 
	   if( reg_file_wr_back_sel_t== 2'b00 )
		     wr_reg_data_t = ALU_Out_t ;
			 else if(reg_file_wr_back_sel_t== 2'b01)
		          wr_reg_data_t = d_mem_rd_data_t ; ///Should define
					 else if (reg_file_wr_back_sel_t== 2'b10)
		               wr_reg_data_t = Add_4_Out_t ;
							else
	                    wr_reg_data_t = Add_Out_t ;
			
		
	  end
    
	// Implementation of simple adder 
	wire [`REGISTER_WIDTH-1:0] Add_Out_t;
	adder adder_1_t (.val_1(curr_addr_t) , .val_2(sz_ex_val_t) , .out(Add_Out_t ));
	
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
	 reg [`REGISTER_WIDTH-1 : 0 ] pc_mux2_Out_t ;
	 //pc_mux2_sel_t = jalr_t ;
	 always @( jalr_t )
	   begin
		   case ( jalr_t)
			   1'b0 :  pc_mux2_Out_t = pc_mux1_Out_t;
			   1'b1 :  pc_mux2_Out_t = ALU_Out_t ;
		   endcase
		end
		
		
		assign next_addr_t= pc_mux2_Out_t ;
	
	  
	 // Implementation of Data Memory module 
	 
	 
	 reg [4:0] d_mem_word_size ; 
	 //reg [`REGISTER_WIDTH : 0]  d_mem_wr_data_t == ALU_Out_t;
	   
	// always    @ ( d_mem_size_t ) begin 
	 //  case (d_mem_size_t)
     //          2'b00 : d_mem_word_size = 5'd32 ; 
      //         2'b10 : d_mem_word_size = 5'd8;
       //        default : d_mem_word_size = 5'd16 ;
        //   endcase    
         // end
         parameter DATA_MEM_WORD_SIZE = 16 ;
         wire [DATA_MEM_WORD_SIZE-1 : 0 ] d_mem_rd_data_t;
         Dist_RAM Dist_RAM_t( .we(d_mem_wr_en_t) , // .d_mem_size_t(d_mem_size), already taken care of using parameter
                    .a(ALU_Out_t) ,.d(reg_data_2_t) , .spo(d_mem_rd_data_t) ,
	            .clk(clk_t) );
	 endmodule
