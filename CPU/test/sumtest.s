# Assembly to test CPU functionality. Code increments through a list in memory and computes the total sum.

.text
.global _start

_start:
	li 	sp, 0x30000		# li = load immediate. 0x30000 = RAM end (64kb (ROM) + 128kb (RAM))
	call	main
	jal	x0, 0				# Infinite loop: Jumps to PC + 0	

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
LIST: 	.word  1, 2, 3, 4, 5

# .end not required for RISC-V