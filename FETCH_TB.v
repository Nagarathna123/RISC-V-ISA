'define WORD_SIZE 32

// Instruction Memory (ROM) Size 2^32 * 32 bits
'define MEMORY_SIZE 4294967296
'define MEMORY_INDEX 32

'define CLOCK_PERIOD 100
'define SIMULATION_TIME 1000
'define PC_INIT_VALUE 32'b0

module rom_tb;

 // Inputs
 reg clk;
 reg [MEMORY_INDEX-1:0] ProgramCounter;

 // Outputs
 wire [WORD_SIZE-1:0] InstructionRegister;
 
 //F-file descriptor and i as counter
    integer f,i;

 // Instantiate the Unit Under Test (UUT)
 rom uut (
  .clk(clk), 
  .ProgramCounter(ProgramCounter), 
  .InstructionRegister(InstructionRegister)
 );
 
 
     initial begin
     
       //Open a text file for writing instructions 
        f=$fopen("Instructions1.txt","w");
   
     end
   
   
     initial begin
    
           // Assumption :Numbers 0 to 255 in binary format are the instructions of a program which will be stored into memory locations 0 to 255
           for (i = 0; i<256; i=i+1)
           $fwrite(f,"%b\n",i);
      end
    
      initial begin
       
       // Initialize Inputs
         clk = 1;
         ProgramCounter=PC_INIT_VALUE;
         #SIMULATION_TIME $finish;
      end
    
      always begin
          //Generate clock signal     
          #(CLOCK_PERIOD/2) clk=~clk;
      end

      always begin
      
        Update the program Counter value before the next cycle 
        #(CLOCK_PERIOD-5) ProgramCounter=ProgramCounter+8'd1; 
       end
  
  
endmodule
