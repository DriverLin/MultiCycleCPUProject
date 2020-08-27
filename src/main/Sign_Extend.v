`define EXTOP_UNSIGNED  2'b00
`define EXTOP_SIGNED    2'b01
`define EXTOP_INST      2'b10


//////////////////////////////////////////////////////////////////////////////////
// 模块名称: EXT
// 模块功能: 扩展模块
//          用于扩展16位数到32位
//          EXTOP来标识UNSIGNED,SIGNED
//////////////////////////////////////////////////////////////////////////////////
module EXT(
    input               clk,
    input   [15:0]      Immediate16,
    input   [1:0]       EXTOp,
    output  reg[31:0]   Immediate32
);
    initial begin
        Immediate32 = 32'b00;
    end
    always @(negedge clk) begin
        case(EXTOp)
            `EXTOP_UNSIGNED: Immediate32 = {{16'b0}, Immediate16[15:0]};
            `EXTOP_SIGNED: Immediate32 = {{16{Immediate16[15]}}, Immediate16[15:0]};
            `EXTOP_INST: Immediate32 = 32'b0;
            default: Immediate32 = {{16'b0}, Immediate16[15:0]};
        endcase
    end
endmodule
