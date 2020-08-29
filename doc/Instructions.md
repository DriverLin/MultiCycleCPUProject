MIPS-C2
LB、LBU、LH、LHU、LW、SB、SH、SW、ADD、ADDU、SUB、SUBU、SLL、SRL、SRA、SLLV、SRLV、SRAV、AND、OR、XOR、NOR、SLT、SLTU、ADDI、ADDIU、ANDI、ORI、XORI、LUI、SLTI、SLTIU、BEQ、BNE、BLEZ、BGTZ、BLTZ、BGEZ、J、JAL、JALR、JR
42条


R类
000000 5 5 5 shmat func
R-typeFlag rs rt rd shmat func
rd = rs ALUOp rt
ADD、ADDU、SUB、SUBU、SLL、SRL、SRA、SLLV、SRLV、SRAV、AND、OR、XOR、NOR、SLT、SLTU

I类
| Ins       | Syntax            | Operation |
| :---:     | :----:            | :-------: |
| LB        | lb rt, offset(rs) | rt = MEM[rs + offset]; advance_pc (4);|
| LBU       | lbu rt, offset(rs)| rt = MEM[rs + (unsigned)offset]; advance_pc (4);|
| LH        | lh rt, offset(rs) | rt = MEM[rs + offset]; advance_pc (4);|
| LHU       | lhu rt, offset(rs)| rt = MEM[rs + (unsigned)offset]; advance_pc (4);|
| LW        | lw rt, offset(rs) | rt = MEM[rs + offset]; advance_pc (4);|
| SB        | sb rt, offset(rs) | MEM[rs + offset] = (0xff & rt); advance_pc (4);|
| SH        | sh rt, offset(rs) | MEM[rs + offset] = (0xffff & rt); advance_pc (4);|
| SW        | sw rt, offset(rs) | MEM[rs + offset] = rt; advance_pc (4);|

##### Imm calculate

| Ins       | Syntax            | Operation |
| :---:     | :----:            | :-------: |
| ADDI      | addi rt, rs, imm  | rt = rs + imm; advance_pc (4);|
| ADDIU     | addiu rt, rs, imm | rt = rs + imm; advance_pc (4);|
| ANDI      | andi rt, rs, imm  | rt = rs & imm; advance_pc (4);|
| ORI       | ori rt, rs, imm   | rt = rs | imm; advance_pc (4);|
| XORI      | xori rt, rs, imm  | rt = rs ^ imm; advance_pc (4);|
| LUI       | lui rt, imm       | rt = (imm << 16); advance_pc (4);|
| SLTI      | slti rt, rs, imm  | if rs < imm rt = 1; advance_pc (4); else rt = 0; advance_pc (4);|
| SLTIU     | sltiu rt, rs, imm | if rs < imm rt = 1; advance_pc (4); else rt = 0; advance_pc (4);|

#### Branch

| Ins       | Syntax            | Operation |
| :---:     | :----:            | :-------: |
| BEQ       | beq rs, rt, offset| if rs == rt advance_pc (offset << 2)); else advance_pc (4);|
| BNE       | bne rs, rt, offset| if rs != rt advance_pc (offset << 2)); else advance_pc (4);|
| BLEZ      | blez rs, offset   | if rs <= 0 advance_pc (offset << 2)); else advance_pc (4);|
| BGTZ      | bgtz rs, offset   | if rs > 0 advance_pc (offset << 2)); else advance_pc (4);|
| BLTZ      | bltz rs, offset   | if rs < 0 advance_pc (offset << 2)); else advance_pc (4);|
| BGEZ      | bgez rs, offset   | if rs >= 0 advance_pc (offset << 2)); else advance_pc (4);|

#### J

| Instr     | Syntax        | Operation |
| :---:     | :----:        | :-------: |
| J         | j target      | PC = nPC; nPC = (PC & 0xf0000000) OR (target << 2);|
| JAL       | jal target    | $31 = PC + 8 (or nPC + 4); PC = nPC; nPC = (PC & 0xf0000000) OR (target << 2);|
| JALR      | jalr rs       | $31 = PC + 8 (or nPC + 4); PC = nPC; nPC = rs;|
| JR        | jr rs         | PC = nPC; nPC = rs;|

