
`define OP_LB   6'b100000
`define OP_LBU  6'b100100
`define OP_LH   6'b100001
`define OP_LHU  6'b100101
`define OP_LW   6'b100011
`define OP_SB   6'b101000
`define OP_SH   6'b101001
`define OP_SW   6'b101011
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: BECtrl
// 模块功能: 位扩展功能
//          根据当前指令自行判断数据类型
//          通过设置对应的BEflag控制对DM的读写
//          以及读写的数据类型 US,S
//////////////////////////////////////////////////////////////////////////////////


module BECtrl(
    input   [5:0]       OP,
    input   [31:0]      addr,
    output  reg[3:0]    BE,
    output  reg[11:0]   fakeAddr,
    output  reg         MemReadSigned
);
    always@(*) begin
        fakeAddr = addr[11:0];
        case(OP)
            `OP_LBU, `OP_LHU:
                MemReadSigned   =   0;
            default:
                MemReadSigned   =   1;
        endcase
        case(OP)
            `OP_LB, `OP_LBU, `OP_SB:
                case(addr[1:0])
                    2'b00:
                        BE = 4'b0001;
                    2'b01:
                        BE = 4'b0010;
                    2'b10:
                        BE = 4'b0100;
                    2'b11:
                        BE = 4'b1000;
                    default:
                        BE = 4'b0001;
                endcase
            `OP_LH, `OP_LHU, `OP_SH:
                case(addr[1:0])
                    2'b00:
                        BE = 4'b0011;
                    2'b10:
                        BE = 4'b1100;
                    default:
                        BE = 4'b0011;
                endcase
            `OP_LW, `OP_SW:
                BE = 4'b1111;
            default:
                BE = 4'b1111;
        endcase
    end
endmodule