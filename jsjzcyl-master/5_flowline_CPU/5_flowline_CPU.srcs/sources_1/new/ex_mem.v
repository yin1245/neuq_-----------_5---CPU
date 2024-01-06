`timescale 1ns / 1ps
`include "defines.v"

module ex_mem(

	input wire clk,//ʱ���ź�
	input wire rst,//��λ�ź�

	//���Կ���ģ�����Ϣ
	input wire[5:0] stall,	
	
	//����ִ�н׶ε���Ϣ	
	input wire[4:0] ex_wd,//ִ�н׶�ָ��ִ�к�Ҫд���Ŀ�ļĴ�����ַ
	input wire ex_wreg,//ִ�н׶�ָ��ִ�к��Ƿ���Ҫд���Ŀ�ļĴ���
	input wire[31:0] ex_wdata,//ִ�н׶�ָ��ִ�к�Ҫд��Ŀ�ļĴ�����ֵ
	input wire[31:0] ex_hi,//ִ�н׶�д��HI��ֵ
	input wire[31:0] ex_lo,//ִ�н׶�д��LO��ֵ
	input wire ex_whilo,//ִ�н׶�ָ���Ƿ�ҪдHI��LO�Ĵ���

  //Ϊʵ�ּ��ء��ô�ָ������
    input wire[7:0] ex_aluop,//ִ�н׶ε�ָ��Ҫ���е������������
	input wire[31:0] ex_mem_addr,//ִ�н׶εļ��ء��洢ָ���Ӧ�Ĵ洢����ַ
	input wire[31:0] ex_reg2,//ִ�н׶εĴ洢ָ��Ҫ�洢�����ݣ���ָ��Ҫд���Ŀ�ļĴ�����ԭʼֵ

	input wire[63:0] hilo_i,//���浽�˷����
	input wire[1:0]  cnt_i,//��һ��ʱ��������ִ�н׶εĵڼ���ʱ������
	
	//�͵��ô�׶ε���Ϣ
	output reg[4:0] mem_wd,//����׶�ָ������Ҫд���Ŀ�ļĴ�����ַ
	output reg mem_wreg,//�ô�׶�ָ�������Ƿ�Ҫд��Ŀ�ļĴ���
	output reg[31:0] mem_wdata,//�ô�׶�ָ������д��Ŀ�ļĴ�����ֵ
	output reg[31:0] mem_hi,//д��HI��ֵ
	output reg[31:0] mem_lo,//д��LO��ֵ
	output reg mem_whilo,

  //Ϊʵ�ּ��ء��ô�ָ������
    output reg[7:0] mem_aluop,//�ô�׶ε�ָ��Ҫ���е������������
	output reg[31:0] mem_mem_addr,//�ô�׶μ��ء��洢ָ���Ӧ�Ĵ洢����ַ
	output reg[31:0] mem_reg2,//�ô�׶εĴ洢ָ��Ҫ�洢�����ݻ�Ҫд���Ŀ�ļĴ�����ԭʼֵ
		
	output reg[63:0] hilo_o,//���浽�˷����
	output reg[1:0] cnt_o//��ǰ����ִ�н׶εĵڼ���ʱ������
	
	
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