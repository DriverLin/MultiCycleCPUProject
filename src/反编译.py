import json
import sys
reMapper = {
    "R": "000000",
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

mapper = {
    reMapper[key]: key for key in reMapper
}

Memory = [""]

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
    "100000": "ADD",
    "100001": "ADDU",
    "100010": "SUB",
    "100011": "SUBU",
    "000100": "SLLV",
    "000110": "SRLV",
    "000111": "SRAV",
    "100100": "AND",
    "100101": "OR",
    "100110": "XOR",
    "100111": "NOR",
    "101010": "SLT",
    "101011": "SLTU",
    "000000": "SLL",
    "000010": "SRL",
    "000011": "SRA",
    "110000": "LUI",
    "110100": "ANDI",
    "110101": "ORI",
    "110110": "XORI",
    "001000": "JR",
    "001001": "JALR"
}


if __name__ == "__main__":
    instr = open(sys.argv[1]).read()
    for line in instr.splitlines():
        if line == "":
            continue
        # print(line)
        opcode = mapper[line[0:6]]  # 前6位 操作码
        type = types[opcode]  # 获取对应的后面的数据排列的类型
        if type == "t_s_imm":  # 6 5 5 16
            t = "R"+str(int(line[11:16], 2))
            s = "R"+str(int(line[6:11], 2))
            imm = int(line[16:32], 2)
            print("{} {},{},{}".format(opcode, t, s, imm))
        if type == "t_offset(s)":  # 6 5 5 16
            t = "R"+str(int(line[11:16], 2))
            s = "R"+str(int(line[6:11], 2))
            imm = int(line[16:32], 2)
            print("{} {},{},{}".format(opcode, t, s, imm))
        if type == "s_t_offset":  # 6 5 5 16
            t = "R"+str(int(line[11:16], 2))
            s = "R"+str(int(line[6:11], 2))
            imm = int(line[16:32], 2)
            print("{} {},{},{}".format(opcode, t, s, imm))
        if type == "target":  # 6 0*10 16
            imm = int(line[16:32], 2)
            print("{} {}".format(opcode, imm))
        if type == "s_offset":  # 6 5 0*5 16
            if opcode in ["BGEZ", "BLTZ"]:
                if line[11:16] == "00000":
                    opcode = "BLTZ"
                else:
                    opcode = "BGEZ"
            s = "R"+str(int(line[6:11], 2))
            imm = int(line[16:32], 2)
            print("{} {},{}".format(opcode, s, imm))
        if type == "t_imm":  # 6 0*5 5 16
            t = "R"+str(int(line[11:16], 2))
            imm = int(line[16:32], 2)
            print("{} {},{}".format(opcode, t, imm))
        if type == "s":
            funct = line[26:32]
            func_code = func_map[funct]
            if funct in Extr:  # 000000 0*5 5 6 6
                imm = line[20:26]
                t = "R"+str(int(line[11:16], 2))
                print("{} {},{}".format(func_code, t, imm))
            elif func_code == "JR":  # 000000 6 0*n 6
                s = "R"+str(int(line[6:11], 2))
                print("{} {}".format(func_code, s))
            else:  # 000000 5 5 5 0*n 6
                s = "R"+str(int(line[6:11], 2))
                t = "R"+str(int(line[11:16], 2))
                d = "R"+str(int(line[16:21], 2))
                print("{} {},{},{}".format(func_code, d, s, t))
