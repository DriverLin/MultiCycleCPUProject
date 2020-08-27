//////////////////////////////////////////////////////////////////////////////////
// 模块名称: SReg
// 模块功能: 单个寄存器
//          可用于实现IR,DR,PC，ALUResult
//          通过信号可以更新或者保持一个32位数
//////////////////////////////////////////////////////////////////////////////////
module SReg(
    input               clk,
    input               RegWrite,
    input   [31:0]      Data,
    input               rst,

    output  reg[31:0]   Result
);
    reg[31:0]       Reg;
    always@(negedge clk) begin
        if (RegWrite)
            Result <= Data;
    end
    always@(posedge rst) begin
        Result <= {32'h00003000};
    end
endmodule
