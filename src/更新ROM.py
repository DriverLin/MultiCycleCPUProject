text = '''
module im(
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
        //$display("IM get addr: %x, dout: %x<-%b", addr, dout, dout);
    end
endmodule
'''


ROMcodes = ""
bincodeText = open(
    r"D:\工作\programs\组成原理实验\006\examples\MultiCycleCPU_MIPS\tool\bincode.out").read()
count = 0
for binCodeLine in bincodeText.splitlines():
    line = "ROM[{}] = 0'b{};\n".format(count, binCodeLine)
    count += 1
    ROMcodes += line

text = text.format(ROMcodes)

# print(text)

with open(r"D:\工作\programs\组成原理实验\006\examples\MultiCycleCPU_MIPS\src\main\im.v", 'w') as f:
    f.write(text)
