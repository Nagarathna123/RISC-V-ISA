`define REGISTER_WIDTH 32
`define PC_INIT_VAL 32'b0
module pc_block(
    input rst,
    input clk  ,
	 input next_addr ,
	 output reg curr_addr 
    );
initial
  curr_addr = `PC_INIT_VAL ;
always @(posedge clk) begin
 if(rst)
     curr_addr = `PC_INIT_VAL ;
	else 
     curr_addr = next_addr ;
  end	  
endmodule
