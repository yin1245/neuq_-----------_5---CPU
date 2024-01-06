//指令
`define EXE_AND             6'b100100 // 按位与
`define EXE_OR              6'b100101 // 按位或
`define EXE_XOR             6'b100110 // 按位异或
`define EXE_NOR             6'b100111 // 按位或非
`define EXE_ANDI            6'b001100 // 按位与立即数
`define EXE_ORI             6'b001101 // 按位或立即数
`define EXE_XORI            6'b001110 // 按位异或立即数
`define EXE_LUI             6'b001111 // 加载立即数的高位到目标寄存器中
`define EXE_SLL             6'b000000 // 逻辑左移
`define EXE_SLLV            6'b000100 // 逻辑左移变量,通过变量的值确定左移的位数
`define EXE_SRL             6'b000010 // 逻辑右移
`define EXE_SRLV            6'b000110 // 逻辑右移变量
`define EXE_SRA             6'b000011 // 算数右移
`define EXE_SRAV            6'b000111 // 算数右移变量
`define EXE_SYNC            6'b001111 // 同步指令
`define EXE_PREF            6'b110011 // 预取指令,提前加载指令到高速缓存中
`define EXE_MOVZ            6'b001010 // 如果$rt中的值为0,则将寄存器2中的值移动到寄存器1中
`define EXE_MOVN            6'b001011 // 如果$rt中的值不为0,则将寄存器2中的值移动到寄存器1中
`define EXE_MFHI            6'b010000 // 将HI寄存器中的值移动到目标寄存器
`define EXE_MTHI            6'b010001 // 将源寄存器的值移动到HI寄存器
`define EXE_MFLO            6'b010010 // 将LO寄存器中的值移动到目标寄存器
`define EXE_MTLO            6'b010011 // 将源寄存器的值移动到LO寄存器
`define EXE_SLT             6'b101010 // 如果$rs中的值小于$rt中的值，则将$rd中的值设置为1；否则设置为0
`define EXE_SLTU            6'b101011 // 如果$rs中的值无符号小于$rt中的值，则将$rd中的值设置为1；否则设置为0
`define EXE_SLTI            6'b001010 // 如果$rs中的值小于立即数，则将$rd中的值设置为1；否则设置为0
`define EXE_SLTIU           6'b001011 // 如果$rs中的值无符号小于立即数，则将$rd中的值设置为1；否则设置为0
`define EXE_ADD             6'b100000 // 加法指令
`define EXE_ADDU            6'b100001 // 无符号加法
`define EXE_SUB             6'b100010 // 减法指令
`define EXE_SUBU            6'b100011 // 无符号减法
`define EXE_ADDI            6'b001000 // 加法立即数指令
`define EXE_ADDIU           6'b001001 // 无符号加法立即数指令
`define EXE_CLZ             6'b100000 // 计算左侧零的数量
`define EXE_CLO             6'b100001 // 计算左侧一的数量
`define EXE_MULT            6'b011000 // 有符号乘法
`define EXE_MULTU           6'b011001 // 无符号乘法
`define EXE_MUL             6'b000010 // 有符号整数乘法
`define EXE_MADD            6'b000000 // 有符号整数乘加
`define EXE_MADDU           6'b000001 // 无符号整数乘加
`define EXE_MSUB            6'b000100 // 有符号整数乘减
`define EXE_MSUBU           6'b000101 // 无符号整数乘减
`define EXE_DIV             6'b011010 // 有符号整数除法
`define EXE_DIVU            6'b011011 // 无符号整数除法
`define EXE_J               6'b000010 // 无条件跳转
`define EXE_JAL             6'b000011 // 跳转并链接指令，保存当前指令地址到指令寄存器$ra，然后跳转到指定地址
`define EXE_JALR            6'b001001 // 寄存器间接跳转并链接指令
`define EXE_JR              6'b001000 // 寄存器跳转指令，从寄存器中读取地址并跳转到该地址
`define EXE_BEQ             6'b000100 // 如果两个寄存器的值相等，则进行分支
`define EXE_BGEZ            5'b00001 // 大于等于零分支
`define EXE_BGEZAL          5'b10001 // 大于等于零并链接分支
`define EXE_BGTZ            6'b000111 // 大于零分支
`define EXE_BLEZ            6'b000110 // 小于等于零分支
`define EXE_BLTZ            5'b00000 // 小于零分支
`define EXE_BLTZAL          5'b10000 // 小于零并链接分支
`define EXE_BNE             6'b000101 // 如果两个寄存器的值不等，则进行分支
`define EXE_LB              6'b100000 // 加载字节
`define EXE_LBU             6'b100100 // 加载无符号字节
`define EXE_LH              6'b100001 // 加载半字
`define EXE_LHU             6'b100101 // 加载无符号半字
`define EXE_LL              6'b110000 // 加载链接
`define EXE_LW              6'b100011 // 从存储器中加载一个字（32位数据）到寄存器中
`define EXE_LWL             6'b100010 // 加载左半字
`define EXE_LWR             6'b100110 // 加载右半字
`define EXE_SB              6'b101000 // 存储字节
`define EXE_SC              6'b111000 // 存储链接
`define EXE_SH              6'b101001 // 存储半字
`define EXE_SW              6'b101011 // 将寄存器中的一个字存储到存储器中
`define EXE_SWL             6'b101010 // 存储左半字
`define EXE_SWR             6'b101110 // 存储右半字
`define EXE_NOP             6'b000000 // 空操作指令
`define SSNOP               32'b00000000000000000000000001000000 // Sun SPARC NOP,每一位表示指令的不同字段,被用于在指令流中插入延迟
`define EXE_SPECIAL_INST    6'b000000 // 特殊指令
`define EXE_REGIMM_INST     6'b000001 // 寄存器立即数指令
`define EXE_SPECIAL2_INST   6'b011100 // 特殊2指令


//AluOp
`define EXE_AND_OP          8'b00100100
`define EXE_OR_OP           8'b00100101
`define EXE_XOR_OP          8'b00100110
`define EXE_NOR_OP          8'b00100111
`define EXE_ANDI_OP         8'b01011001
`define EXE_ORI_OP          8'b01011010
`define EXE_XORI_OP         8'b01011011
`define EXE_LUI_OP          8'b01011100   
`define EXE_SLL_OP          8'b01111100
`define EXE_SLLV_OP         8'b00000100
`define EXE_SRL_OP          8'b00000010
`define EXE_SRLV_OP         8'b00000110
`define EXE_SRA_OP          8'b00000011
`define EXE_SRAV_OP         8'b00000111
`define EXE_MOVZ_OP         8'b00001010
`define EXE_MOVN_OP         8'b00001011
`define EXE_MFHI_OP         8'b00010000
`define EXE_MTHI_OP         8'b00010001
`define EXE_MFLO_OP         8'b00010010
`define EXE_MTLO_OP         8'b00010011
`define EXE_SLT_OP          8'b00101010
`define EXE_SLTU_OP         8'b00101011
`define EXE_SLTI_OP         8'b01010111
`define EXE_SLTIU_OP        8'b01011000   
`define EXE_ADD_OP          8'b00100000
`define EXE_ADDU_OP         8'b00100001
`define EXE_SUB_OP          8'b00100010
`define EXE_SUBU_OP         8'b00100011
`define EXE_ADDI_OP         8'b01010101
`define EXE_ADDIU_OP        8'b01010110
`define EXE_CLZ_OP          8'b10110000
`define EXE_CLO_OP          8'b10110001
`define EXE_MULT_OP         8'b00011000
`define EXE_MULTU_OP        8'b00011001
`define EXE_MUL_OP          8'b10101001
`define EXE_MADD_OP         8'b10100110
`define EXE_MADDU_OP        8'b10101000
`define EXE_MSUB_OP         8'b10101010
`define EXE_MSUBU_OP        8'b10101011
`define EXE_DIV_OP          8'b00011010
`define EXE_DIVU_OP         8'b00011011
`define EXE_J_OP            8'b01001111
`define EXE_JAL_OP          8'b01010000
`define EXE_JALR_OP         8'b00001001
`define EXE_JR_OP           8'b00001000
`define EXE_BEQ_OP          8'b01010001
`define EXE_BGEZ_OP         8'b01000001
`define EXE_BGEZAL_OP       8'b01001011
`define EXE_BGTZ_OP         8'b01010100
`define EXE_BLEZ_OP         8'b01010011
`define EXE_BLTZ_OP         8'b01000000
`define EXE_BLTZAL_OP       8'b01001010
`define EXE_BNE_OP          8'b01010010
`define EXE_LB_OP           8'b11100000
`define EXE_LBU_OP          8'b11100100
`define EXE_LH_OP           8'b11100001
`define EXE_LHU_OP          8'b11100101
`define EXE_LL_OP           8'b11110000
`define EXE_LW_OP           8'b11100011
`define EXE_LWL_OP          8'b11100010
`define EXE_LWR_OP          8'b11100110
`define EXE_PREF_OP         8'b11110011
`define EXE_SB_OP           8'b11101000
`define EXE_SC_OP           8'b11111000
`define EXE_SH_OP           8'b11101001
`define EXE_SW_OP           8'b11101011
`define EXE_SWL_OP          8'b11101010
`define EXE_SWR_OP          8'b11101110
`define EXE_SYNC_OP         8'b00001111
`define EXE_NOP_OP          8'b00000000
//AluSel
`define EXE_RES_LOGIC 3'b001 // 逻辑运算
`define EXE_RES_SHIFT 3'b010 // 位移运算
`define EXE_RES_MOVE 3'b011	  // 数据移动操作
`define EXE_RES_ARITHMETIC 3'b100	// 算术运算
`define EXE_RES_MUL 3'b101  // 乘法运算
`define EXE_RES_JUMP_BRANCH 3'b110 // 跳转和分支操作
`define EXE_RES_LOAD_STORE 3'b111	// 加载和存储操作
`define EXE_RES_NOP 3'b000 // 空操作

//指令存储器inst_rom
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131071
`define InstMemNumLog2 17

//数据存储器data_ram
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 131071
`define DataMemNumLog2 17
`define ByteWidth 7:0

//除法div
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivResultReady 1'b1
`define DivResultNotReady 1'b0
`define DivStart 1'b1
`define DivStop 1'b0