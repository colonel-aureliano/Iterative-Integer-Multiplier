csrr x1, mngr2proc < 8192
csrr x3, mngr2proc < 4
nop
nop
nop
nop
nop
nop
nop
nop
sw x3, 0(x1)
nop
nop
nop
nop
nop
nop
nop
nop
lw x2, 0(x1)
nop
nop
nop
nop
nop
nop
nop
nop
csrw proc2mngr, x2 > 4