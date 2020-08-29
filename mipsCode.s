main:
    li $a2, 20
    li $a1, 1    
    li $a3, 1
    li $a0, 1
fib:
    add   $s2, $a1, $a3
    addi  $a2, $a2, -1
    add   $a1, $0,  $s2
    beq   $a2, $a0, exit
    add   $s2, $a1, $a3
    add   $a3, $0   $s2
    addi  $a2, $a2, -1
    bne   $a2, $a0, fib
exit:   add   $s2, $0,  $s2