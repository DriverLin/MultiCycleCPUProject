
##### Memory
LB      t_offset(s)
LBU     t_offset(s)
LH      t_offset(s)
LHU     t_offset(s)
LW      t_offset(s)
SB      t_offset(s)
SH      t_offset(s)
SW      t_offset(s)

##### Imm calculate
ADDI    t_s_imm
ADDIU   t_s_imm
ANDI    t_s_imm
ORI     t_s_imm
XORI    t_s_imm
LUI     lui t_imm
SLTI    t_s_imm
SLTIU   t_s_imm

#### Branch
BEQ     s_t_offset
BNE     s_t_offset
BLEZ    s_offset
BGTZ    s_offset
BLTZ    s_offset
BGEZ    s_offset

#### J
J       target
JAL     target
JALR    s
JR      s
