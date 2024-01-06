`timescale 1ns / 1ps

module LLbit_reg(

	input wire	clk,
	input wire	rst,
	
	input wire flush,
	//д�˿�
	input wire LLbit_i,
	input wire we,
	
	//���˿�1
	output reg LLbit_o
	
);


	always @ (posedge clk) begin
		if (rst == 1'b1) begin
					LLbit_o <= 1'b0;
		end else if((flush == 1'b1)) begin
					LLbit_o <= 1'b0;
		end else if((we == 1'b1)) begin
					LLbit_o <= LLbit_i;
		end
	end

endmodule