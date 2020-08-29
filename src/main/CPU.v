module CPU(
    input   clk,
    input   rst
);
    wire    [31:0]  Instr;
    wire    [31:0]  DataALUOut;
    wire    [31:0]  DataALUOutReg;
    wire    [31:0]  DataALU_A;
    wire    [31:0]  DataALU_B;
    wire    [31:0]  DataNextPC;
    wire    [31:0]  DataPCReg;
    wire    [31:0]  DataIMOutput;
    wire    [31:0]  DataIMRegInput;
    wire    [31:0]  DataIMRegOutput;
    wire    [31:0]  DataDMRead;
    wire    [31:0]  DataDMReadReg;
    wire    [11:0]  DataDMFakeAddr;
    wire    [31:0]  DataRFRead1;
    wire    [31:0]  DataRFRead2;
    wire    [4:0]   DataRFWriteAddr;
    wire    [31:0]  DataRFWriteData;
    wire    [1:0]   SignalEXTOp;
    wire    [31:0]  DataSignExt;
    wire    [31:0]  DataSignExtSL2;
    wire            SignalPCWriteCond;
    wire            SignalPCWrite;
    wire    [1:0]   SignalPCSource;
    wire            SignalPCNext;
    wire            SignalMemRead;
    wire            SignalMemWrite;
    wire    [3:0]   SignalDMBE;
    wire            SignalDMSigned;
    wire    [1:0]   SignalMem2Reg;
    wire            SignalIRWrite;
    wire    [1:0]   SignalRegDst;
    wire            SignalRegWrite;
    wire    [1:0]   SignalALU_A;
    wire    [1:0]   SignalALU_B;
    wire            SignalBranch;
    wire    [5:0]   SignalALUOp;
    wire    [1:0]   SignalALUCtrlOp;
    wire            SignalBranchResult;
    wire            SignalPCWriteResult;
    integer cycleNumber;
    assign SignalBranchResult   =   SignalBranch & SignalPCWriteCond;
    assign SignalPCWriteResult  =   SignalBranchResult | SignalPCWrite;

    SReg PCSReg(
        .clk(clk),
        .RegWrite(SignalPCWriteResult),
        .Data(DataNextPC),
        .rst(rst),
        .Result(DataPCReg)
    );
    // Ctrl
    CU CU(
        .clk(clk),
        .OP(Instr[31:26]),
        .funct(Instr[5:0]),
        .PC(DataPCReg),
        .PCWriteCond(SignalPCWriteCond),
        .PCWrite(SignalPCWrite),
        .PCSource(SignalPCSource),
        .MemWrite(SignalMemWrite),
        .Mem2Reg(SignalMem2Reg),
        .IRWrite(SignalIRWrite),
        .RegDst(SignalRegDst),
        .RegWrite(SignalRegWrite),
        .ALU_A(SignalALU_A),
        .ALU_B(SignalALU_B),
        .ALUCtrlOp(SignalALUCtrlOp)
    );
    assign Instr = DataIMRegOutput;
    IM IM(
        .clk(clk),
        .addr(DataPCReg[11:2]),
        .dout(DataIMOutput)
    );
    SReg IMSreg(
        .clk(clk),
        .RegWrite(SignalIRWrite),
        .Data(DataIMOutput),
        .Result(DataIMRegOutput)
    );
    BECtrl BECtrl(
        .OP(Instr[31:26]),
        .addr(DataALUOutReg),
        .BE(SignalDMBE),
        .fakeAddr(DataDMFakeAddr),
        .MemReadSigned(SignalDMSigned)
    );
    DM DM(
        .clk(clk),
        .addr(DataDMFakeAddr[11:2]),
        .din(DataRFRead2),
        .DMWr(SignalMemWrite),
        .BE(SignalDMBE),
        .MemReadSigned(SignalDMSigned),
        .dout(DataDMRead)
    );
    SReg DMReg(
        .clk(clk),
        .RegWrite(1),
        .Data(DataDMRead),
        .Result(DataDMReadReg)
    );
    Mux ALU_A_Mux(
        .Select(SignalALU_A),
        .Data1(DataPCReg),              //PC 
        .Data2(DataRFRead1),            //regout_1
        .Data3({27'b0, Instr[10:6]}),   //imm
        .Result(DataALU_A)
    );
    EXT ext(
        .clk(clk),
        .Immediate16(Instr[15:0]),
        .EXTOp(SignalEXTOp),
        .Immediate32(DataSignExt)
    );
    Mux ALU_B_Mux(
        .Select(SignalALU_B),
        .Data1(DataRFRead2),                //regout_2
        .Data2(4),                          //imm 4  用于PC <= PC+4
        .Data3(DataSignExt),                //EXT_imm32
        .Data4({DataSignExt[29:0], 2'b00}), //EXT_imm32 * 4
        .Result(DataALU_B)
    );
    //INS : OP RS RT RD 5B'X 6B'X
    Mux RFWriteAddr(
        .Select(SignalRegDst),
        .Data1(Instr[20:16]),//RT
        .Data2(Instr[15:11]),//`
        .Data3(31),
        .Result(DataRFWriteAddr)
    );
    Mux RFWriteData(
        .Select(SignalMem2Reg),
        .Data1(DataALUOutReg),// ALUresult
        .Data2(DataDMReadReg),// DR
        .Data3(DataPCReg),// PC
        .Result(DataRFWriteData)
    );
    RF RF(
        .clk(clk),
        .RegWrite(SignalRegWrite),
        .ReadAddr1(Instr[25:21]),//RS
        .ReadAddr2(Instr[20:16]),//RT
        .WriteAddr(DataRFWriteAddr),
        .WriteData(DataRFWriteData),
        .ReadData1(DataRFRead1),
        .ReadData2(DataRFRead2)
    );
    ALUCtrl ALUCtrl(
        .OP(Instr[31:26]),
        .funct(Instr[5:0]),
        .ALUCtrlOp(SignalALUCtrlOp),
        .EXTOp(SignalEXTOp),
        .ALUOp(SignalALUOp)
    );
    ALU alu(
        .A(DataALU_A),
        .B(DataALU_B),
        .ALUOp(SignalALUOp),
        .result(DataALUOut)
    );
    SReg ALUReg(
        .clk(clk),
        .RegWrite(1),
        .Data(DataALUOut),
        .Result(DataALUOutReg)
    );
    Mux PCSourceMux(
        .Select(SignalPCSource),
        .Data1(DataALUOut), // ALURes  直接结果，通常用于 PC+4
        .Data2(DataALUOutReg), //ALURegRes  区别在于 不同状态下 ALU结果是不确定的 而ALUREGS的则是保持的
        .Data3({DataPCReg[31:28], Instr[25:0], 2'b00}),//INS OP address
        .Result(DataNextPC)
    );
    BranchCtrl BranchCtrl(
        .clk(clk),
        .A(DataRFRead1),
        .B(DataRFRead2),
        .OP(Instr[31:26]),
        .Branch_funct(Instr[20:16]),
        .BranchSucceed(SignalBranch)
    );
    initial begin
        cycleNumber = 0;
    end
    always @(clk) begin
        if (!clk) begin
            cycleNumber  = cycleNumber + 1;
            $display("Instruction:0x%08X", Instr);
            $display("Current Cycle:%d",cycleNumber);
        end
    end

endmodule
