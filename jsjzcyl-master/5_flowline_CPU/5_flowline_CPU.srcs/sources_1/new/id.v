`timescale 1ns / 1ps
`include "defines.v"

module id(
	input wire rst,
	input wire[31:0] pc_i,//译码阶段指令对应地址
	input wire[31:0] inst_i,//译码阶段指令

    //处于执行阶段的指令的一些信息，用于解决load相关,load相关指的是，加载指令的下一条指令所要读取的寄存器与load指令访存之后要写回的寄存器相同，从而产生相关。
    input wire[7:0] ex_aluop_i, // 处于执行阶段指令的ALU操作码
	input wire ex_wreg_i,//处于执行阶段的指令是否写目的寄存器
	input wire[31:0] ex_wdata_i,//处于执行阶段的指令要写入目的寄存器的数据
	input wire[4:0] ex_wd_i,//处于执行阶段的指令要写的目的寄存器地址
	
	//处于访存阶段的指令要写入的目的寄存器信息
	input wire mem_wreg_i,//处于访存阶段的指令是否要写目的寄存器
	input wire[31:0] mem_wdata_i,//写入的数据
	input wire[4:0] mem_wd_i,//写入的地址
	
	input wire[31:0] reg1_data_i,//从regfile的第一个读寄存器端口得到的输出
	input wire[31:0] reg2_data_i,//从regfile的第二个读寄存器端口得到的输出

	//如果上一条指令是转移指令，那么下一条指令在译码的时候is_in_delayslot为true
	input wire is_in_delayslot_i, //当前处于译码阶段的指令是否位于延迟槽

	//送到regfile的信息
	output reg reg1_read_o,//regfile模块第一个读寄存器读使能信号
	output reg reg2_read_o,//regfile模块第二个读寄存器读使能信号   
	output reg[4:0] reg1_addr_o,//regfile模块第一个读寄存器读地址信号   
	output reg[4:0] reg2_addr_o,//regfile模块第二个读寄存器读地址信号         
	
	//送到执行阶段的信息
	output reg[7:0] aluop_o,//译码阶段指令要进行的运算的子类型
	output reg[2:0] alusel_o,//译码阶段指令要进行的运算类型
	output reg[31:0] reg1_o,//译码阶段指令源操作数1
	output reg[31:0] reg2_o,//译码阶段指令源操作数2
	output reg[4:0] w_addr_o,//译码阶段指令要写入的目的寄存器地址
	output reg wreg_o,//译码阶段指令是否要写入目的寄存器
	output wire[31:0] inst_o,//当前处于译码阶段的指令

	output reg next_inst_in_delayslot_o,//下一条进入译码阶段的指令是否位于延迟槽
	
	output reg branch_flag_o,//是否转移
	output reg[31:0] branch_target_address_o,//转移到的目的地址   
	output reg[31:0] link_addr_o,//转移指令要保存的返回地址
	output reg is_in_delayslot_o, // 是否位于延迟槽
	
	output wire stallreq // 控制信号,判断流水线是否停顿
);

  wire[5:0] op = inst_i[31:26]; //opcode,用于区分指令功能
  wire[4:0] op2 = inst_i[10:6]; //sa寄存器
  wire[5:0] op3 = inst_i[5:0];  //function
  wire[4:0] op4 = inst_i[20:16];//rt目标寄存器
  reg[31:0]	imm; //立即数
  reg instvalid; //当前指令是否有效
  wire[31:0] pc_plus_8;
  wire[31:0] pc_plus_4;
  wire[31:0] imm_sll2_signedext;  //立即数左移两位并进行符号扩展后的结果

  reg stallreq_for_reg1_loadrelate;
  reg stallreq_for_reg2_loadrelate;
  wire pre_inst_is_load; //流水线暂停逻辑
  
  assign pc_plus_8 = pc_i + 8;
  assign pc_plus_4 = pc_i + 4;
  assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00 };  
  assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate; // 流水线停顿逻辑
  assign pre_inst_is_load = ((ex_aluop_i == `EXE_LB_OP) || 
  							 (ex_aluop_i == `EXE_LBU_OP)||
  							 (ex_aluop_i == `EXE_LH_OP) ||
  							 (ex_aluop_i == `EXE_LHU_OP)||
  							 (ex_aluop_i == `EXE_LW_OP) ||
  							 (ex_aluop_i == `EXE_LWR_OP)||
  							 (ex_aluop_i == `EXE_LWL_OP)||
  							 (ex_aluop_i == `EXE_LL_OP) ||
  							 (ex_aluop_i == `EXE_SC_OP)) ? 1'b1 : 1'b0; // 检测执行阶段是否有加载指令

  assign inst_o = inst_i;
    
	always @ (*) begin	
	   if (rst == 1'b1) begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			w_addr_o <= 5'b00000;
			wreg_o <= 1'b0;
			instvalid <= 1'b0;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= 5'b00000;
			reg2_addr_o <= 5'b00000;
			imm <= 32'h0;	
			link_addr_o <= 32'h00000000;
			branch_target_address_o <= 32'h00000000;
			branch_flag_o <= 1'b0;
			next_inst_in_delayslot_o <= 1'b0;					
	   end else begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			w_addr_o <= inst_i[15:11]; //rd,目标寄存器
			wreg_o <= 1'b0;
			instvalid <= 1'b1;	   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];
			reg2_addr_o <= inst_i[20:16];		
			imm <= 32'h00000000;
			link_addr_o <= 32'h00000000;
			branch_target_address_o <= 32'h00000000;
			branch_flag_o <= 1'b0;	
			next_inst_in_delayslot_o <= 1'b0; 			
		  case (op)
		    `EXE_SPECIAL_INST:begin //特殊指令
		    	case (op2)
		    		5'b00000:begin  // 当op2为空,
		    			case (op3)
		    				`EXE_OR:	begin
		    					wreg_o <= 1'b1;		
		    					aluop_o <= `EXE_OR_OP;       // 或操作
		  						alusel_o <= `EXE_RES_LOGIC;  //逻辑运算
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
							end  
		    				`EXE_AND:	begin
		    					wreg_o <= 1'b1;		
		    					aluop_o <= `EXE_AND_OP;
		  						alusel_o <= `EXE_RES_LOGIC;	  
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;	
		  						instvalid <= 1'b0;	
							end  	
		    				`EXE_XOR:	begin
		    					wreg_o <= 1'b1;		
		    					aluop_o <= `EXE_XOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;	
		  						instvalid <= 1'b0;	
							end  				
		    				`EXE_NOR:	begin
		    					wreg_o <= 1'b1;		
		    					aluop_o <= `EXE_NOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;	
		  						instvalid <= 1'b0;	
							end 
							`EXE_SLLV: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_SLL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
							end 
							`EXE_SRLV: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_SRL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
							end 					
							`EXE_SRAV: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_SRA_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;			
		  					  end
							`EXE_MFHI: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_MFHI_OP;
		  						alusel_o <= `EXE_RES_MOVE;   
		  						reg1_read_o <= 1'b0;	
		  						reg2_read_o <= 1'b0;
		  						instvalid <= 1'b0;	
							end
							`EXE_MFLO: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_MFLO_OP;
		  						alusel_o <= `EXE_RES_MOVE;   
		  						reg1_read_o <= 1'b0;	
		  						reg2_read_o <= 1'b0;
		  						instvalid <= 1'b0;	
							end
							`EXE_MTHI: begin
								wreg_o <= 1'b0;		
								aluop_o <= `EXE_MTHI_OP;
								alusel_o <= `EXE_RES_MOVE;   
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b0;
		  						instvalid <= 1'b0;	
							end
							`EXE_MTLO: begin
								wreg_o <= 1'b0;		
								aluop_o <= `EXE_MTLO_OP;
								alusel_o <= `EXE_RES_MOVE;   
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b0; 
		  						instvalid <= 1'b0;	
							end
							`EXE_MOVN: begin // 如果$rt中的值不为0,则将$rd中的值移动到$rd中
								aluop_o <= `EXE_MOVN_OP;
		  						alusel_o <= `EXE_RES_MOVE;   
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;
								if(reg2_o != 32'h00000000) begin
	 								wreg_o <= 1'b1;
	 							end else begin
	 								wreg_o <= 1'b0;
	 							end
							end
							`EXE_MOVZ: begin
								aluop_o <= `EXE_MOVZ_OP;
		  						alusel_o <= `EXE_RES_MOVE;   
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;
								if(reg2_o == 32'h00000000) begin
	 								wreg_o <= 1'b1;
	 							end else begin
	 								wreg_o <= 1'b0;
	 							end		  							
							end
							`EXE_SLT: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_SLT_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
							end
							`EXE_SLTU: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_SLTU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
							end
							`EXE_SYNC: begin
								wreg_o <= 1'b0;		
								aluop_o <= `EXE_NOP_OP;
		  						alusel_o <= `EXE_RES_NOP;		
		  						reg1_read_o <= 1'b0;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
							end								
							`EXE_ADD: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_ADD_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
							end
							`EXE_ADDU: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_ADDU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
							end
							`EXE_SUB: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_SUB_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
							end
							`EXE_SUBU: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_SUBU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
							end
							`EXE_MULT: begin
								wreg_o <= 1'b0;		
								aluop_o <= `EXE_MULT_OP;
		  						reg1_read_o <= 1'b1;
		  						reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
							end
							`EXE_MULTU: begin
								wreg_o <= 1'b0;		
								aluop_o <= `EXE_MULTU_OP;
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1; 
		  						instvalid <= 1'b0;	
							end
							`EXE_DIV: begin
								wreg_o <= 1'b0;		
								aluop_o <= `EXE_DIV_OP;
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1; 
		  						instvalid <= 1'b0;	
							end
							`EXE_DIVU: begin
								wreg_o <= 1'b0;		
								aluop_o <= `EXE_DIVU_OP;
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b1; 
		  						instvalid <= 1'b0;	
							end			
							`EXE_JR: begin //跳转指令,从寄存器中读取地址并跳转到该地址
								wreg_o <= 1'b0;		
								aluop_o <= `EXE_JR_OP;
		  						alusel_o <= `EXE_RES_JUMP_BRANCH;   
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b0;
		  						link_addr_o <= 32'h00000000;
		  						
                                branch_target_address_o <= reg1_o;
                                branch_flag_o <= 1'b1;
			           
                                next_inst_in_delayslot_o <= 1'b1; // 分支指令后的第一条指令应用延迟槽技术
                                instvalid <= 1'b0;	
								end
							`EXE_JALR: begin
								wreg_o <= 1'b1;		
								aluop_o <= `EXE_JALR_OP;
		  						alusel_o <= `EXE_RES_JUMP_BRANCH;   
		  						reg1_read_o <= 1'b1;	
		  						reg2_read_o <= 1'b0;
		  						w_addr_o <= inst_i[15:11];
		  						link_addr_o <= pc_plus_8;
		  						
                                branch_target_address_o <= reg1_o;
                                branch_flag_o <= 1'b1;
                           
                                next_inst_in_delayslot_o <= 1'b1;
                                instvalid <= 1'b0;	
								end													 											  											
						    default:	begin
						    end
						  endcase
						 end
						default: begin
						end
					endcase	
					end									  
		  	`EXE_ORI:			begin                        //ORI指令,按位或立即数
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				imm <= {16'h0, inst_i[15:0]};	//高16位为零，低16位为 inst_i[15:0]	,I-type指令
				w_addr_o <= inst_i[20:16];  // rt
				instvalid <= 1'b0;	
		  	end
		  	`EXE_ANDI:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_AND_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				imm <= {16'h0, inst_i[15:0]};		
				w_addr_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end	 	
		  	`EXE_XORI:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_XOR_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				imm <= {16'h0, inst_i[15:0]};		
				w_addr_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end	 		
		  	`EXE_LUI:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				imm <= {inst_i[15:0], 16'h0};		
				w_addr_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end			
			`EXE_SLTI:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_SLT_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				w_addr_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end
			`EXE_SLTIU:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_SLTU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				w_addr_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end
			`EXE_PREF:			begin // 预取指令,未实现
		  		wreg_o <= 1'b0;		
		  		aluop_o <= `EXE_NOP_OP;
		  		alusel_o <= `EXE_RES_NOP; 
		  		reg1_read_o <= 1'b0;	
		  		reg2_read_o <= 1'b0;	  	  	
				instvalid <= 1'b0;	
			end						
			`EXE_ADDI:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_ADDI_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				w_addr_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end
			`EXE_ADDIU:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_ADDIU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC;
		  		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				w_addr_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end
			`EXE_J:			begin  // 无条件跳转,J-TYPE指令(31-26opcode,25-0instr-index(偏移量))
		  		wreg_o <= 1'b0;		
		  		aluop_o <= `EXE_J_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  		reg1_read_o <= 1'b0;	
		  		reg2_read_o <= 1'b0;
		  		link_addr_o <= 32'h00000000;
			    branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00}; // 计算分支指令的目标地址
			    branch_flag_o <= 1'b1;
			    next_inst_in_delayslot_o <= 1'b1;		  	
			    instvalid <= 1'b0;	
			end
			`EXE_JAL:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_JAL_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  		reg1_read_o <= 1'b0;	
		  		reg2_read_o <= 1'b0;
		  		w_addr_o <= 5'b11111;	
		  		link_addr_o <= pc_plus_8 ;
			    branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
			    branch_flag_o <= 1'b1;
			    next_inst_in_delayslot_o <= 1'b1;		  	
			    instvalid <= 1'b0;	
			end
			`EXE_BEQ:			begin
		  		wreg_o <= 1'b0;		
		  		aluop_o <= `EXE_BEQ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b1;
		  		instvalid <= 1'b0;	
		  		if(reg1_o == reg2_o) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= 1'b1;
			    	next_inst_in_delayslot_o <= 1'b1;		  	
			    end
			end
			`EXE_BGTZ:			begin
		  		wreg_o <= 1'b0;		
		  		aluop_o <= `EXE_BGTZ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;
		  		instvalid <= 1'b0;	
		  		if((reg1_o[31] == 1'b0) && (reg1_o != 32'h00000000)) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= 1'b1;
			    	next_inst_in_delayslot_o <= 1'b1;		  	
			    end
			end
			`EXE_BLEZ:			begin
		  		wreg_o <= 1'b0;		
		  		aluop_o <= `EXE_BLEZ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;
		  		instvalid <= 1'b0;	
		  		if((reg1_o[31] == 1'b1) || (reg1_o == 32'h00000000)) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= 1'b1;
			    	next_inst_in_delayslot_o <= 1'b1;		  	
			    end
			end
			`EXE_BNE:			begin
		  		wreg_o <= 1'b0;		
		  		aluop_o <= `EXE_BLEZ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b1;
		  		instvalid <= 1'b0;	
		  		if(reg1_o != reg2_o) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= 1'b1;
			    	next_inst_in_delayslot_o <= 1'b1;		  	
			    end
			end
			`EXE_LB:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_LB_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				w_addr_o <= inst_i[20:16]; 
				instvalid <= 1'b0;	
			end
			`EXE_LBU:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_LBU_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				w_addr_o <= inst_i[20:16]; 
				instvalid <= 1'b0;	
			end
			`EXE_LH:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_LH_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				w_addr_o <= inst_i[20:16]; 
				instvalid <= 1'b0;	
			end
			`EXE_LHU:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_LHU_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				w_addr_o <= inst_i[20:16]; 
				instvalid <= 1'b0;	
			end
			`EXE_LW:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_LW_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				w_addr_o <= inst_i[20:16]; 
				instvalid <= 1'b0;	
			end
			`EXE_LL:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_LL_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b0;	  	
				w_addr_o <= inst_i[20:16]; 
				instvalid <= 1'b0;	
			end
			`EXE_LWL:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_LWL_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b1;	  	
				w_addr_o <= inst_i[20:16]; 
				instvalid <= 1'b0;	
			end
			`EXE_LWR:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_LWR_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b1;	  	
				w_addr_o <= inst_i[20:16]; 
				instvalid <= 1'b0;	
			end			
			`EXE_SB:			begin
		  		wreg_o <= 1'b0;		
		  		aluop_o <= `EXE_SB_OP;
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b1; 
		  		instvalid <= 1'b0;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SH:			begin
		  		wreg_o <= 1'b0;		
		  		aluop_o <= `EXE_SH_OP;
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b1; 
		  		instvalid <= 1'b0;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SW:			begin
		  		wreg_o <= 1'b0;		
		  		aluop_o <= `EXE_SW_OP;
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b1; 
		  		instvalid <= 1'b0;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SWL:			begin
		  		wreg_o <= 1'b0;		
		  		aluop_o <= `EXE_SWL_OP;
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b1; 
		  		instvalid <= 1'b0;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SWR:			begin
		  		wreg_o <= 1'b0;		
		  		aluop_o <= `EXE_SWR_OP;
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b1; 
		  		instvalid <= 1'b0;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SC:			begin
		  		wreg_o <= 1'b1;		
		  		aluop_o <= `EXE_SC_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
		  		reg1_read_o <= 1'b1;	
		  		reg2_read_o <= 1'b1;	  	
				w_addr_o <= inst_i[20:16]; 
				instvalid <= 1'b0;	
				alusel_o <= `EXE_RES_LOAD_STORE; 
			end				
			`EXE_REGIMM_INST:		begin
					case (op4)
						`EXE_BGEZ:	begin
							wreg_o <= 1'b0;		
							aluop_o <= `EXE_BGEZ_OP;
                            alusel_o <= `EXE_RES_JUMP_BRANCH; 
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b0;
                            instvalid <= 1'b0;	
                            if(reg1_o[31] == 1'b0) begin
                                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o <= 1'b1;
                                next_inst_in_delayslot_o <= 1'b1;		  	
                            end
						end
						`EXE_BGEZAL:		begin
							wreg_o <= 1'b1;		
							aluop_o <= `EXE_BGEZAL_OP;
                            alusel_o <= `EXE_RES_JUMP_BRANCH; 
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b0;
                            link_addr_o <= pc_plus_8; 
                            w_addr_o <= 5'b11111;  	
                            instvalid <= 1'b0;
                            if(reg1_o[31] == 1'b0) begin
                                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o <= 1'b1;
                                next_inst_in_delayslot_o <= 1'b1;
                            end
						end
						`EXE_BLTZ:		begin
                            wreg_o <= 1'b0;		
                            aluop_o <= `EXE_BGEZAL_OP;
                            alusel_o <= `EXE_RES_JUMP_BRANCH; 
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b0;
                            instvalid <= 1'b0;	
                            if(reg1_o[31] == 1'b1) begin
                                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o <= 1'b1;
                                next_inst_in_delayslot_o <= 1'b1;		  	
                            end
						end
						`EXE_BLTZAL:		begin
							wreg_o <= 1'b1;	
							aluop_o <= `EXE_BGEZAL_OP;
		  				    alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  				    reg1_read_o <= 1'b1;	
		  				    reg2_read_o <= 1'b0;
		  				    link_addr_o <= pc_plus_8;	
		  				    w_addr_o <= 5'b11111; instvalid <= 1'b0;
		  				    if(reg1_o[31] == 1'b1) begin
			    		    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    		    	branch_flag_o <= 1'b1;
			    		    	next_inst_in_delayslot_o <= 1'b1;
			   			    end
						end
						default:	begin
						end
					endcase
				end								
				`EXE_SPECIAL2_INST:		begin
					case ( op3 )
						`EXE_CLZ:		begin
							wreg_o <= 1'b1;		
							aluop_o <= `EXE_CLZ_OP;
		  				    alusel_o <= `EXE_RES_ARITHMETIC; 
		  				    reg1_read_o <= 1'b1;	
		  				    reg2_read_o <= 1'b0;	  	
							instvalid <= 1'b0;	
						end
						`EXE_CLO:		begin
							wreg_o <= 1'b1;		
							aluop_o <= `EXE_CLO_OP;
		  				    alusel_o <= `EXE_RES_ARITHMETIC; 
		  				    reg1_read_o <= 1'b1;	
		  				    reg2_read_o <= 1'b0;	  	
							instvalid <= 1'b0;	
						end
						`EXE_MUL:		begin
							wreg_o <= 1'b1;		
							aluop_o <= `EXE_MUL_OP;
		  				    alusel_o <= `EXE_RES_MUL; 
		  				    reg1_read_o <= 1'b1;	
		  				    reg2_read_o <= 1'b1;	
		  				    instvalid <= 1'b0;	  			
						end
						`EXE_MADD:		begin
							wreg_o <= 1'b0;		
							aluop_o <= `EXE_MADD_OP;
		  				    alusel_o <= `EXE_RES_MUL; 
		  				    reg1_read_o <= 1'b1;	
		  				    reg2_read_o <= 1'b1;	  			
		  				    instvalid <= 1'b0;	
						end
						`EXE_MADDU:		begin
							wreg_o <= 1'b0;		
							aluop_o <= `EXE_MADDU_OP;
		  				    alusel_o <= `EXE_RES_MUL; 
		  				    reg1_read_o <= 1'b1;	
		  				    reg2_read_o <= 1'b1;	  			
		  				    instvalid <= 1'b0;	
						end
						`EXE_MSUB:		begin
							wreg_o <= 1'b0;		
							aluop_o <= `EXE_MSUB_OP;
		  				    alusel_o <= `EXE_RES_MUL; 
		  				    reg1_read_o <= 1'b1;	
		  				    reg2_read_o <= 1'b1;	  			
		  				    instvalid <= 1'b0;	
						end
						`EXE_MSUBU:		begin
							wreg_o <= 1'b0;		
							aluop_o <= `EXE_MSUBU_OP;
		  				    alusel_o <= `EXE_RES_MUL; 
		  				    reg1_read_o <= 1'b1;	
		  				    reg2_read_o <= 1'b1;	  			
		  				    instvalid <= 1'b0;	
						end						
						default:	begin
						end
					endcase      //EXE_SPECIAL_INST2 case
				end																		  	
		    default:			begin
		    end
		  endcase		  //case op
		  
		  if (inst_i[31:21] == 11'b00000000000) begin
                if (op3 == `EXE_SLL) begin
                    wreg_o <= 1'b1;		
                    aluop_o <= `EXE_SLL_OP;
                    alusel_o <= `EXE_RES_SHIFT; 
                    reg1_read_o <= 1'b0;	
                    reg2_read_o <= 1'b1;	  	
                    imm[4:0] <= inst_i[10:6];		
                    w_addr_o <= inst_i[15:11];
                    instvalid <= 1'b0;	
                end else if ( op3 == `EXE_SRL ) begin
                    wreg_o <= 1'b1;		
                    aluop_o <= `EXE_SRL_OP;
                    alusel_o <= `EXE_RES_SHIFT; 
                    reg1_read_o <= 1'b0;	
                    reg2_read_o <= 1'b1;	  	
                    imm[4:0] <= inst_i[10:6];		
                    w_addr_o <= inst_i[15:11];
                    instvalid <= 1'b0;	
                end else if ( op3 == `EXE_SRA ) begin
                    wreg_o <= 1'b1;		
                    aluop_o <= `EXE_SRA_OP;
                    alusel_o <= `EXE_RES_SHIFT; 
                    reg1_read_o <= 1'b0;	
                    reg2_read_o <= 1'b1;	  	
                    imm[4:0] <= inst_i[10:6];		
                    w_addr_o <= inst_i[15:11];
                    instvalid <= 1'b0;	
				end
		  end		  
		  
		end       //if
	end         //always
	

	always @ (*) begin // 寄存器reg_1的更新逻辑
	   stallreq_for_reg1_loadrelate <= 1'b0;	
	   if(rst == 1'b1) begin
	   	   reg1_o <= 32'h00000000;	
	   end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o 
	   						&& reg1_read_o == 1'b1 ) begin
	       stallreq_for_reg1_loadrelate <= 1'b1;			// 当前一指令为加载指令,且执行阶段写入目标寄存器与reg1_o地址相同且需要读取reg_1时,设置其为1		
	       //用于解决数据相关,解决涉及读写数据寄存器的潜在冲突		
	   end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
	   						&& (ex_wd_i == reg1_addr_o)) begin
	   	   reg1_o <= ex_wdata_i;  // 当前一指令非加载指令,且执行阶段写使能为1,且写目标寄存器与reg1_o地址相同,则...
	   end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
	   						&& (mem_wd_i == reg1_addr_o)) begin
	   	   reg1_o <= mem_wdata_i; // 当内存阶段写使能为1,且写目标寄存器与reg1_o地址相同,则将reg1_o更新为内存阶段写入的数据			
	   end else if(reg1_read_o == 1'b1) begin
	  	   reg1_o <= reg1_data_i;
	   end else if(reg1_read_o == 1'b0) begin
	  	   reg1_o <= imm;
	   end else begin
	       reg1_o <= 32'h00000000;
	   end
	end
	
	always @ (*) begin
		stallreq_for_reg2_loadrelate <= 1'b0;
		if(rst == 1'b1) begin
			reg2_o <= 32'h00000000;
		end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o 
								&& reg2_read_o == 1'b1 ) begin
		    stallreq_for_reg2_loadrelate <= 1'b1;			
		end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg2_addr_o)) begin
			reg2_o <= ex_wdata_i; 
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg2_addr_o)) begin
			reg2_o <= mem_wdata_i;			
	    end else if(reg2_read_o == 1'b1) begin
	  	    reg2_o <= reg2_data_i;
	    end else if(reg2_read_o == 1'b0) begin
	  	    reg2_o <= imm;
	    end else begin
	       reg2_o <= 32'h00000000;
	    end
	end

	always @ (*) begin
		if(rst == 1'b1) begin
			is_in_delayslot_o <= 1'b0;  // 表示在复位状态下,不处于延迟槽中
		end else begin
		    is_in_delayslot_o <= is_in_delayslot_i;		
	    end
	end

endmodule