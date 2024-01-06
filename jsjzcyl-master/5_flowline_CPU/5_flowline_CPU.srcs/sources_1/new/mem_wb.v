`timescale 1ns / 1ps
`include "defines.v"

module mem_wb(

	input wire clk,//时钟信号
	input wire rst,//复位信号

  //来自控制模块的信息
	input wire[5:0] stall,//控制信号

	//来自访存阶段的信息	
	input wire[4:0] mem_wd,//访存阶段的指令最终要写入的目的寄存器地址
	input wire mem_wreg,//访存阶段的指令是否要写入目的寄存器
	input wire[31:0]	mem_wdata,//访存阶段指令最终要写入目的寄存器的值
	input wire[31:0] mem_hi,//访存阶段指令要写入HI寄存器的值
	input wire[31:0] mem_lo,//访存阶段指令要写入LO寄存器的值
	input wire mem_whilo,//访存阶段指令是否要写HI、LO寄存器
	
	input wire mem_LLbit_we,
	input wire mem_LLbit_value,	

	//送到回写阶段的信息
	output reg[4:0] wb_wd,//回写阶段指令要写入的目的寄存器地址
	output reg wb_wreg,//回写阶段的指令是否要写入目的寄存器
	output reg[31:0]	wb_wdata,//回写阶段指令要写入的目的寄存器
	output reg[31:0] wb_hi,//回写阶段指令要写入HI寄存器的值
	output reg[31:0] wb_lo,//回写阶段指令要写入LO寄存器的值
	output reg wb_whilo,//是否要写HILO寄存器

	output reg wb_LLbit_we,
	output reg wb_LLbit_value			       
	
);


	always @ (posedge clk) begin
		if(rst == 1'b1) begin
			wb_wd <= 5'b00000;
			wb_wreg <= 1'b0;
		  wb_wdata <= 32'h00000000;	
		  wb_hi <= 32'h00000000;
		  wb_lo <= 32'h00000000;
		  wb_whilo <= 1'b0;
		  wb_LLbit_we <= 1'b0;
		  wb_LLbit_value <= 1'b0;			  	
		end else if(stall[4] == 1'b1 && stall[5] == 1'b0) begin
			wb_wd <= 5'b00000;
			wb_wreg <= 1'b0;
		  wb_wdata <= 32'h00000000;
		  wb_hi <= 32'h00000000;
		  wb_lo <= 32'h00000000;
		  wb_whilo <= 1'b0;	
		  wb_LLbit_we <= 1'b0;
		  wb_LLbit_value <= 1'b0;			  	  	  
		end else if(stall[4] == 1'b0) begin
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;
			wb_hi <= mem_hi;
			wb_lo <= mem_lo;
			wb_whilo <= mem_whilo;		
		  wb_LLbit_we <= mem_LLbit_we;
		  wb_LLbit_value <= mem_LLbit_value;				
		end    //if
	end      //always
			

endmodule