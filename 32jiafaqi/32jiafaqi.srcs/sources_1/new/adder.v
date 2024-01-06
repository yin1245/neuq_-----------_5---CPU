`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/26 18:20:42
// Design Name: 
// Module Name: adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//一位全加器
//一位全加器
module adder(X,Y,Cin,F,Cout);

  input X,Y,Cin;
  output F,Cout;
  
  assign F = X ^ Y ^ Cin;
  assign Cout = (X ^ Y) & Cin | X & Y;
endmodule 

