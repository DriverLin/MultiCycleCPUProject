import sys
types = {
    "LB": "t_offset(s)",
    "LBU": "t_offset(s)",
    "LH": "t_offset(s)",
    "LHU": "t_offset(s)",
    "LW": "t_offset(s)",
    "SB": "t_offset(s)",
    "SH": "t_offset(s)",
    "SW": "t_offset(s)",
    "ADDI": "t_s_imm",
    "ADDIU": "t_s_imm",
    "ANDI": "t_s_imm",
    "ORI": "t_s_imm",
    "XORI": "t_s_imm",
    "LUI": "t_imm",
    "SLTI": "t_s_imm",
    "SLTIU": "t_s_imm",
    "BEQ": "s_t_offset",
    "BNE": "s_t_offset",
    "BLEZ": "s_offset",
    "BGTZ": "s_offset",
    "BLTZ": "s_offset",
    "BGEZ": "s_offset",
    "J": "target",
    "JAL": "target",
    "JALR": "s",
    "JR": "s",
    "R": "s"
}

Extr = {
    "000000": "SLL",
    "000010": "SRL",
    "000011": "SRA"
}

func_map = {
    "ADD": "100000",
    "ADDU": "100001",
    "SUB": "100010",
    "SUBU": "100011",
    "SLLV": "000100",
    "SRLV": "000110",
    "SRAV": "000111",
    "AND": "100100",
    "OR": "100101",
    "XOR": "100110",
    "NOR": "100111",
    "SLT": "101010",
    "SLTU": "101011",
    "SLL": "000000",
    "SRL": "000010",
    "SRA": "000011",
    "LUI": "110000",
    "ANDI": "110100",
    "ORI": "110101",
    "XORI": "110110",
    "JR": "001000",
    "JALR": "001001"
}

op_to_opcode = {
    "ADD": "000000",
    "ADDU": "000000",
    "SUB": "000000",
    "SUBU": "000000",
    "SLLV": "000000",
    "SRLV": "000000",
    "SRAV": "000000",
    "AND": "000000",
    "OR": "000000",
    "XOR": "000000",
    "NOR": "000000",
    "SLT": "000000",
    "SLTU": "000000",
    "SLL": "000000",
    "SRL": "000000",
    "SRA": "000000",
    "LUI": "000000",
    "ANDI": "000000",
    "ORI": "000000",
    "XORI": "000000",
    "JR": "000000",

    "LB": "100000",
    "LBU": "100100",
    "LH": "100001",
    "LHU": "100101",
    "LW": "100011",
    "SB": "101000",
    "SH": "101001",
    "SW": "101011",
    "ADDI": "001000",
    "ADDIU": "001001",
    "ANDI": "001100",
    "ORI": "001101",
    "XORI": "001110",
    "LUI": "001111",
    "SLTI": "001010",
    "SLTIU": "001011",
    "BEQ": "000100",
    "BNE": "000101",
    "BLEZ": "000110",
    "BGTZ": "000111",
    "BLTZ": "000001",
    "BGEZ": "000001",
    "J": "000010",
    "JAL": "000011"

}


def int2bin(n, count=24):
    """returns the binary of integer n, using count number of digits"""
    return "".join([str((n >> y) & 1) for y in range(count-1, -1, -1)])


def reg_map(reg):
    index = int(reg[1:])
    return int2bin(index, 5)


if __name__ == "__main__":
    ASMcode = open(sys.argv[1]).read()
    for line in ASMcode.splitlines():
        if line == "":
            continue
        operation = line.split()[0]
        opcode = op_to_opcode[operation]
        if opcode == "000000":  # R类
            func = func_map[operation]  # func
            # 000000 00000 rt rd 5位偏移量 func <= op rd,rt,imm
            if operation in ["SLL", "SRL", "SRA"]:
                rd, rt, shamt = line.split()[1].split(",")
                rd = reg_map(rd)
                rt = reg_map(rt)
                shamt = int2bin(int(shamt), 5)
                bincode = "00000000000{}{}{}{}".format(rt, rd, shamt, func)
                print(bincode)
            elif operation == "JR":  # 000000 rs 00000 00000 00000 001000
                rs = line.split()[1]
                rs = reg_map(rs)
                bincode = "000000{}000000000000000{}".format(rs, func)
                print(bincode)
            else:  # 000000 rs rt rd 00000 func <= op rd,rs,rt
                rd, rs, rt = line.split()[1].split(",")
                rd = reg_map(rd)
                rs = reg_map(rs)
                rt = reg_map(rt)
                bincode = "000000{}{}{}00000{}".format(rs, rt, rd, func)
                print(bincode)
        else:
            type = types[operation]
            # opcode rs rt imm <=  op rt rs imm
            if type in ["t_offset(s)", "t_s_imm", "s_t_offset"]:
                rt, rs, imm = line.split()[1].split(",")
                rt = reg_map(rt)
                rs = reg_map(rs)
                imm = int2bin(int(imm), 16)
                bincode = "{}{}{}{}".format(opcode, rs, rt, imm)
                print(bincode)
            elif type in ["t_imm"]:  # opcode 00000 rt imm
                rt, imm = line.split()[1].split(",")
                rt = reg_map(rt)
                imm = int2bin(int(imm), 16)
                bincode = "{}00000{}{}".format(opcode, rt, imm)
                print(bincode)
            elif type in ["s_offset"]:  # opcode rs 0000 imm <= op rs offset
                rs, imm = line.split()[1].split(",")
                rs = reg_map(rs)
                imm = int2bin(int(imm), 16)
                bincode = "{}{}00000{}".format(opcode, rs, imm)
                if operation == "BGEZ":
                    bincode = "{}{}00001{}".format(opcode, rs, imm)
                print(bincode)
            elif type in ["target"]:  # opcode imm <= op imm26
                imm = line.split()[1]
                imm = int2bin(int(imm), 26)
                bincode = "{}{}".format(opcode, imm)
                print(bincode)
            else:
                print("Error!")
