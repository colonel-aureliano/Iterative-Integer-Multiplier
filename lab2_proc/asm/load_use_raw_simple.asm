csrr x1, mngr2proc < 17
csrr x2, mngr2proc < 8192
lw x1, 0(x2)
addi x3, x1, 1
csrw proc2mngr, x3 > 1