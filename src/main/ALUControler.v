`define ALUOP_ADD   6'b100000
`define ALUOP_ADDU  6'b100001
`define ALUOP_SUB   6'b100010
`define ALUOP_SUBU  6'b100011
`define ALUOP_SLLV  6'b000100
`define ALUOP_SRLV  6'b000110
`define ALUOP_SRAV  6'b000111
`define ALUOP_AND   6'b100100
`define ALUOP_OR    6'b100101
`define ALUOP_XOR   6'b100110
`define ALUOP_NOR   6'b100111
`define ALUOP_SLT   6'b101010
`define ALUOP_SLTU  6'b101011
`define ALUOP_SLL   6'b000000
`define ALUOP_SRL   6'b000010
`define ALUOP_SRA   6'b000011
`define ALUOP_LUI   6'b110000
`define JROP_JALR   6'b001001
`define JROP_JR     6'b001000
`define ALUOP_ANDI  6'b110100
`define ALUOP_ORI   6'b110101
`define ALUOP_XORI  6'b110110
`define EXTOP_UNSIGNED  2'b00
`define EXTOP_SIGNED    2'b01
`define EXTOP_INST      2'b10
`define ALUCTRL_ADD     2'b00
`define ALUCTRL_ADDU    2'b01
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
`define EXTOP_UNSIGNED  2'b00
`define EXTOP_SIGNED    2'b01
`define EXTOP_INST      2'b10
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: ALUCtrl
// 模块功能: ALU控制单元
//          独立译码 
//          根据对应的指令，控制ALU计算
//          同时也设置运算的数据类型是UNSIGNED或者SIGNED
//////////////////////////////////////////////////////////////////////////////////
module ALUCtrl(
    input   [5:0]       OP,
    input   [5:0]       funct,
    input   [1:0]       ALUCtrlOp,

    output  reg[5:0]    ALUOp,
    output  reg[1:0]    EXTOp
);

    always@(*) begin
        case(ALUCtrlOp)
            `ALUCTRL_ADD: begin//加
                EXTOp = `EXTOP_SIGNED;
                ALUOp = `ALUOP_ADD;
            end
            `ALUCTRL_ADDU: begin//无符号加
                EXTOp = `EXTOP_UNSIGNED;
                ALUOp = `ALUOP_ADD;
            end
            `ALUCTRL_RTYPE: begin//R类
                ALUOp = funct;
            end
            `ALUCTRL_ITYPE: begin//I类
                case(OP)
                    `OP_ADDI:   begin
                        EXTOp   =   `EXTOP_SIGNED;
                        ALUOp   =   `ALUOP_ADD;
                    end
                    `OP_ADDIU:  begin
                        EXTOp   =   `EXTOP_UNSIGNED;
                        ALUOp   =   `ALUOP_ADDU;
                    end
                    `OP_ANDI:   begin
                        EXTOp   =   `EXTOP_UNSIGNED;
                        ALUOp   =   `ALUOP_ANDI;
                    end
                    `OP_ORI:    begin
                        EXTOp   =   `EXTOP_UNSIGNED;
                        ALUOp   =   `ALUOP_ORI;
                    end
                    `OP_XORI:   begin
                        EXTOp   =   `EXTOP_UNSIGNED;
                        ALUOp   =   `ALUOP_XORI;
                    end
                    `OP_LUI:    begin
                        EXTOp   =   `EXTOP_UNSIGNED;
                        ALUOp   =   `ALUOP_LUI;
                    end
                    `OP_SLTI:   begin
                        EXTOp   =   `EXTOP_SIGNED;
                        ALUOp   =   `ALUOP_SLT;
                    end
                    `OP_SLTIU:  begin
                        EXTOp   =   `EXTOP_UNSIGNED;
                        ALUOp   =   `ALUOP_SLTU;
                    end
                    default:    ALUOp = 2'b000000;
                endcase
            end
            default:
                ALUOp = 0;
        endcase
    end

endmodule
