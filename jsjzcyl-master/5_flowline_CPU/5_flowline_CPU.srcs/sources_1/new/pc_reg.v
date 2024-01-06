`timescale 1ns / 1ps

module pc_reg(
	input wire clk,//ʱ���ź�
	input wire rst,//��λ�ź�

	//���Կ���ģ�����Ϣ
	input wire[5:0] stall,//�����ź�,�ж���ˮ���Ƿ���ͣ

	//��������׶ε���Ϣ
	input wire branch_flag_i,//�Ƿ���ת��(��֧)
	input wire[31:0] branch_target_address_i,//ת�Ƶ���Ŀ���ַ
	
	output reg[31:0] pc,//Ҫ��ȡ��ָ���ַ
	output reg ce//ָ��洢��ʹ���ź�
	
);

	always @ (posedge clk) begin // �����ش���
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