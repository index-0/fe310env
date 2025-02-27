/* See LICENSE file for copyright and license details. */

.section .init
.align 2
.global _trap
.type   _trap, @function
_trap:
	addi sp, sp, -0x40
	sw ra, 0x00(sp)
	sw t0, 0x04(sp)
	sw t1, 0x08(sp)
	sw t2, 0x0C(sp)
	sw t3, 0x10(sp)
	sw t4, 0x14(sp)
	sw t5, 0x18(sp)
	sw t6, 0x1C(sp)
	sw a0, 0x20(sp)
	sw a1, 0x24(sp)
	sw a2, 0x28(sp)
	sw a3, 0x2C(sp)
	sw a4, 0x30(sp)
	sw a5, 0x34(sp)
	sw a6, 0x38(sp)
	sw a7, 0x3C(sp)

	li t0, 0x3FF
	csrr t1, mcause
	and t0, t0, t1

	bgez t1, 1f

	li t1, 0x03
	beq t0, t1, _msi

	li t1, 0x07
	beq t0, t1, _mti

	li t1, 0x0B
	beq t0, t1, _mei

	j _panic

1:
	li t1, 0x08
	beq t0, t1, _ecall

	li t1, 0x0B
	beq t0, t1, _ecall

	j _panic

_end:
	lw ra, 0x00(sp)
	lw t0, 0x04(sp)
	lw t1, 0x08(sp)
	lw t2, 0x0C(sp)
	lw t3, 0x10(sp)
	lw t4, 0x14(sp)
	lw t5, 0x18(sp)
	lw t6, 0x1C(sp)
	lw a0, 0x20(sp)
	lw a1, 0x24(sp)
	lw a2, 0x28(sp)
	lw a3, 0x2C(sp)
	lw a4, 0x30(sp)
	lw a5, 0x34(sp)
	lw a6, 0x38(sp)
	lw a7, 0x3C(sp)
	addi sp, sp, 0x40
	mret


_mei:
	li t0, 0x0C200004
	lw t1, 0x00(t0)
	sw t1, 0x00(t0)
	j _end


_msi:
	li t0, 0x2000000
	sw zero, 0x00(t0)
	j _end


_mti:
	li t0, 0x02004000
	li t1, 0x0200BFF8
	li t2, TIMER_TICK
1:
	lw t3, 0x04(t1)
	lw t4, 0x00(t1)
	lw t5, 0x04(t1)
	bne t3, t5, 1b
	add t1, t2, t4
	sltu t5, t1, t4
	add t3, t3, t5
	sw t1, 0x00(t0)
	sw t3, 0x04(t0)
	j _end


_ecall:
	la ra, 2f
	li t0, 0x3F
	bne t0, a7, 1f
	j sys_read
1:
	li t0, 0x40
	bne t0, a7, 1f
	j sys_write
1:
	li t0, 0xD6
	bne t0, a7, 1f
	j sys_brk
1:
	la t0, errno
	li t1, 0x58
	li a0, -1
	sw t1, 0x00(t0)
2:
	sw a0, 0x20(sp)

	csrr t0, mepc
	addi t0, t0, 0x04
	csrw mepc, t0

	j _end


_panic:
	csrr t0, mcause
	csrr t1, mepc
	csrr t2, mtval
	j _panic
