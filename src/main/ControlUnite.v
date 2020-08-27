`define ALUOP_SLL   6'b000000
`define ALUOP_SRL   6'b000010
`define ALUOP_SRA   6'b000011
`define JROP_JALR   6'b001001
`define JROP_JR     6'b001000
`define ALUCTRL_ADD     2'b00
`define ALUCTRL_RTYPE   2'b10
`define ALUCTRL_ITYPE   2'b11
`define OP_R    6'b000000
`define OP_LB   6'b100000
`define OP_LBU  6'b100100
`define OP_LH   6'b100001
`define OP_LHU  6'b100101
`define OP_LW   6'b100011
`define OP_SB   6'b101000
`define OP_SH   6'b101001
`define OP_SW   6'b101011
`define OP_ADDI 6'b001000
`define OP_ADDIU 6'b001001
`define OP_ANDI 6'b001100
`define OP_ORI  6'b001101
`define OP_XORI 6'b001110
`define OP_LUI  6'b001111
`define OP_SLTI 6'b001010
`define OP_SLTIU 6'b001011
`define OP_BEQ  6'b000100
`define OP_BNE  6'b000101
`define OP_BLEZ 6'b000110
`define OP_BGTZ 6'b000111
`define OP_BLTZ 6'b000001
`define OP_BGEZ 6'b000001
`define OP_J    6'b000010
`define OP_JAL  6'b000011
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: CU
// 模块功能:主要控制单元
//          控制RF,DM,PC之间的数据流动
//          ALU控制单元的顶层控制信号
//          ALU的数据来源
//          包含状态机来在多周期的不同阶段之间跳转
//          详细描述见文档以及注释
//////////////////////////////////////////////////////////////////////////////////
module CU(
    input               clk,
    input   [5:0]       OP,
    input   [5:0]       funct,
    input   [31:0]      PC,

    output  reg         PCWriteCond,
    output  reg         PCWrite,
    output  reg[1:0]    PCSource,

    output  reg         MemRead,
    output  reg         MemWrite,

    output  reg[1:0]    Mem2Reg,
    output  reg         IRWrite,
    output  reg[1:0]    RegDst,
    output  reg         RegWrite,

    output  reg[1:0]    ALU_A,
    output  reg[1:0]    ALU_B,

    output  reg[1:0]    ALUCtrlOp
);
    integer State;

    initial begin
        State = 0;
    end

    always@(posedge clk) begin
        case (State)
        0:  begin
            // State 0
            // 执行操作: 取指令
            //          PC <= PC+4
            {PCWriteCond,PCWrite,PCSource} = 4'b0100;// 非分支 PC直写 pc <= Data1:DataALUOut
            MemWrite = 0;
            {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b000010;// 指令寄存器更新为IM读取  // mem2reg:Data1=AluResult RegDst:Data1 Reg[Instr[20:16]] 寄存器堆不可写
            {ALU_A,ALU_B,ALUCtrlOp} = {4'b0001,`ALUCTRL_ADD};//ALU_A:A_Data1:PCreg  ALU_B:B_Data2:imm4
            State = 1;
        end
        1:  begin
            // State 0
            // 执行操作: 译码
            {PCWriteCond,PCWrite,PCSource} = 4'b0000;// 非分支 PC不可直写 
            MemWrite = 0;
            {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b000000;// mem2reg:Data1:寄存器编号来自ALU的计算结果 RegDst:Data1 寄存器编号来自Instr[20:16] 指令寄存器保持 寄存器堆不可写
            {ALU_A,ALU_B,ALUCtrlOp} = {4'b0011,`ALUCTRL_ADD};//ALU_A:A_Data1:PCreg  ALU_B:Data4:EXT_imm32*4
            case (OP)
                // R-类指令 仅操作寄存器
                `OP_R: begin
                    case (funct)
                        `JROP_JALR, `JROP_JR://涉及寄存器跳转
                            State = 9;
                        default:            //其他的R类指令 
                            State = 6;
                    endcase
                end
                // 立即数操作
                `OP_ADDI, `OP_ADDIU, `OP_ANDI, `OP_ORI, `OP_XORI, `OP_LUI, `OP_SLTI, `OP_SLTIU:
                    State = 10;
                //  内存操作
                `OP_LB, `OP_LBU, `OP_LH, `OP_LHU, `OP_LW, `OP_SB, `OP_SH, `OP_SW:
                    State = 2;
                // 分支
                `OP_BEQ, `OP_BNE, `OP_BLEZ, `OP_BGTZ, `OP_BLTZ, `OP_BGEZ:
                    State = 8;
                `OP_J, `OP_JAL:
                    State = 9;
                default:    
                    State = 0;
            endcase
        end
        // State 2: lw & sw
        // 执行操作: 选择跳转LW,SW
        2:  begin
            {PCWriteCond,PCWrite,PCSource} = 4'b0000;// 非分支 PC不可直写 
            MemWrite = 0;
            {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b000000;// mem2reg:Data1:寄存器编号来自ALU的计算结果 RegDst:Data1 寄存器编号来自Instr[20:16] 指令寄存器保持 寄存器堆不可写
            {ALU_A,ALU_B,ALUCtrlOp} = {4'b0110,`ALUCTRL_ADD};//ALU_A:A_Data2:RegFileOUT_1  ALU_B:B_Data3:EXT_imm32
            case (OP)
                `OP_LB, `OP_LBU, `OP_LH, `OP_LHU, `OP_LW://mem->reg
                    State = 3;
                `OP_SB, `OP_SH, `OP_SW:                 //reg->mem
                    State = 5;
                default:    
                    State = 0;
            endcase
        end
        // State 3: lw
        // 执行操作: None
        3: begin
            {PCWriteCond,PCWrite,PCSource} = 4'b0000;// 非分支 PC不可直写 
            MemWrite = 0;
            {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b000000;// mem2reg:Data1:寄存器编号来自ALU的计算结果 RegDst:Data1 寄存器编号来自Instr[20:16] 指令寄存器保持 寄存器堆不可写
            {ALU_A,ALU_B,ALUCtrlOp} = {4'b0110,`ALUCTRL_ADD};//ALU_A:A_Data2:RegFileOUT_1  ALU_B:B_Data3:EXT_imm32
            State = 4;
        end
        // State 4: lw 写寄存器
        // 执行操作: regIndex = Instr[20:16]
        //          memAddr = Instr[11:2] 10位 1024范围寻址
        //          reg[regIndex] <= DataMem[memAddr]
        4: begin
            // Signal
            {PCWriteCond,PCWrite,PCSource} = 4'b0000;// 非分支 PC不可直写 
            MemWrite = 0;
            {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b010001;// mem2reg:Data2:寄存器编号来自DataMEM的数据 RegDst:Data1 寄存器编号来自Instr[20:16] 指令寄存器保持 寄存器堆可写
            {ALU_A,ALU_B,ALUCtrlOp} = {4'b0110,`ALUCTRL_ADD};//ALU_A:A_Data2:RegFileOUT_1  ALU_B:B_Data3:EXT_imm32
            State = 0;
        end
        // State 5: sw 写主存
        // 执行操作: regIndex = Instr[20:16]
        //          memAddr = Instr[11:2] 10位 1024范围寻址
        //          DataMem[memAddr] <= reg[regIndex]
        5: begin
            {PCWriteCond,PCWrite,PCSource} = 4'b0000;// 非分支 PC不可直写 
            MemWrite = 1;//写入主存
            {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b000000;// mem2reg:Data1:寄存器编号来自ALU的计算结果 RegDst:Data1 寄存器编号来自Instr[20:16] 指令寄存器保持 寄存器堆不可写
            {ALU_A,ALU_B,ALUCtrlOp} = {4'b0110,`ALUCTRL_ADD};//ALU_A:A_Data2:RegFileOUT_1  ALU_B:B_Data3:EXT_imm32
            State = 0;
        end
        // State 6: R类 运算指令 设置控制信号
        // 执行操作: 设置ALU操作数来源以及ALUop
        //           if funct (即Ins[5:0]) == ALUOP_SLL,ALUOP_SRL,ALUOP_SRA
        //              ALU_A = {27'b0,Ins[10:6]}
        //           else
        //               Alu_A = reg[Instr[25:21]]
        //          Alu_B = reg[Instr[20:16]]
        //          ALUOP = Ins[5:0]
        6:  begin
            {PCWriteCond,PCWrite,PCSource} = 4'b0000;// 非分支 PC不可直写 
            MemWrite = 0;
            {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b000000;// mem2reg:Data1:寄存器编号来自ALU的计算结果 RegDst:Data1 寄存器编号来自Instr[20:16] 指令寄存器保持 寄存器堆不可写
            case(funct)
                `ALUOP_SLL, `ALUOP_SRL, `ALUOP_SRA://位移类R指令 操作数格式为0,RT,RD
                    {ALU_A,ALU_B,ALUCtrlOp} = {4'b1000,`ALUCTRL_RTYPE};//ALU_A:A_Data3:{27{0},Ins[10:6]}  ALU_B:B_Data1:RegFileOUT_2 ALUop = Ins[5:0]
                default:                           //其他R类指令 即操作数格式为 RS,RT,RD
                    {ALU_A,ALU_B,ALUCtrlOp} = {4'b0100,`ALUCTRL_RTYPE};//ALU_A:A_Data2:RegFileOUT_1  ALU_B:B_Data1:RegFileOUT_2 ALUop = Ins[5:0]
            endcase
            State = 7;
        end
        // State 7:  R类 写回
        // 执行操作: reg[Instr[15:11]] <= AluResult
        7:  begin
            {PCWriteCond,PCWrite,PCSource} = 4'b0000;// 非分支 PC不可直写 
            MemWrite = 0;
            {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b000101;// mem2reg:Data1:寄存器编号来自ALU的计算结果 RegDst:Data2 寄存器编号来自Instr[15:11] 指令寄存器保持 寄存器堆可写
            {ALU_A,ALU_B,ALUCtrlOp} = {4'b0100,`ALUCTRL_ADD};//ALU_A:A_Data2:RegFileOUT_1  ALU_B:B_Data1:RegFileOUT_2
            State = 0;
        end
        // State 8: 分支指令执行
        // 执行操作: Alu_A = reg[Instr[25:21]]
        //          Alu_B = {16'bIns[15],Ins[15:0]}
        //          ALUOp = ALUOP_ADD
        //          独立的分支计算模块会计算比较结果,SignalBranch控制是否跳转
        //          如果分支计算模块计算出允许跳转  
        //          则此时则 PCWriteCond==1 && SignalBranch==1  
        //              PC <= AluResult
        8: begin
            {PCWriteCond,PCWrite,PCSource} = 4'b1000;// 分支 PC不可直写  分支结束则 pc <= 4路选择器选择Data1:DataALUOut
            MemWrite = 0;
            {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b000000;// mem2reg:Data1:寄存器编号来自ALU的计算结果 RegDst:Data1 寄存器编号来自Instr[20:16] 指令寄存器保持 寄存器堆不可写
            {ALU_A,ALU_B,ALUCtrlOp} = {4'b0011,`ALUCTRL_ADD};//ALU_A:A_Data1:RegFileOUT_1  ALU_B:Data4:EXT_imm32*4
            State = 0;
        end
        // State 9: Jump / JR
        // 执行操作:if JR
        //              PC <= Reg[Instr[25:21]]
        //          if Jump
        //              PC <= {DataPCReg[31:28], Instr[25:0]*4}  
        9: begin
            if(OP == `OP_R)
                {PCWriteCond,PCWrite,PCSource} = 4'b0111;// 非分支（实际是直接分支 但是不需要计算） PC直写 pc <= 4路选择器选择Data4:DataRFRead1选中寄存器1内容送PC
            else
                {PCWriteCond,PCWrite,PCSource} = 4'b0110;// 非分支（实际是直接分支 但是不需要计算） PC直写 pc <= 4路选择器选择Data3:{DataPCReg[31:28], Instr[25:0], 2'b00}指令给出直接地址，组合内容送PC
            MemWrite = 0;
            if(OP == `OP_J || funct == `JROP_JR)
                {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b101000;// mem2reg:Data3:寄存器编号当前PC值 RegDst:Data3 寄存器编号来自= 5'b11111 指令寄存器保持 寄存器堆不可写
            else
                {Mem2Reg,RegDst,IRWrite,RegWrite}= 6'b101001;// mem2reg:Data3:寄存器编号当前PC值 RegDst:Data3 寄存器编号来自= 5'b11111 指令寄存器保持 寄存器堆可写
            {ALU_A,ALU_B,ALUCtrlOp} = {4'b0011,`ALUCTRL_ADD};//ALU_A:A_Data1:PCreg  ALU_B:Data4:EXT_imm32*4
            State = 0;
        end
        // State 10: I类 执行
        // 执行操作: rs,rt,imm
        //            ALU_A = Reg[Instr[25:21]] 
        //            ALU_B = 扩展32位(Ins[15:0])
        //            ALUOP = 解码    
        10: begin
            {PCWriteCond,PCWrite,PCSource} = 4'b0000;// 非分支 PC不可直写 
            MemWrite = 0;
            {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b000000;// mem2reg:Data1:寄存器编号来自ALU的计算结果 RegDst:Data1 寄存器编号来自Instr[20:16] 指令寄存器保持 寄存器堆不可写
            {ALU_A,ALU_B,ALUCtrlOp} = {4'b0110,`ALUCTRL_ITYPE};//ALU_A:A_Data2:RegFileOUT_1  ALU_B:B_Data3:EXT_imm32
            State = 11;
        end
        // State 11: I类 写回
        // 执行操作: Reg[Instr[20:16]] <= AULResult
        11:  begin
            {PCWriteCond,PCWrite,PCSource} = 4'b0000;// 非分支 PC不可直写 
            MemWrite = 0;
            {Mem2Reg,RegDst,IRWrite,RegWrite} = 6'b000001;// mem2reg:Data1:寄存器编号来自ALU的计算结果 RegDst:Data1 寄存器编号来自Instr[20:16] 指令寄存器保持 寄存器堆可写
            {ALU_A,ALU_B,ALUCtrlOp} = {4'b0100,`ALUCTRL_ADD};//ALU_A:A_Data2:RegFileOUT_1  ALU_B:B_Data1:RegFileOUT_2
            State = 0;
        end
        default: State  = 0;
        endcase
    end
endmodule