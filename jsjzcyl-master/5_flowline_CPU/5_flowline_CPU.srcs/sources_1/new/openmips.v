`timescale 1ns / 1ps

module openmips(
	input wire clk,//时钟信号
	input wire rst,//复位信号
	
	input wire[31:0] rom_data_i,//从指令存储器取得的指令
	output wire[31:0] rom_addr_o,//输出到指令存储器的地址
	output wire rom_ce_o,//指令存储器使能信号
	
  //连接数据存储器data_ram
	input wire[31:0] ram_data_i,//从数据存储器读取的数据
	output wire[31:0] ram_addr_o,//要访存的数据存储器地址
	output wire[31:0] ram_data_o,//要写入数据存储器的数据
	output wire ram_we_o,//是否是对数据存储器的写操作
	output wire[3:0] ram_sel_o,//字节选择信号
	output wire[3:0] ram_ce_o//数据存储器使能信号
	
);

	wire[31:0] pc;
	wire[31:0] id_pc_i;  // 译码阶段的程序计数器
	wire[31:0] id_inst_i;// 译码阶段的指令
	
	//连接译码阶段ID模块的输出与ID/EX模块的输入
	wire[7:0] id_aluop_o;
	wire[2:0] id_alusel_o;
	wire[31:0] id_reg1_o;
	wire[31:0] id_reg2_o;
	wire id_wreg_o;
	wire[4:0] id_w_addr_o;
	wire id_is_in_delayslot_o;
    wire[31:0] id_link_address_o;	
    wire[31:0] id_inst_o;
	
	//连接ID/EX模块的输出与执行阶段EX模块的输入
	wire[7:0] ex_aluop_i;
	wire[2:0] ex_alusel_i;
	wire[31:0] ex_reg1_i;
	wire[31:0] ex_reg2_i;
	wire ex_wreg_i;
	wire[4:0] ex_wd_i;
	wire ex_is_in_delayslot_i;	
    wire[31:0] ex_link_address_i;	
    wire[31:0] ex_inst_i;
	
	//连接执行阶段EX模块的输出与EX/MEM模块的输入
	wire ex_wreg_o;
	wire[4:0] ex_w_addr_o;
	wire[31:0] ex_wdata_o;
	wire[31:0] ex_hi_o;
	wire[31:0] ex_lo_o;
	wire ex_whilo_o;
	wire[7:0] ex_aluop_o;
	wire[31:0] ex_mem_addr_o;
	wire[31:0] ex_reg1_o;
	wire[31:0] ex_reg2_o;	

	//连接EX/MEM模块的输出与访存阶段MEM模块的输入
	wire mem_wreg_i;
	wire[4:0] mem_wd_i;
	wire[31:0] mem_wdata_i;
	wire[31:0] mem_hi_i;
	wire[31:0] mem_lo_i;
	wire mem_whilo_i;		
	wire[7:0] mem_aluop_i;
	wire[31:0] mem_mem_addr_i;
	wire[31:0] mem_reg1_i;
	wire[31:0] mem_reg2_i;		

	//连接访存阶段MEM模块的输出与MEM/WB模块的输入
	wire mem_wreg_o;
	wire[4:0] mem_w_addr_o;
	wire[31:0] mem_wdata_o;
	wire[31:0] mem_hi_o;
	wire[31:0] mem_lo_o;
	wire mem_whilo_o;	
	wire mem_LLbit_value_o;
	wire mem_LLbit_we_o;		
	
	//连接MEM/WB模块的输出与回写阶段的输入	
	wire wb_wreg_i;
	wire[4:0] wb_wd_i;
	wire[31:0] wb_wdata_i;
	wire[31:0] wb_hi_i;
	wire[31:0] wb_lo_i;
	wire wb_whilo_i;	
	wire wb_LLbit_value_i;
	wire wb_LLbit_we_i;	
	
	//连接译码阶段ID模块与通用寄存器Regfile模块
    wire reg1_read;
    wire reg2_read;
    wire[31:0] reg1_data;
    wire[31:0] reg2_data;
    wire[4:0] reg1_addr;
    wire[4:0] reg2_addr;

	//连接执行阶段与hilo模块的输出，读取HI、LO寄存器
	wire[31:0] 	hi;
	wire[31:0] lo;

  //连接执行阶段与ex_reg模块，用于多周期的MADD、MADDU、MSUB、MSUBU指令
	wire[63:0] hilo_temp_o;
	wire[1:0] cnt_o;
	
	wire[63:0] hilo_temp_i;
	wire[1:0] cnt_i;

	wire[63:0] div_result;
	wire div_ready;
	wire[31:0] div_opdata1;
	wire[31:0] div_opdata2;
	wire div_start;
	wire div_annul;
	wire signed_div;

	wire is_in_delayslot_i;
	wire is_in_delayslot_o;
	wire next_inst_in_delayslot_o;
	wire id_branch_flag_o;
	wire[31:0] branch_target_address;

	wire[5:0] stall;
	wire stallreq_from_id;	
	wire stallreq_from_ex;

	wire LLbit_o;
  
  //pc_reg例化
	pc_reg pc_reg0(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.branch_flag_i(id_branch_flag_o),
		.branch_target_address_i(branch_target_address),		
		.pc(pc),
		.ce(rom_ce_o)	
			
	);
	
  assign rom_addr_o = pc;   //取指

  //IF_ID模块例化
	if_id if_id0(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.if_pc(pc),
		.if_inst(rom_data_i),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i)      	
	);     // 取指->译码
	
	//译码阶段ID模块
	id id0(
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),
  	    .ex_aluop_i(ex_aluop_o),
		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),
	  //处于执行阶段的指令要写入的目的寄存器信息
		.ex_wreg_i(ex_wreg_o),
		.ex_wdata_i(ex_wdata_o),
		.ex_wd_i(ex_w_addr_o),
	  //处于访存阶段的指令要写入的目的寄存器信息
		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		.mem_wd_i(mem_w_addr_o),
	    .is_in_delayslot_i(is_in_delayslot_i),
		//送到regfile的信息
		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read), 	  
		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 
		//送到ID_EX模块的信息
		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.w_addr_o(id_w_addr_o),
		.wreg_o(id_wreg_o),
		.inst_o(id_inst_o),
	 	.next_inst_in_delayslot_o(next_inst_in_delayslot_o),	
		.branch_flag_o(id_branch_flag_o),
		.branch_target_address_o(branch_target_address),       
		.link_addr_o(id_link_address_o),
		.is_in_delayslot_o(id_is_in_delayslot_o),
		.stallreq(stallreq_from_id)		
	);

  //通用寄存器Regfile例化
	regfile regfile1(
		.clk (clk),
		.rst (rst),
		.we	(wb_wreg_i),
		.waddr (wb_wd_i),
		.wdata (wb_wdata_i),
		.re1 (reg1_read),
		.raddr1 (reg1_addr),
		.rdata1 (reg1_data),
		.re2 (reg2_read),
		.raddr2 (reg2_addr),
		.rdata2 (reg2_data)
	);

	//ID_EX模块例化
	id_ex id_ex0(
		.clk(clk),
		.rst(rst),
		
		.stall(stall),
		
		//从译码阶段ID模块传递的信息
		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_w_addr_o),
		.id_wreg(id_wreg_o),
		.id_link_address(id_link_address_o),
		.id_is_in_delayslot(id_is_in_delayslot_o),
		.next_inst_in_delayslot_i(next_inst_in_delayslot_o),		
		.id_inst(id_inst_o),		
	
		//传递到执行阶段EX模块的信息
		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.ex_link_address(ex_link_address_i),
  	    .ex_is_in_delayslot(ex_is_in_delayslot_i),
		.is_in_delayslot_o(is_in_delayslot_i),
		.ex_inst(ex_inst_i)		
	);		// 译码->执行
	
	//EX模块
	ex ex0(
		.rst(rst),
	
		//送到执行阶段EX模块的信息
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
		.hi_i(hi),
		.lo_i(lo),
		.inst_i(ex_inst_i),

	    .wb_hi_i(wb_hi_i),
	    .wb_lo_i(wb_lo_i),
	    .wb_whilo_i(wb_whilo_i),
	    .mem_hi_i(mem_hi_o),
	    .mem_lo_i(mem_lo_o),
	    .mem_whilo_i(mem_whilo_o),

	    .hilo_temp_i(hilo_temp_i),
	    .cnt_i(cnt_i),

		.div_result_i(div_result),
		.div_ready_i(div_ready), 

	    .link_address_i(ex_link_address_i),
		.is_in_delayslot_i(ex_is_in_delayslot_i),	  
			  
	    //EX模块的输出到EX/MEM模块信息
		.w_addr_o(ex_w_addr_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),

		.hi_o(ex_hi_o),
		.lo_o(ex_lo_o),
		.whilo_o(ex_whilo_o),

		.hilo_temp_o(hilo_temp_o),
		.cnt_o(cnt_o),

		.div_opdata1_o(div_opdata1),
		.div_opdata2_o(div_opdata2),
		.div_start_o(div_start),
		.signed_div_o(signed_div),	

		.aluop_o(ex_aluop_o),
		.mem_addr_o(ex_mem_addr_o),
		.reg2_o(ex_reg2_o),
		
		.stallreq(stallreq_from_ex)     				
		
	);

  //EX_MEM模块
  ex_mem ex_mem0(
		.clk(clk),
		.rst(rst),
	  
	    .stall(stall),
	  
		//来自执行阶段EX模块的信息	
		.ex_wd(ex_w_addr_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
		.ex_hi(ex_hi_o),
		.ex_lo(ex_lo_o),
		.ex_whilo(ex_whilo_o),		

  	    .ex_aluop(ex_aluop_o),
		.ex_mem_addr(ex_mem_addr_o),
		.ex_reg2(ex_reg2_o),			

		.hilo_i(hilo_temp_o),
		.cnt_i(cnt_o),	

		//送到访存阶段MEM模块的信息
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
		.mem_hi(mem_hi_i),
		.mem_lo(mem_lo_i),
		.mem_whilo(mem_whilo_i),

  	    .mem_aluop(mem_aluop_i),
		.mem_mem_addr(mem_mem_addr_i),
		.mem_reg2(mem_reg2_i),
				
		.hilo_o(hilo_temp_i),
		.cnt_o(cnt_i)
						       	
	); // 执行->访存阶段
	
  //MEM模块例化
	mem mem0(
		.rst(rst),
	
		//来自EX/MEM模块的信息	
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),
		.hi_i(mem_hi_i),
		.lo_i(mem_lo_i),
		.whilo_i(mem_whilo_i),		

  	    .aluop_i(mem_aluop_i),
		.mem_addr_i(mem_mem_addr_i),
		.reg2_i(mem_reg2_i),
	
		//来自memory的信息
		.mem_data_i(ram_data_i),

		//LLbit_i是LLbit寄存器的值
		.LLbit_i(LLbit_o),
		//但不一定是最新值，回写阶段可能要写LLbit，所以还要进一步判断
		.wb_LLbit_we_i(wb_LLbit_we_i),
		.wb_LLbit_value_i(wb_LLbit_value_i),

		.LLbit_we_o(mem_LLbit_we_o),
		.LLbit_value_o(mem_LLbit_value_o),
	  
		//送到MEM/WB模块的信息
		.w_addr_o(mem_w_addr_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
		.hi_o(mem_hi_o),
		.lo_o(mem_lo_o),
		.whilo_o(mem_whilo_o),
		
		//送到memory的信息
		.mem_addr_o(ram_addr_o),
		.mem_we_o(ram_we_o),
		.mem_sel_o(ram_sel_o),
		.mem_data_o(ram_data_o),
		.mem_ce_o(ram_ce_o)		
	);  // 访存阶段

  //MEM/WB模块
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),

        .stall(stall),

		//来自访存阶段MEM模块的信息	
		.mem_wd(mem_w_addr_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
		.mem_hi(mem_hi_o),
		.mem_lo(mem_lo_o),
		.mem_whilo(mem_whilo_o),		

		.mem_LLbit_we(mem_LLbit_we_o),
		.mem_LLbit_value(mem_LLbit_value_o),						
	
		//送到回写阶段的信息
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i),
		.wb_hi(wb_hi_i),
		.wb_lo(wb_lo_i),
		.wb_whilo(wb_whilo_i),

		.wb_LLbit_we(wb_LLbit_we_i),
		.wb_LLbit_value(wb_LLbit_value_i)				
									       	
	); // 访存->回写阶段

	hilo_reg hilo_reg0(
		.clk(clk),
		.rst(rst),
	
		//写端口
		.we(wb_whilo_i),
		.hi_i(wb_hi_i),
		.lo_i(wb_lo_i),
	
		//读端口1
		.hi_o(hi),
		.lo_o(lo)	
	); // hi,lo寄存器,分别用于存储乘法结果的高32位和乘法结果的低32位以及存储除法的余数和商
	
	ctrl ctrl0(
		.rst(rst),
	    //来自译码阶段的暂停请求
		.stallreq_from_id(stallreq_from_id),
  	    //来自执行阶段的暂停请求
		.stallreq_from_ex(stallreq_from_ex),
        //整个流水线是否应该停顿
		.stall(stall)       	
	);  // 实现结构相关的逻辑

	div div0(
		.clk(clk),
		.rst(rst),
	
		.signed_div_i(signed_div),
		.opdata1_i(div_opdata1),
		.opdata2_i(div_opdata2),
		.start_i(div_start),
		.annul_i(1'b0),
	
		.result_o(div_result),
		.ready_o(div_ready)
	);

	LLbit_reg LLbit_reg0(
		.clk(clk),
		.rst(rst),
	    .flush(1'b0),
	  
		//写端口
		.LLbit_i(wb_LLbit_value_i),
		.we(wb_LLbit_we_i),
	
		//读端口1
		.LLbit_o(LLbit_o)
	
	);// 用于实现原子操作,在使用LL和SC指令时,处理器会使用LLbit来判断在两个指令之间是否有其他处理器对相同的内存位置进行修改,如果有,SC操作失败.
	
endmodule