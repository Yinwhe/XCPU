addi x0, x0, 0
lw x2, 4(x0)		# x2 = 0x08
lw x4, 8(x0)		# x4 = 0x10
add x1, x2, x4		# x1 = 0x18
addi x1, x1, -1		# x1 = 0x17
lw x5, 12(x0)		# x5 = 0x14
lw x6, 16(x0)		# x6 = 0xFFFF0000
lw x7, 20(x0)		# x7 = 0x0FFF0000
sub x1,x4,x2		# x1 = 0x08
and x1,x4,x2		# x1 = 0x00
or  x1,x4,x2		# x1 = 0x18
xor x1,x4,x2		# x1 = 0x18
sll x1,x4,x2		# x1 = 0x1000
slt x1,x4,x2		# x1 = 0x0
slt x1,x2,x4		# x1 = 0x1
srl x1, x6, x2		# x1 = 0x00FFFF00
sra x1, x6, x2		# x1 = 0xFFFFFF00
sra x1, x7, x2		# x1 = 0x000FFF00
sltu x1, x6, x7	    # x1 = 0x0
sltu x1, x7, x6	    # x1 = 0x1
add x0,x0,x0
addi x1,x10,-3		# x1 = -3
andi x1,x4,15		# x1 = 0x00
ori  x1,x4,15		# x1 = 0x1F
xori x1,x4,15		# x1 = 0x1F
slti x1,x4,15		# x1 = 0x0
slli x1,x4,1		# x1 = 0x20
srli x1,x4,2		# x1 = 0x04
srai x1, x6, 12	    # x1 = 0xFFFFFFF0
sltiu x1, x6, -1	# x1 = 0x1
sltiu x1, x7, -1	# x1 = 0x1
beq  x4,x5,label0	# not taken
beq  x4,x4,label0	# taken
addi x0,x0,0
addi x0,x0,0label0:
bne  x4,x4,label1	# not taken
bne  x4,x5,label1	# taken
addi x0,x0,0
addi x0,x0,0label1:
blt  x5,x4,label2
blt  x4,x5,label2
addi x0,x0,0
addi x0,x0,0label2:
bltu x6,x7,label3
bltu x7,x6,label3
addi x0,x0,0
addi x0,x0,0label3:
bge x4,x5,label4
bge x5,x4,label4
addi x0,x0,0
addi x0,x0,0label4:
bgeu x7,x6,label5
bgeu x6,x7,label5
addi x0,x0,0
addi x0,x0,0label5:
bge  x4,x4,label6
addi x0,x0,0
addi x0,x0,0label6:
lui  x1,4
jal  x1,12
addi x0,x0,0
addi x0,x0,0
lw   x8, 24(x0)	# x8 = 0xFF000F0F
sw   x8, 28(x0)
lw   x1, 28(x0)	# x1 = 0xFF000F0F
sh   x8, 32(x0)
lw   x1, 32(x0)	# x1 = 0x00000F0F
sb   x8, 36(x0)
lw   x1, 36(x0)
lh   x1, 26(x0)
lhu  x1, 26(x0)
lb   x1, 27(x0)
lbu  x1, 27(x0)
auipc x1, 0xffff0
jalr x1,0(x0)
