/* See LICENSE file for copyright and license details. */

.section .text.init.enter
.global _boot
_boot:
#ifndef WITHOUT_BRICKGUARD
	li s0, 0x10012000
	addi s1, s0, 0x0C
	li s2, 0x10000000
	li s3, 0xF001BA11
	lw s4, 0xBC(s2)
	li a0, 0x200bff8
	li a1, 0x4000

	bne s3, s4, 2f

	sw zero, 0xBC(s2)

	li s5, 0x400000
	sw s5, 0x0C(s0)
	sw s5, 0x08(s0)
1:
	amoxor.w zero, s5, (s1)
	jal .Lwait
	j 1b
2:
	li s5, 0x80000
	sw s5, 0x0C(s0)
	sw s5, 0x08(s0)

	amoxor.w zero, s5, (s1)
	jal .Lwait
	amoxor.w zero, s5, (s1)
	sw s3, 0xBC(s2)
	jal .Lwait
	amoxor.w zero, s5, (s1)
	sw s4, 0xBC(s2)
	jal .Lwait

	sw zero, 0x08(s0)
	sw zero, 0x0C(s0)

	j 3f

.Lwait:
	lw t1, 0x04(a0)
	lw t0, 0x00(a0)
	lw t4, 0x04(a0)
	bne t1, t4, .Lwait

	add t2, t0, a1
	sltu t4, t2, t0
	add t3, t1, t4
1:
	lw t1, 0x04(a0)
	lw t0, 0x00(a0)
	lw t4, 0x04(a0)
	bne t1, t4, 1b

	bltu t1, t3, 1b
	bgtu t1, t3, 1f
	bltu t0, t2, 1b
1:
	ret
3:
#endif
#ifndef WITHOUT_BOOTCFG
	/* init qspi0 */
	li t0, 0x10014000
	li t1, 0x3
	li t2, 0x80000
	li t3, 0x30007
	sw t1, 0x00(t0)
	sw t2, 0x40(t0)
	sw t3, 0x64(t0)

	/* init gpio */
	li t0, 0x10012000
	li t1, 0x30000
	sw t1, 0x08(t0)
	sw t1, 0x0C(t0)
	sw t1, 0x38(t0)
	sw zero, 0x3C(t0)
	sw zero, 0x40(t0)

	/* init uart0 */
	li t0, 0x10013000
	li t1, 0x1
	li t2, 0x27F
	sw t1, 0x08(t0)
	sw t1, 0x0C(t0)
	sw t2, 0x18(t0)

	/* init clock */
	li t0, 0x10008000
	li t1, 0x20671
	li t2, 0x30671
	li t3, 0x100004
	sw t1, 0x08(t0)
1:
	lw t1, 0x08(t0)
	bgez t1, 1b
	sw t2, 0x08(t0)
	sw t3, 0x00(t0)
#endif

	/* irq config */
	csrci mstatus, 0x8
	csrw mie, zero

	li t0, 0x0C002000
	sw zero, 0x00(t0)
	sw zero, 0x04(t0)

	li t0, 0x0C000000
	li t1, 0x0C0000D0
1:
	sw zero, 0x04(t0)
	addi t0, t0, 0x4
	bne t0, t1, 1b

	li t0, 0x0C200000
	sw zero, 0x00(t0)

	la t0, _trap
	csrw mtvec, t0

	li t0, 0x808
	csrw mie, t0

	li t0, 0x1888
	csrw mstatus, t0

	tail _start
