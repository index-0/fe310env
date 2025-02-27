/* See LICENSE file for copyright and license details. */

.text
.global _setbyte
.type   _setbyte, @function
_setbyte:
	li t0, 0x10013000
1:
	amoor.w t1, a0, 0x0(t0)
	bltz t1, 1b
	ret

.global _getbyte
.type   _getbyte, @function
_getbyte:
	li t0, 0x10013000
1:
	lw a0, 0x4(t0)
	bltz a0, 1b
	ret
