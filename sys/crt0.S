/* See LICENSE file for copyright and license details. */

.section .init
.global _start
_start:
.option push
.option norelax
	la sp, __stack
	la gp, __global_pointer$
.option pop
	la a0, __data_start
	la a1, __data_source
	la a2, __data_size
	call memcpy

	la a0, __bss_start
	li a1, 0
	la a2, __bss_size
	call memset

	la tp, __tls_base

	la a0, __libc_fini_array
	call atexit
	call __libc_init_array

	li a0, 0
	li a1, 0
	call main
	tail exit
