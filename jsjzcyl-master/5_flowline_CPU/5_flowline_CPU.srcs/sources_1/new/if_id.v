`timescale 1ns / 1ps

module if_id(
    input wire clk,    // 时钟信号
    input wire rst,    // 复位信号
    input wire[5:0] stall,  // 控制信号

    // 来自取指阶段的信息
    input wire[31:0] if_pc,    // 取指阶段取得的指令对应的地址
    input wire[31:0] if_inst,  // 取指阶段取得的指令

    // 输出到译码阶段的信息
    output reg[31:0] id_pc,     // 译码阶段指令对应地址
    output reg[31:0] id_inst    // 译码阶段指令
);

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            // 如果复位信号为1，将输出复位为零
            id_pc <= 32'h00000000;
            id_inst <= 32'h00000000;
        end else if(stall[1] == 1'b1 && stall[2] == 1'b0) begin
            // 如果控制信号指示译码阶段需要暂停，则输出保持不变
            id_pc <= id_pc;
            id_inst <= id_inst;
        end else if(stall[1] == 1'b0) begin
            // 否则，将输出设置为来自取指阶段的输入
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule