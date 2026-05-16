# Assembly to test ID/EX execution. Code increments through a list in memory and computes the total sum.

.text
.global _start

_start:
	li 	sp, 0x43800	# li = load immediate, pretty much the same as la except assembler is not providing the value (you are)
	call	main
	jal	x0, 0		# Infinite loop: Jumps to PC + 0	

main:
	la		t0, N           # t0 = address of N (la = movia equivalent)
	lw		t1, 0(t0)       # t1 holds count (N) (lw = ldw equivalent)
	la		t2, LIST        # t2 holds addr of first element
	mv		t3, x0          # t3 holds sum = 0 (mv = mov equivalanet)
LOOP:
	lw		t4, 0(t2)       # t5 holds actual value 
	add	t3, t3, t4      # add value to sum
	addi 	t2, t2, 4       # increment to next element
	addi 	t1, t1, -1      # decrement count
	bgt 	t1, x0, LOOP    # if count > 0, loop

	la		t0, SUM         # t1 = address of SUM
	sw 	t3, 0(t0)       # store sum
	ret
	
.data
SUM:		.space 4
N:  		.word  5
LIST: 	.word  12, 0xFFFFFFFE, 7, -1, 2

# .end not required for RISC-V

# Note
# li is a pseudoinstruction. It expects a 32 bit immediate. So to keep the rule of 32 bit instructions, it splits the 32 bit imm into the upper 20 and lower 12 bits. Then it does lui on the upper 20, and adds the lower 12 bits. For ex, 0x00043800 -> 0x00043 & 0x800.
# Numbers get turned into 0x00044 and 0xFFFFF800 by assembler magic
# lui sp, 0x44
# addi sp, sp, 0xFFFFF800
# Explains why modelsim waveform may show unexpected imm_o/opcode