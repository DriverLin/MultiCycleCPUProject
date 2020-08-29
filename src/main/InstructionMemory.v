
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: IM
// 模块功能: 指令存储器
//          存储指令
//////////////////////////////////////////////////////////////////////////////////
module IM(
    input               clk,
    input	[11:2]      addr,
    output	reg[31:0]   dout
);
    reg     [31:0]  ROM[1023:0];
    initial begin
        ROM[0] = 0'b00100100000001100000000000010100;
        ROM[1] = 0'b00100100000001010000000000000001;
        ROM[2] = 0'b00100100000001110000000000000001;
        ROM[3] = 0'b00100100000001000000000000000001;
        ROM[4] = 0'b00000000101001111001000000100000;
        ROM[5] = 0'b00100000110001101111111111111111;
        ROM[6] = 0'b00000000000100100010100000100000;
        ROM[7] = 0'b00010000110001000000000000000100;
        ROM[8] = 0'b00000000101001111001000000100000;
        ROM[9] = 0'b00000000000100100011100000100000;
        ROM[10] = 0'b00100000110001101111111111111111;
        ROM[11] = 0'b00010100110001001111111111111000;
        ROM[12] = 0'b00000000000100101001000000100000;
        ROM[14] = 0'b11111111111111111111111111111111;
    end
    always @(posedge clk) begin
        dout = ROM[addr[11:2]][31:0];
    end
endmodule
