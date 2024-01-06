`timescale 1ns / 1ps
`include "defines.v"

module data_ram(
	input wire clk,//ʱ���ź�
	input wire ce,//ʹ���źţ���ʾ�Ƿ�ѡ��
	input wire we,//дʹ��
	input wire[31:0] addr,//��Ҫ���ʵĵ�ַ
	input wire[3:0] sel,//�ֽ�ѡ���ź�
	input wire[31:0] data_i,//��Ҫд�������
	output reg[31:0] data_o//��Ҫ����������
	
);

	reg[7:0]  data_mem0[0:131071-1];
	reg[7:0]  data_mem1[0:131071-1];
	reg[7:0]  data_mem2[0:131071-1];
	reg[7:0]  data_mem3[0:131071-1];

	always @ (posedge clk) begin
		if (ce == 1'b0) begin
			//data_o <= ZeroWord;
		end else if(we == 1'b1) begin
			  if (sel[3] == 1'b1) begin
		      data_mem3[addr[17+1:2]] <= data_i[31:24];
		    end
			  if (sel[2] == 1'b1) begin
		      data_mem2[addr[17+1:2]] <= data_i[23:16];
		    end
		    if (sel[1] == 1'b1) begin
		      data_mem1[addr[17+1:2]] <= data_i[15:8];
		    end
			  if (sel[0] == 1'b1) begin
		      data_mem0[addr[17+1:2]] <= data_i[7:0];
		    end			   	    
		end
	end
	
	always @ (*) begin
		if (ce == 1'b0) begin
			data_o <= 32'h00000000;
	  end else if(we == 1'b0) begin
		    data_o <= {data_mem3[addr[17+1:2]],
		               data_mem2[addr[17+1:2]],
		               data_mem1[addr[17+1:2]],
		               data_mem0[addr[17+1:2]]};
		end else begin
				data_o <= 32'h00000000;
		end
	end		

endmodule