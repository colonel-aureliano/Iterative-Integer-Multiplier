csrr x1, mngr2proc < 1
csrr x2, mngr2proc < 2
addi x1, x2, 5
addi x3, x1, 1
csrw proc2mngr, x3 > 8