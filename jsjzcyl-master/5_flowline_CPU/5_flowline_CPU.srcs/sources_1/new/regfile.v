`timescale 1ns / 1ps

module regfile(
	input wire clk,//ʱ���ź�
	input wire rst,//��λ�ź�
	
	//д�˿�
	input wire we,//дʹ��
	input wire[4:0]	waddr,//Ҫд��ļĴ�����ַ
	input wire[31:0]	wdata,//Ҫд�������
	
	//���˿�1
	input wire re1,//��һ�����Ĵ����˿ڶ�ʹ���ź�
	input wire[4:0]	raddr1,//��һ�����Ĵ����˿�Ҫ��ȡ�ļĴ�����ַ
	output reg[31:0] rdata1,//��һ�����Ĵ����˿�����ļĴ���ֵ
	
	//���˿�2
	input wire re2,//�ڶ������Ĵ����˿ڶ�ʹ���ź�
	input wire[4:0]	raddr2,//�ڶ������Ĵ����˿�Ҫ��ȡ�ļĴ�����ַ
	output reg[31:0] rdata2//�ڶ������Ĵ����˿�����ļĴ���ֵ
	
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