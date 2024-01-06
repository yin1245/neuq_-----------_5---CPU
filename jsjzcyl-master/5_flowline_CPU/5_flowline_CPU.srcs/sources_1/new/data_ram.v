`timescale 1ns / 1ps
`include "defines.v"

module data_ram(
	input wire clk,//时钟信号
	input wire ce,//使能信号，表示是否被选中
	input wire we,//写使能
	input wire[31:0] addr,//需要访问的地址
	input wire[3:0] sel,//字节选择信号
	input wire[31:0] data_i,//需要写入的内容
	output reg[31:0] data_o//需要读出的内容
	
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