`timescale 1ns / 1ps

module regfile(
	input wire clk,//时钟信号
	input wire rst,//复位信号
	
	//写端口
	input wire we,//写使能
	input wire[4:0]	waddr,//要写入的寄存器地址
	input wire[31:0]	wdata,//要写入的数据
	
	//读端口1
	input wire re1,//第一个读寄存器端口读使能信号
	input wire[4:0]	raddr1,//第一个读寄存器端口要读取的寄存器地址
	output reg[31:0] rdata1,//第一个读寄存器端口输出的寄存器值
	
	//读端口2
	input wire re2,//第二个读寄存器端口读使能信号
	input wire[4:0]	raddr2,//第二个读寄存器端口要读取的寄存器地址
	output reg[31:0] rdata2//第二个读寄存器端口输出的寄存器值
	
);

	reg[31:0]  regs[0:31];

	always @ (posedge clk) begin
		if (rst == 1'b0) begin
			if((we == 1'b1) && (waddr != 5'h0)) begin
				regs[waddr] <= wdata;
			end
		end
	end
	
	always @ (*) begin
	  if(rst == 1'b1) begin
			rdata1 <= 32'h00000000;
	  end else if(raddr1 == 5'h0) begin
	  		rdata1 <= 32'h00000000;
	  end else if((raddr1 == waddr) && (we == 1'b1) 
	  	            && (re1 == 1'b1)) begin
	  	    rdata1 <= wdata;
	  end else if(re1 == 1'b1) begin
	        rdata1 <= regs[raddr1];
	  end else begin
	        rdata1 <= 32'h00000000;
	  end
	end

	always @ (*) begin
	  if(rst == 1'b1) begin
			rdata2 <= 32'h00000000;
	  end else if(raddr2 == 5'h0) begin
	  		rdata2 <= 32'h00000000;
	  end else if((raddr2 == waddr) && (we == 1'b1) 
	  	            && (re2 == 1'b1)) begin
	  	    rdata2 <= wdata;
	  end else if(re2 == 1'b1) begin
	        rdata2 <= regs[raddr2];
	  end else begin
	        rdata2 <= 32'h00000000;
	  end
	end

endmodule