addi x1, x0, 10
addi x2, x0, 20
add  x3, x1, x2
sub  x4, x3, x1
sw   x3, 0(x0)
lw   x5, 0(x0)
beq  x4, x2, 8
addi x6, x0, 99
addi x7, x0, 1
