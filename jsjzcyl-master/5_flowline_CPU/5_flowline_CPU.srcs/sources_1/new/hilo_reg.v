`timescale 1ns / 1ps
`include "defines.v"

module hilo_reg(

	input wire clk,
	input wire rst,
	
	//д�˿�
	input wire we,//HI��LO�Ĵ���дʹ���ź�
	input wire[31:0] hi_i,//д��HI��ֵ
	input wire[31:0] lo_i,//д��LO��ֵ
	
	//���˿�1
	output reg[31:0] hi_o,//HI�Ĵ�����ֵ
	output reg[31:0] lo_o//LO�Ĵ�����ֵ
	
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