/* See LICENSE file for copyright and license details. */

#include <fe310/bits.h>
#include <fe310/clint.h>
#include <fe310/plic.h>

/* Masks */
#define MCAUSE_MSK_CAUSE GENMASK(9, 0)

/* Interrupt codes */
#define IRQ_M_SOFT 3
#define IRQ_M_TIMER 7
#define IRQ_M_EXT 11

/* Exception codes */
#define CAUSE_USER_ECALL 8
#define CAUSE_MACHINE_ECALL 11

/* Syscalls */
#define SYSCALL_READ 63
#define SYSCALL_WRITE 64
#define SYSCALL_BRK 214

/* Values */
#define RTCFQ 32768

typedef struct {
	u32 s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11;
	u32 ra, t0, t1, t2, t3, t4, t5, t6;
	u32 a0, a1, a2, a3, a4, a5, a6, a7;
	u32 pc;
	u32 pad[3];
} TrapFrame;

extern ssize sys_read(s32 fd, void *buf, usize count);
extern ssize sys_write(s32 fd, const void *buf, usize count);
extern s32 sys_brk(u32 brk);

void isr_timer(void);
void isr_plic(void);
void isr_clic(void);
void panic(void);

__attribute__((aligned(16))) u8 trap_stack[512];

static void __attribute((used))
trap_handler(TrapFrame *tf)
{
	u32 cause, mcause, mepc;

	__asm__ volatile (
		"csrr %0, mcause"
		: "=&r"(mcause)
		:
		: "memory"
	);

	cause = mcause & MCAUSE_MSK_CAUSE;

	if ((s32)mcause < 0) {
		switch(cause) {
		case IRQ_M_TIMER:
			isr_timer();
			break;
		case IRQ_M_EXT:
			isr_plic();
			break;
		case IRQ_M_SOFT:
			isr_clic();
			break;
		default:
			panic();
		}

		return;
	}

	switch(cause) {
	case CAUSE_USER_ECALL:
	case CAUSE_MACHINE_ECALL:
		switch(tf->a7) {
		case SYSCALL_READ:
			tf->a0 = sys_read(
				(s32)tf->a0,
				(void *)tf->a1,
				(usize)tf->a2
			);
			break;
		case SYSCALL_WRITE:
			tf->a0 = sys_write(
				(s32)tf->a0,
				(const void*)tf->a1,
				(usize)tf->a2
			);
			break;
		case SYSCALL_BRK:
			tf->a0 = sys_brk((unsigned long)tf->a0);
			break;
		default:
			tf->a0 = 0;
			break;
		}

		__asm__ volatile (
			"csrr %0, mepc\n\t"
			"addi %0, %0, 4\n\t"
			"csrw mepc, %0"
			: "=&r"(mepc)
			:
			: "memory"
		);

		break;
	default:
		panic();
	}
}

void __attribute__((interrupt, aligned(64)))
trap_entry(void)
{
	__asm__ volatile (
		"csrrw sp, mscratch, sp\n\t"

		"addi sp, sp, -0x80\n\t"
		"sw s0, 0x00(sp)\n\t"
		"sw s1, 0x04(sp)\n\t"
		"sw s2, 0x08(sp)\n\t"
		"sw s3, 0x0C(sp)\n\t"
		"sw s4, 0x10(sp)\n\t"
		"sw s5, 0x14(sp)\n\t"
		"sw s6, 0x18(sp)\n\t"
		"sw s7, 0x1C(sp)\n\t"
		"sw s8, 0x20(sp)\n\t"
		"sw s9, 0x24(sp)\n\t"
		"sw s10, 0x28(sp)\n"
		"sw s11, 0x2C(sp)\n"
		"sw ra, 0x30(sp)\n\t"
		"sw t0, 0x34(sp)\n\t"
		"sw t1, 0x38(sp)\n\t"
		"sw t2, 0x3C(sp)\n\t"
		"sw t3, 0x40(sp)\n\t"
		"sw t4, 0x44(sp)\n\t"
		"sw t5, 0x48(sp)\n\t"
		"sw t6, 0x4C(sp)\n\t"
		"sw a0, 0x50(sp)\n\t"
		"sw a1, 0x54(sp)\n\t"
		"sw a2, 0x58(sp)\n\t"
		"sw a3, 0x5C(sp)\n\t"
		"sw a4, 0x60(sp)\n\t"
		"sw a5, 0x64(sp)\n\t"
		"sw a6, 0x68(sp)\n\t"
		"sw a7, 0x6C(sp)\n\t"

		"mv a0, sp\n\t"
		"call trap_handler\n\t"

		"lw s0, 0x00(sp)\n\t"
		"lw s1, 0x04(sp)\n\t"
		"lw s2, 0x08(sp)\n\t"
		"lw s3, 0x0C(sp)\n\t"
		"lw s4, 0x10(sp)\n\t"
		"lw s5, 0x14(sp)\n\t"
		"lw s6, 0x18(sp)\n\t"
		"lw s7, 0x1C(sp)\n\t"
		"lw s8, 0x20(sp)\n\t"
		"lw s9, 0x24(sp)\n\t"
		"lw s10, 0x28(sp)\n\t"
		"lw s11, 0x2C(sp)\n\t"
		"lw ra, 0x30(sp)\n\t"
		"lw t0, 0x34(sp)\n\t"
		"lw t1, 0x38(sp)\n\t"
		"lw t2, 0x3C(sp)\n\t"
		"lw t3, 0x40(sp)\n\t"
		"lw t4, 0x44(sp)\n\t"
		"lw t5, 0x48(sp)\n\t"
		"lw t6, 0x4C(sp)\n\t"
		"lw a0, 0x50(sp)\n\t"
		"lw a1, 0x54(sp)\n\t"
		"lw a2, 0x58(sp)\n\t"
		"lw a3, 0x5C(sp)\n\t"
		"lw a4, 0x60(sp)\n\t"
		"lw a5, 0x64(sp)\n\t"
		"lw a6, 0x68(sp)\n\t"
		"lw a7, 0x6C(sp)\n\t"
		"addi sp, sp, 0x80\n\t"

		"csrrw sp, mscratch, sp"
		:
		:
		: "memory"
	);
}

void __attribute__((weak))
isr_timer(void)
{
	u64 time = clint_get_mtime();
	clint_set_mtimecmp(time + RTCFQ);
}

void __attribute__((weak))
isr_plic(void)
{
	plic_dispatch();
}

void __attribute__((weak))
isr_clic(void)
{
	clint_msip(false);
}

void __attribute__((noreturn))
panic(void)
{
	for (;;) {
		__asm__ volatile (
			"csrr t0, mcause\n"
			"csrr t1, mepc\n"
			"csrr t2, mtval\n"
			:::
		);
	}
}
