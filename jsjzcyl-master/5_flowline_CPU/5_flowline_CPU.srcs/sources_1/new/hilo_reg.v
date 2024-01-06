`timescale 1ns / 1ps
`include "defines.v"

module hilo_reg(

	input wire clk,
	input wire rst,
	
	//写端口
	input wire we,//HI、LO寄存器写使能信号
	input wire[31:0] hi_i,//写入HI的值
	input wire[31:0] lo_i,//写入LO的值
	
	//读端口1
	output reg[31:0] hi_o,//HI寄存器的值
	output reg[31:0] lo_o//LO寄存器的值
	
);

	always @ (posedge clk) begin
		if (rst == 1'b1) begin
					hi_o <= 32'h00000000;
					lo_o <= 32'h00000000;
		end else if((we == 1'b1)) begin
					hi_o <= hi_i;
					lo_o <= lo_i;
		end
	end

endmodule