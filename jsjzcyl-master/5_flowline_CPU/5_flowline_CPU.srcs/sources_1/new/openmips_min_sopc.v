`timescale 1ns / 1ps

module openmips_min_sopc(
	input wire clk,//时钟信号
	input wire rst//复位信号
	
);

  //连接指令存储器
  wire[31:0] inst_addr; // 指令地址,从指令存储器中读取指令
  wire[31:0] inst;      // 存储从指令存储器中读取的指令
  wire rom_ce;          // 用于控制指令存储器的片选信号
  wire mem_we_i;        // 写使能信号
  wire[31:0] mem_addr_i;// 数据存储器的地址信号
  wire[31:0] mem_data_i;// 数据存储器的写入数据信号
  wire[31:0] mem_data_o;// 数据存储器的读取数据信号
  wire[3:0] mem_sel_i;  // 数据存储器的选择信号
  wire mem_ce_i;        // 数据存储器的片选信号
 

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
	
	); // 核心模块
	
	inst_rom inst_rom0(
		.ce(rom_ce),
		.addr(inst_addr),
		.inst(inst)	
	); // 实现指令存储器ROM,接收指令存储器的片选信号和地址信号,然后输出对应地址的指令数据

	data_ram data_ram0(
		.clk(clk),
		.ce(mem_ce_i),
		.we(mem_we_i),
		.addr(mem_addr_i),
		.sel(mem_sel_i),
		.data_i(mem_data_i),
		.data_o(mem_data_o)	
	); // 接收时钟信号,数据存储器的片选信号,写使能信号,地址信号,选择信号以及输入数据信号,将数据提供给openmips模块或从openmips模块接收写入的数据

endmodule