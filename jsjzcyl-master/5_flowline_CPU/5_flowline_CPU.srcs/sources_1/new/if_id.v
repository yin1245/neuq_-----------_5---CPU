`timescale 1ns / 1ps

module if_id(
    input wire clk,    // ʱ���ź�
    input wire rst,    // ��λ�ź�
    input wire[5:0] stall,  // �����ź�

    // ����ȡָ�׶ε���Ϣ
    input wire[31:0] if_pc,    // ȡָ�׶�ȡ�õ�ָ���Ӧ�ĵ�ַ
    input wire[31:0] if_inst,  // ȡָ�׶�ȡ�õ�ָ��

    // ���������׶ε���Ϣ
    output reg[31:0] id_pc,     // ����׶�ָ���Ӧ��ַ
    output reg[31:0] id_inst    // ����׶�ָ��
);

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            // �����λ�ź�Ϊ1���������λΪ��
            id_pc <= 32'h00000000;
            id_inst <= 32'h00000000;
        end else if(stall[1] == 1'b1 && stall[2] == 1'b0) begin
            // ��������ź�ָʾ����׶���Ҫ��ͣ����������ֲ���
            id_pc <= id_pc;
            id_inst <= id_inst;
        end else if(stall[1] == 1'b0) begin
            // ���򣬽��������Ϊ����ȡָ�׶ε�����
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule