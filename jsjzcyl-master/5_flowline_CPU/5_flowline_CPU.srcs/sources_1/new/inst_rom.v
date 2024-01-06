`timescale 1ns / 1ps
`include "defines.v"

module inst_rom(

//	input wire clk,
	input wire ce,//ʹ���ź�
	input wire [31:0] addr,//Ҫ��ȡ��ָ���ַ
	output reg [31:0] inst//������ָ��
	
);

	reg[31:0]  inst_mem[0:131071-1];

	initial $readmemh ( "C:/vivadoprojects/jsjzcyl-master/5_flowline_CPU/5_flowline_CPU.srcs/sources_1/new/inst_rom.data", inst_mem );

	always @ (*) begin
		if (ce == 1'b0) begin
			inst <= 32'h00000000;
	  end else begin
		  inst <= inst_mem[addr[17+1:2]];
		end
	end

endmodule