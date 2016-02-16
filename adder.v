`timescale 1ns / 1ps

`define REGISTER_WIDTH 32

module adder(
    input [REGISTER_WIDTH-1:0] val_1,
    input [REGISTER_WIDTH-1:0] val_2,
    output reg [REGISTER_WIDTH-1:0] out
    );
always @ (*)
out = val_1 + val_2 ;

endmodule
