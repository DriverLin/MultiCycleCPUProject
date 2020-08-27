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
// 模块名称: BranchCtrl
// 模块功能: 分支计算
//          辅助分支计算单元
//          读取指令并独立计算分支结果
//          目标地址由CU同步计算
//          通过BranchSucceedFlag控制PC跳转
//          若分支成功，则当CU允许时就会写PC
//////////////////////////////////////////////////////////////////////////////////

module BranchCtrl(
    input           clk,
    input   [31:0]  A,
    input   [31:0]  B,
    input   [5:0]   OP,
    input   [4:0]   Branch_funct,
    output  reg     BranchSucceed
);
    initial begin
        BranchSucceed = 0;
    end
    always@(negedge clk) begin
        case (OP)
            `OP_BEQ     :   BranchSucceed = A == B ? 1 : 0;
            `OP_BNE     :   BranchSucceed = A != B ? 1 : 0;
            `OP_BLEZ    :   BranchSucceed = $signed(A) <= 0 ? 1 : 0;
            `OP_BGTZ    :   BranchSucceed = $signed(A) > 0 ? 1 : 0;
            `OP_BLTZ, `OP_BGEZ  : begin
                    if (Branch_funct == 5'b00000)
                            BranchSucceed = $signed(A)   <  0       ? 1 : 0;//BLTZ 
                    else
                            BranchSucceed = $signed(A)   >= 0       ? 1 : 0;//BLEZ
            end
            default: BranchSucceed = 0;
        endcase
    end
endmodule
