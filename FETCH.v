`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:09:18 01/26/2016 
// Design Name: 
// Module Name:    rom 
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
'define WORD_SIZE 32

// Instruction Memory (ROM) Size 2^32 * 32 bits
'define MEMORY_SIZE 4294967296
'define MEMORY_INDEX 32

module rom(
    input clk,
    input [MEMORY_INDEX-1:0] ProgramCounter,
    output [WORD_SIZE-1:0] InstructionRegister
    );
    
reg [WORD_SIZE-1:0] InstructionRegister ;
reg [WORD_SIZE-1:0] MemoryDataRegister;
reg [WORD_SIZE-1:0] MemoryAddressRegister;
reg [WORD_SIZE-1:0] ROM [0:MEMORY_SIZE-1];

//File descriptor for the binary file
integer g;

// Delays for latching the address and retreiving the contents
parameter addressLatch=5 ,memDelay =5;
 
 
 initial
   begin
       // Open the binary file  for reading
        g=$fopen("Instructions1.txt","r");
        
       // Load the instructions in binary format into ROM 
        $readmemb("Instructions1.txt",ROM);

  end
  
  always @ (posedge clk)
     begin 
         #addressLatch MemoryAddressRegister=ProgramCounter;
         #memDelay MemoryDataRegister=ROM[MemoryAddressRegister];
         InstructionRegister=MemoryDataRegister ;
     end
endmodule
