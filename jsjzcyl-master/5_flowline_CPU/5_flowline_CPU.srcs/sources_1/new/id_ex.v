`timescale 1ns / 1ps

module id_ex(
	input wire clk,//ʱ���ź�
	input wire rst,//��λ�ź�

	//���Կ���ģ�����Ϣ
	input wire[5:0] stall,//�����ź�
	
	//������׶δ��ݵ���Ϣ
	input wire[7:0] id_aluop,//����׶ε�ָ��Ҫ���е������������
	input wire[2:0] id_alusel,//����׶ε�ָ��Ҫ���е���������
	input wire[31:0] id_reg1,//����׶�Դ������1
	input wire[31:0] id_reg2,//����׶�Դ������2
	input wire[4:0] id_wd,//����׶�ָ��Ҫд���Ŀ�ļĴ�����ַ
	input wire id_wreg,//����׶�ָ���Ƿ�Ҫд��Ŀ�ļĴ���
	input wire[31:0] id_link_address,//����׶ε�ת��ָ��Ҫ����ķ��ص�ַ
	input wire id_is_in_delayslot,//��ǰ����׶�ָ���Ƿ�λ���ӳٲ�
	input wire next_inst_in_delayslot_i,//��һ������׶�ָ���Ƿ�λ���ӳٲ�
	input wire[31:0] id_inst,//��ǰ��������׶ε�ָ��	
	
	//���ݵ�ִ�н׶ε���Ϣ
	output reg[7:0] ex_aluop,//ִ�н׶ε�ָ��Ҫ���е�����������
	output reg[2:0] ex_alusel,//ִ�н׶ε�ָ��Ҫ���е���������
	output reg[31:0] ex_reg1,//ִ�н׶�Դ������1
	output reg[31:0] ex_reg2,//ִ�н׶�Դ������2
	output reg[4:0] ex_wd,//ִ�н׶�Ҫд���Ŀ�ļĴ�����ַ
	output reg ex_wreg,//ִ�н׶��Ƿ�Ҫд��Ŀ�ļĴ���
	output reg[31:0] ex_link_address,//����ִ�н׶ε�ת��ָ��Ҫ����ķ��ص�ַ
    output reg ex_is_in_delayslot,//��ǰ����ִ�н׶ε�ָ���Ƿ�λ���ӳٲ�
	output reg is_in_delayslot_o,//��ǰ��������׶ε�ָ���Ƿ�λ���ӳٲ�
	output reg[31:0] ex_inst//��ǰ����ִ�н׶ε�ָ��
	
);

	always @ (posedge clk) begin
		if (rst == 1'b1 || (stall[2] == 1'b1 && stall[3] == 1'b0)) begin // ��λ״̬����ˮ�߽׶�3����ͣ
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