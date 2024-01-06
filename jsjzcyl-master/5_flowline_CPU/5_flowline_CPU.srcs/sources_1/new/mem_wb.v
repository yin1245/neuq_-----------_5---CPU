`timescale 1ns / 1ps
`include "defines.v"

module mem_wb(

	input wire clk,//ʱ���ź�
	input wire rst,//��λ�ź�

  //���Կ���ģ�����Ϣ
	input wire[5:0] stall,//�����ź�

	//���Էô�׶ε���Ϣ	
	input wire[4:0] mem_wd,//�ô�׶ε�ָ������Ҫд���Ŀ�ļĴ�����ַ
	input wire mem_wreg,//�ô�׶ε�ָ���Ƿ�Ҫд��Ŀ�ļĴ���
	input wire[31:0]	mem_wdata,//�ô�׶�ָ������Ҫд��Ŀ�ļĴ�����ֵ
	input wire[31:0] mem_hi,//�ô�׶�ָ��Ҫд��HI�Ĵ�����ֵ
	input wire[31:0] mem_lo,//�ô�׶�ָ��Ҫд��LO�Ĵ�����ֵ
	input wire mem_whilo,//�ô�׶�ָ���Ƿ�ҪдHI��LO�Ĵ���
	
	input wire mem_LLbit_we,
	input wire mem_LLbit_value,	

	//�͵���д�׶ε���Ϣ
	output reg[4:0] wb_wd,//��д�׶�ָ��Ҫд���Ŀ�ļĴ�����ַ
	output reg wb_wreg,//��д�׶ε�ָ���Ƿ�Ҫд��Ŀ�ļĴ���
	output reg[31:0]	wb_wdata,//��д�׶�ָ��Ҫд���Ŀ�ļĴ���
	output reg[31:0] wb_hi,//��д�׶�ָ��Ҫд��HI�Ĵ�����ֵ
	output reg[31:0] wb_lo,//��д�׶�ָ��Ҫд��LO�Ĵ�����ֵ
	output reg wb_whilo,//�Ƿ�ҪдHILO�Ĵ���

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