/* See LICENSE file for copyright and license details. */

.section .text.init.enter
.global _boot
_boot:
	/* init qspi0 */
	li t0, 0x10014000
	li t1, 0x3
	li t2, 0x80000
	li t3, 0x00030007
	sw t1, 0x00(t0)
	sw t2, 0x40(t0)
	sw t3, 0x64(t0)

	/* init gpio0 */
	li t0, 0x10012000
	li t1, 0x30000
	sw t1, 0x08(t0)
	sw t1, 0x0C(t0)
	sw t1, 0x38(t0)
	sw zero, 0x3C(t0)
	sw zero, 0x40(t0)

	/* init uart0 */
	li t0, 0x10013000
	li t1, 0x10001
	li t2, 0x1
	li t3, 0x27F
	sw t1, 0x08(t0)
	sw t2, 0x0C(t0)
	sw t3, 0x18(t0)

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
