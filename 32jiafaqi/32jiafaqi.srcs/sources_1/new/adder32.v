`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/26 18:37:47
// Design Name: 
// Module Name: adder_32
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


//32位并行进位加法器顶层模块
module adder32(X,Y,S,c32);
    input [32:1] X;
	 input [32:1] Y;
	 output [32:1] S;
	 output c32;
	 
	 wire px1,gx1,px2,gx2;
	 wire c4,c8,c12,c16,c20,c24,c28,c32;

  adder_4 adder4_1(
      .x(X[4:1]),
		.y(Y[4:1]),
		.c0(0),
		.c4(c4),
		.F(S[4:1])
	);adder_4 adder4_2(
      .x(X[8:5]),
		.y(Y[8:5]),
		.c0(c4),
		.c4(c8),
		.F(S[8:5])
	);adder_4 adder4_3(
      .x(X[12:9]),
		.y(Y[12:9]),
		.c0(c8),
		.c4(c12),
		.F(S[12:9])
	);adder_4 adder4_4(
      .x(X[16:13]),
		.y(Y[16:13]),
		.c0(c12),
		.c4(c16),
		.F(S[16:13])
	);adder_4 adder4_5(
      .x(X[20:16]),
		.y(Y[20:17]),
		.c0(c16),
		.c4(c20),
		.F(S[20:17])
	);adder_4 adder4_6(
      .x(X[24:21]),
		.y(Y[24:21]),
		.c0(c20),
		.c4(c24),
		.F(S[24:21])
	);adder_4 adder4_7(
      .x(X[28:25]),
		.y(Y[28:25]),
		.c0(c24),
		.c4(c28),
		.F(S[28:25])
	);adder_4 adder4_8(
      .x(X[32:29]),
		.y(Y[32:29]),
		.c0(c28),
		.c4(c32),
		.F(S[32:29])
	);

endmodule 

