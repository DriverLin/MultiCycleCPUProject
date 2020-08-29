text = '''
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
{}
    end
    always @(posedge clk) begin
        dout = ROM[addr[11:2]][31:0];
    end
endmodule
'''

ROMcodes = ""
bincodeText = open(
    r"D:\工作\programs\组成原理实验\006\MultiCycleCPUProject\MultiCycleCPUProject\src\out").read()
count = 0
for binCodeLine in bincodeText.splitlines():
    line = "ROM[{}] = 0'b{};\n".format(count, binCodeLine)
    count += 1
    ROMcodes += line
count += 1
ROMcodes += "ROM[{}] = 0'b{};\n".format(count, "1"*32)
text = text.format(ROMcodes)
with open(r"D:\工作\programs\组成原理实验\006\MultiCycleCPUProject\MultiCycleCPUProject\src\main\InstructionMemory.v", 'w', encoding='utf-8') as f:
    f.write(text)
