//////////////////////////////////////////////////////////////////////////////////
// 模块名称: RF
// 模块功能: 寄存器堆
//          寄存器阵列，包含32个寄存器
//          可同时读取两位
//          时钟下降沿使能则写入
//////////////////////////////////////////////////////////////////////////////////
module RF(
    input   clk,
    input   RegWrite,

    input   [4:0]   ReadAddr1, 
    input   [4:0]   ReadAddr2, 

    input   [4:0]   WriteAddr, 
    input   [31:0]  WriteData, 
    
    output  [31:0]  ReadData1, 
    output  [31:0]  ReadData2 
);
    reg[31:0]   register[31:0];
    integer     i;
    initial begin
        for(i = 0; i < 32; i = i + 1)
            register[i] = 0;
    end
    always@(negedge clk) begin
        if (WriteAddr != 0 && RegWrite) begin
            register[WriteAddr] = WriteData[31:0];
        end
    end
    assign ReadData1 = register[ReadAddr1];
    assign ReadData2 = register[ReadAddr2];

endmodule
