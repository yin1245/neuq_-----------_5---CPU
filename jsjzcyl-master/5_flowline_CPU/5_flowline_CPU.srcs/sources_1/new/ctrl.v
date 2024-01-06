`timescale 1ns / 1ps
`include "defines.v"

module ctrl(
	input wire rst,//复位
	input wire stallreq_from_id,//译码阶段指令是否请求流水线暂停
	input wire stallreq_from_ex,//执行阶段指令是否请求流水线暂停
	output reg[5:0] stall//输出流水线暂停信号
	
);

	always @ (*) begin
		if(rst == 1'b1) begin
			stall <= 6'b000000;
		end else if(stallreq_from_ex == 1'b1) begin
			stall <= 6'b001111;
		end else if(stallreq_from_id == 1'b1) begin
			stall <= 6'b000111;			
		end else begin
			stall <= 6'b000000;
		end    //if
	end      //always
			

endmodule