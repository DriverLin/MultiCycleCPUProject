//////////////////////////////////////////////////////////////////////////////////
// 模块名称: DM
// 模块功能: 数据存储器
//          一个存储单元为4个字节
//          可控制数据类型
//          通过Addr读取写入
//          BE来控制部分写入 与BEctrl协同工作 
//////////////////////////////////////////////////////////////////////////////////
module DM(
    input               clk,
    input   [11:2]      addr,
    input   [3:0]       BE,
    input   [31:0]      din,
    input               DMWr,
    input               MemReadSigned,
    output  reg[31:0]   dout
) ;
    reg[31:0]           ROM[1023:0];
    integer             i;
    initial
    begin
        for (i = 0; i < 1024; i = i + 1)
            ROM[i] = 0;
    end
    always@(negedge clk)
    begin
        if(DMWr) begin
            case (BE)
                4'b1111: //32->32 XXXXXXXX -> XXXXXXXX
                    ROM[addr]           =   din;
                4'b1100: //16 -> H16  XXXX -> XXXX----
                    ROM[addr][31:16]    =   din[15:0];
                4'b0011: //16 -> L16  XXXX -> ----XXXX
                    ROM[addr][15:0]     =   din[15:0];
                4'b0001: // 8 -> LL8    XX -> ------XX
                    ROM[addr][7:0]      =   din[7:0];
                4'b0010: // 8 -> LH8    XX -> ----XX--
                    ROM[addr][15:8]     =   din[7:0];
                4'b0100: // 8 -> HL8    XX -> --XX----
                    ROM[addr][23:16]    =   din[7:0];
                4'b1000: // 8-> HH8    XX -> XX------
                    ROM[addr][31:24]    =   din[7:0];
                default:
                    ROM[addr]           =   2'hffffffff;
            endcase
        end
    end
    always@(*) begin
        dout = ROM[addr];
        if(MemReadSigned) begin //signed
            case (BE)
                4'b1111:
                    dout    =   ROM[addr];
                4'b1100: // H16
                    dout    =   {{16{ROM[addr][31]}}, ROM[addr][31:16]};
                4'b0011: // L16
                    dout    =   {{16{ROM[addr][15]}}, ROM[addr][15:0]};
                4'b0001: // LL8
                    dout    =   {{24{ROM[addr][7]}}, ROM[addr][7:0]};
                4'b0010: // LH8
                    dout    =   {{24{ROM[addr][15]}}, ROM[addr][15:8]};
                4'b0100: // HL8
                    dout    =   {{24{ROM[addr][23]}}, ROM[addr][23:16]};
                4'b1000: // HH8
                    dout    =   {{24{ROM[addr][31]}}, ROM[addr][31:24]};
                default:
                    dout    =   ROM[addr];
            endcase
        end
        else 
            begin//unigned
            case (BE)
                4'b1111:
                    dout    =   ROM[addr];
                4'b1100:
                    dout    =   {16'h0000, ROM[addr][31:16]};
                4'b0011:
                    dout    =   {16'h0000, ROM[addr][15:0]};
                4'b0001:
                    dout    =   {24'h0000, ROM[addr][7:0]};
                4'b0010:
                    dout    =   {24'h0000, ROM[addr][15:8]};
                4'b0100:
                    dout    =   {24'h0000, ROM[addr][23:16]};
                4'b1000:
                    dout    =   {24'h0000, ROM[addr][31:24]};
                default:
                    dout    =   ROM[addr];
            endcase
        end
    end
endmodule
