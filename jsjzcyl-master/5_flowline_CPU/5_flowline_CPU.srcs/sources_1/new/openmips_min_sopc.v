`timescale 1ns / 1ps

module openmips_min_sopc(
	input wire clk,//ʱ���ź�
	input wire rst//��λ�ź�
	
);

  //����ָ��洢��
  wire[31:0] inst_addr; // ָ���ַ,��ָ��洢���ж�ȡָ��
  wire[31:0] inst;      // �洢��ָ��洢���ж�ȡ��ָ��
  wire rom_ce;          // ���ڿ���ָ��洢����Ƭѡ�ź�
  wire mem_we_i;        // дʹ���ź�
  wire[31:0] mem_addr_i;// ���ݴ洢���ĵ�ַ�ź�
  wire[31:0] mem_data_i;// ���ݴ洢����д�������ź�
  wire[31:0] mem_data_o;// ���ݴ洢���Ķ�ȡ�����ź�
  wire[3:0] mem_sel_i;  // ���ݴ洢����ѡ���ź�
  wire mem_ce_i;        // ���ݴ洢����Ƭѡ�ź�
 

 openmips openmips0(
		.clk(clk),
		.rst(rst),
	
		.rom_addr_o(inst_addr),
		.rom_data_i(inst),
		.rom_ce_o(rom_ce),

		.ram_we_o(mem_we_i),
		.ram_addr_o(mem_addr_i),
		.ram_sel_o(mem_sel_i),
		.ram_data_o(mem_data_i),
		.ram_data_i(mem_data_o),
		.ram_ce_o(mem_ce_i)		
	
	); // ����ģ��
	
	inst_rom inst_rom0(
		.ce(rom_ce),
		.addr(inst_addr),
		.inst(inst)	
	); // ʵ��ָ��洢��ROM,����ָ��洢����Ƭѡ�źź͵�ַ�ź�,Ȼ�������Ӧ��ַ��ָ������

	data_ram data_ram0(
		.clk(clk),
		.ce(mem_ce_i),
		.we(mem_we_i),
		.addr(mem_addr_i),
		.sel(mem_sel_i),
		.data_i(mem_data_i),
		.data_o(mem_data_o)	
	); // ����ʱ���ź�,���ݴ洢����Ƭѡ�ź�,дʹ���ź�,��ַ�ź�,ѡ���ź��Լ����������ź�,�������ṩ��openmipsģ����openmipsģ�����д�������

endmodule