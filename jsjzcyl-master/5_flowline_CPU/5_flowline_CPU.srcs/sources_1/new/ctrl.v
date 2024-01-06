`timescale 1ns / 1ps
`include "defines.v"

module ctrl(
	input wire rst,//��λ
	input wire stallreq_from_id,//����׶�ָ���Ƿ�������ˮ����ͣ
	input wire stallreq_from_ex,//ִ�н׶�ָ���Ƿ�������ˮ����ͣ
	output reg[5:0] stall//�����ˮ����ͣ�ź�
	
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