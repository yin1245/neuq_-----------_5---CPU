`timescale 1ns / 1ps
`include "defines.v"

module ex_mem(

	input wire clk,//时钟信号
	input wire rst,//复位信号

	//来自控制模块的信息
	input wire[5:0] stall,	
	
	//来自执行阶段的信息	
	input wire[4:0] ex_wd,//执行阶段指令执行后要写入的目的寄存器地址
	input wire ex_wreg,//执行阶段指令执行后是否有要写入的目的寄存器
	input wire[31:0] ex_wdata,//执行阶段指令执行后要写入目的寄存器的值
	input wire[31:0] ex_hi,//执行阶段写入HI的值
	input wire[31:0] ex_lo,//执行阶段写入LO的值
	input wire ex_whilo,//执行阶段指令是否要写HI、LO寄存器

  //为实现加载、访存指令而添加
    input wire[7:0] ex_aluop,//执行阶段的指令要进行的运算的子类型
	input wire[31:0] ex_mem_addr,//执行阶段的加载、存储指令对应的存储器地址
	input wire[31:0] ex_reg2,//执行阶段的存储指令要存储的数据，或指令要写入的目的寄存器的原始值

	input wire[63:0] hilo_i,//保存到乘法结果
	input wire[1:0]  cnt_i,//下一个时钟周期是执行阶段的第几个时钟周期
	
	//送到访存阶段的信息
	output reg[4:0] mem_wd,//方寸阶段指令最终要写入的目的寄存器地址
	output reg mem_wreg,//访存阶段指令最终是否要写入目的寄存器
	output reg[31:0] mem_wdata,//访存阶段指令最终写入目的寄存器的值
	output reg[31:0] mem_hi,//写入HI的值
	output reg[31:0] mem_lo,//写入LO的值
	output reg mem_whilo,

  //为实现加载、访存指令而添加
    output reg[7:0] mem_aluop,//访存阶段的指令要进行的运算的子类型
	output reg[31:0] mem_mem_addr,//访存阶段加载、存储指令对应的存储器地址
	output reg[31:0] mem_reg2,//访存阶段的存储指令要存储的数据或要写入的目的寄存器的原始值
		
	output reg[63:0] hilo_o,//保存到乘法结果
	output reg[1:0] cnt_o//当前处于执行阶段的第几个时钟周期
	
	
);


	always @ (posedge clk) begin
		if(rst == 1'b1) begin
		   mem_wd <= 5'b00000;
	       mem_wreg <= 1'b0;
		   mem_wdata <= 32'h00000000;	
		   mem_hi <= 32'h00000000;
		   mem_lo <= 32'h00000000;
		   mem_whilo <= 1'b0;		
	       hilo_o <= {32'h00000000, 32'h00000000};
		   cnt_o <= 2'b00;	
  		   mem_aluop <= `EXE_NOP_OP;
		   mem_mem_addr <= 32'h00000000;
		   mem_reg2 <= 32'h00000000;			
		end else if(stall[3] == 1'b1 && stall[4] == 1'b0) begin
		  mem_wd <= 5'b00000;
		  mem_wreg <= 1'b0;
		  mem_wdata <= 32'h00000000;
		  mem_hi <= 32'h00000000;
		  mem_lo <= 32'h00000000;
		  mem_whilo <= 1'b0;
	      hilo_o <= hilo_i;
		  cnt_o <= cnt_i;	
  		  mem_aluop <= `EXE_NOP_OP;
		  mem_mem_addr <= 32'h00000000;
		  mem_reg2 <= 32'h00000000;						  				    
		end else if(stall[3] == 1'b0) begin
			mem_wd <= ex_wd;
			mem_wreg <= ex_wreg;
			mem_wdata <= ex_wdata;	
			mem_hi <= ex_hi;
			mem_lo <= ex_lo;
			mem_whilo <= ex_whilo;	
	        hilo_o <= {32'h00000000, 32'h00000000};
			cnt_o <= 2'b00;	
  		    mem_aluop <= ex_aluop;
			mem_mem_addr <= ex_mem_addr;
			mem_reg2 <= ex_reg2;			
		end else begin
	    hilo_o <= hilo_i;
			cnt_o <= cnt_i;											
		end    //if
	end      //always
			

endmodule