`timescale 1ns / 1ps

module pc_reg(
	input wire clk,//时钟信号
	input wire rst,//复位信号

	//来自控制模块的信息
	input wire[5:0] stall,//控制信号,判断流水线是否暂停

	//来自译码阶段的信息
	input wire branch_flag_i,//是否发生转移(分支)
	input wire[31:0] branch_target_address_i,//转移到的目标地址
	
	output reg[31:0] pc,//要读取的指令地址
	output reg ce//指令存储器使能信号
	
);

	always @ (posedge clk) begin // 上升沿触发
		if (ce == 1'b0) begin
			pc <= 32'h00000000;
		end 
		else if(stall[0] == 1'b0) begin
		  	if(branch_flag_i == 1'b1) 
		  	begin
					pc <= branch_target_address_i;
			end 
			else begin
		  		pc <= pc + 4'h4;
		  	end
		end
	end

	always @ (posedge clk) begin
		if (rst == 1'b1) begin
			ce <= 1'b0;
		end else begin
			ce <= 1'b1;
		end
	end

endmodule