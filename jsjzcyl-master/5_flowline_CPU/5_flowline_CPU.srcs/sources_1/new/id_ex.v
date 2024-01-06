`timescale 1ns / 1ps

module id_ex(
	input wire clk,//时钟信号
	input wire rst,//复位信号

	//来自控制模块的信息
	input wire[5:0] stall,//控制信号
	
	//从译码阶段传递的信息
	input wire[7:0] id_aluop,//译码阶段的指令要进行的运算的子类型
	input wire[2:0] id_alusel,//译码阶段的指令要进行的运算类型
	input wire[31:0] id_reg1,//译码阶段源操作数1
	input wire[31:0] id_reg2,//译码阶段源操作数2
	input wire[4:0] id_wd,//译码阶段指令要写入的目的寄存器地址
	input wire id_wreg,//译码阶段指令是否要写入目的寄存器
	input wire[31:0] id_link_address,//译码阶段的转移指令要保存的返回地址
	input wire id_is_in_delayslot,//当前译码阶段指令是否位于延迟槽
	input wire next_inst_in_delayslot_i,//下一条译码阶段指令是否位于延迟槽
	input wire[31:0] id_inst,//当前处于译码阶段的指令	
	
	//传递到执行阶段的信息
	output reg[7:0] ex_aluop,//执行阶段的指令要进行的运算子类型
	output reg[2:0] ex_alusel,//执行阶段的指令要进行的运算类型
	output reg[31:0] ex_reg1,//执行阶段源操作数1
	output reg[31:0] ex_reg2,//执行阶段源操作数2
	output reg[4:0] ex_wd,//执行阶段要写入的目的寄存器地址
	output reg ex_wreg,//执行阶段是否要写入目的寄存器
	output reg[31:0] ex_link_address,//处于执行阶段的转移指令要保存的返回地址
    output reg ex_is_in_delayslot,//当前处于执行阶段的指令是否位于延迟槽
	output reg is_in_delayslot_o,//当前处于译码阶段的指令是否位于延迟槽
	output reg[31:0] ex_inst//当前处于执行阶段的指令
	
);

	always @ (posedge clk) begin
		if (rst == 1'b1 || (stall[2] == 1'b1 && stall[3] == 1'b0)) begin // 复位状态或流水线阶段3被暂停
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= 32'h00000000;
			ex_reg2 <= 32'h00000000;
			ex_wd <= 5'b00000;
			ex_wreg <= 1'b0;
			ex_link_address <= 32'h00000000;
			ex_is_in_delayslot <= 1'b0;
	        is_in_delayslot_o <= 1'b0;		
            ex_inst <= 32'h00000000;			
		end else if(stall[2] == 1'b0) begin		
			ex_aluop <= id_aluop;
			ex_alusel <= id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;		
			ex_link_address <= id_link_address;
			ex_is_in_delayslot <= id_is_in_delayslot;
            is_in_delayslot_o <= next_inst_in_delayslot_i;
            ex_inst <= id_inst;				
		end
	end
	
endmodule