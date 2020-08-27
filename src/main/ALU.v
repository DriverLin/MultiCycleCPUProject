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
`define ALUOP_ANDI  6'b110100
`define ALUOP_ORI   6'b110101
`define ALUOP_XORI  6'b110110
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: ALU
// 模块功能: 算数运算
//          A,B为输入数据
//           ALUOO选择对应为运算,result输出
//////////////////////////////////////////////////////////////////////////////////
module ALU(
    input   [31:0]      A,
    input   [31:0]      B,
    input   [5:0]       ALUOp,
    output  reg[31:0]   result
);
    initial begin
        result = 32'b0;
    end
    always@(*) begin
        case (ALUOp)
            `ALUOP_ADD  :   result = A + B;
            `ALUOP_ADDU :   result = A + B;
            `ALUOP_SUB  :   result = A - B;
            `ALUOP_SUBU :   result = A - B;
            `ALUOP_SLLV :   result = B << A[4:0];
            `ALUOP_SRLV :   result = B >> A[4:0];
            `ALUOP_SRAV :   result = (B >> A[4:0]) | ({32{B[31]}}<<(6'd32-{1'b0,A[4:0]}));
            `ALUOP_AND  :   result = A & B;
            `ALUOP_OR   :   result = A | B;
            `ALUOP_XOR  :   result = A ^ B;
            `ALUOP_NOR  :   result = ~(A | B);
            `ALUOP_ANDI :   result = A & B[15:0];
            `ALUOP_ORI  :   result = A | B[15:0];
            `ALUOP_XORI :   result = A ^ B[15:0];
            `ALUOP_SLT  :   result = ($signed(A) < $signed(B)) ? 1 : 0;
            `ALUOP_SLTU :   result = (A < B) ? 1 : 0;
            `ALUOP_SLL  :   result = B << A[4:0];
            `ALUOP_SRL  :   result = B >> A[4:0];
            `ALUOP_SRA  :   result = (B >> A[4:0]) | ({32{B[31]}}<<(6'd32-{1'b0,A[4:0]}));
            `ALUOP_LUI  :   result = {B[15:0], 16'b0};
            default: result = 32'b0;
        endcase
    end

endmodule
