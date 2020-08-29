LB、LBU、LH、LHU、LW、SB、SH、SW、ADD、ADDU、SUB、SUBU、SLL、SRL、SRA、SLLV、SRLV、SRAV、AND、OR、XOR、NOR、SLT、SLTU、ADDI、ADDIU、ANDI、ORI、XORI、LUI、SLTI、SLTIU、BEQ、BNE、BLEZ、BGTZ、BLTZ、BGEZ、J、JAL、JALR、JR
42条


R类
000000 5 5 5 shmat func
R-typeFlag rs rt rd shmat func
rd = rs func rt
ADD、ADDU、SUB、SUBU、SLL、SRL、SRA、SLLV、SRLV、SRAV、AND、OR、XOR、NOR、SLT、SLTU

I类
| Ins       | Syntax            | Operation |
| :---:     | :----:            | :-------: |
| LB        | lb rt, offset(rs) | rt = MEM[rs + offset];|
| LBU       | lbu rt, offset(rs)| rt = MEM[rs + u(offset)];|
| LH        | lh rt, offset(rs) | rt = MEM[rs + offset];|
| LHU       | lhu rt, offset(rs)| rt = MEM[rs + u(offset)];|
| LW        | lw rt, offset(rs) | rt = MEM[rs + offset];|
| SB        | sb rt, offset(rs) | MEM[rs + offset] = (0xff & rt);|
| SH        | sh rt, offset(rs) | MEM[rs + offset] = (0xffff & rt);|
| SW        | sw rt, offset(rs) | MEM[rs + offset] = rt;|

imm

| Ins       | Syntax            | Operation |
| :---:     | :----:            | :-------: |
| ADDI      | addi rt, rs, imm  | rt = rs + imm;|
| ADDIU     | addiu rt, rs, imm | rt = rs + imm;|
| ANDI      | andi rt, rs, imm  | rt = rs & imm;|
| ORI       | ori rt, rs, imm   | rt = rs | imm;|
| XORI      | xori rt, rs, imm  | rt = rs ^ imm;|
| LUI       | lui rt, imm       | rt = {imm[ 15:0 ],0'B0X16};|
| SLTI      | slti rt, rs, imm  | rt = rs < imm ?  1 : 0;|
| SLTIU     | sltiu rt, rs, imm | rt = rs < u(imm) ?  1 : 0;|

条件分支

| Ins       | Syntax            | Operation |
| :---:     | :----:            | :-------: |
| BEQ       | beq rs, rt, offset| if rs == rt  branch; |
| BNE       | bne rs, rt, offset| if rs != rt  branch; |
| BLEZ      | blez rs, offset   | if rs <=  0  branch; |
| BGTZ      | bgtz rs, offset   | if rs >   0  branch; |
| BLTZ      | bltz rs, offset   | if rs <   0  branch; |
| BGEZ      | bgez rs, offset   | if rs >=  0  branch; |

J

| Instr     | Syntax        | Operation |
| :---:     | :----:        | :-------: |
| J         | j target      | PC = target << 2;|
| JAL       | jal target    | PC = target << 2 ; $ra = PC + 4;|
| JALR      | jalr rs       | PC = Reg[ target ] << 2 ; $ra = PC + 4;|
| JR        | jr rs         | PC = Reg[ target ] << 2;|

