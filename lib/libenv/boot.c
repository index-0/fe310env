/* See LICENSE file for copyright and license details. */

#include <fe310/aon.h>
#include <fe310/gpio.h>
#include <fe310/plic.h>
#include <fe310/prci.h>
#include <fe310/riscv.h>
#include <fe310/spi.h>
#include <fe310/uart.h>

#include "hifive1.h"

#define RTCFQ 32768
#define MAGIC 0xF001BA11

#define MIE_MSIE BITMASK(3)
#define MIE_MTIE BITMASK(7)
#define MIE_MEIE BITMASK(11)
#define MSTATUS_MIE BITMASK(3)

#ifndef UART_BAUDRATE
#define UART_BAUDRATE 115200
#endif

#ifndef FLASH_BAUDRATE
#define FLASH_BAUDRATE 40000000
#endif

#define TRAP_STACK_SIZE 512
__attribute__((used, aligned(16)))
static u8 trap_stack[TRAP_STACK_SIZE];

extern void trap_entry(void);
extern void _start(void);

static inline void
guard(void)
{
	u32 save;

	if (aon->backup[15] == MAGIC) {
		aon->backup[15] = 0;

		gpio->output_en = LED_R;
		while (1) {
			delay_ms(500);
			gpio_tgl(LED_R);
		};
	}

	save = aon->backup[15];

	gpio->output_en = LED_G;
	delay_ms(500);
	gpio_set(LED_G);
	aon->backup[15] = MAGIC;
	delay_ms(500);
	aon->backup[15] = save;
	gpio_clr(LED_G);
	delay_ms(500);
	gpio->output_en = 0;
}

static inline void
clock(void)
{
	prci_pll(1, 31, 3, PRCI_PLL_SEL_PLL, PRCI_PLL_REFSEL_HFXOSC, true);
	while(prci_is_pll_lock());
	prci_set_hfrosc_en(false);
}

static inline void
flash(u32 hfclk, u32 baud)
{
	spi_baudrate(spi0, hfclk, baud);
	spi_ffmt(spi0, true, 3, 4, SPI_PROTO_S, SPI_PROTO_D, SPI_PROTO_D, 0xBB, 0x00);
}

static inline void
tty(u32 hfclk, u32 baud)
{
	uart_baudrate(uart0, hfclk, baud);
	uart_txctrl(uart0, true, UART_STOP_BITS_ONE, WM_0);
	uart_rxctrl(uart0, true, WM_0);
	uart_iof(uart0, true, UART_IOF_TXRX);
}

static inline void
plic(void)
{
	PlicIrq irq;
	*(volatile u32 *)(PLIC_BASE_IE) = 0;
	*(volatile u32 *)(PLIC_BASE_IE + 4) = 0;
	plic_threshold(PLIC_PRIORITY_0);
	for (irq = PLIC_IRQ_NONE; irq <= PLIC_IRQ_I2C; irq++)
		plic_priority(irq, PLIC_PRIORITY_0);
}

static inline void
riscv(void)
{
	__asm__ volatile (
		"csrw mscratch, %0"
		:
		: "r"((u32)trap_stack + TRAP_STACK_SIZE)
		: "memory"
	);

	__asm__ volatile (
		"csrci mstatus, %0"
		:
		: "i"(MSTATUS_MIE)
		: "memory"
	);

	__asm__ volatile (
		"csrw mie, zero"
		:
		:
		: "memory"
	);

	__asm__ volatile (
		"csrw mtvec, %0"
		:
		: "r"(&trap_entry)
		: "memory"
	);

	__asm__ volatile (
		"fence.i"
		:
		:
		: "memory"
	);

	__asm__ volatile(
		"csrs mie, %0"
		:
		: "r"(MIE_MEIE)
		: "memory"
	);

	__asm__ volatile(
		"csrsi mstatus, %0"
		:
		: "i"(MSTATUS_MIE)
		: "memory"
	);
}

void __attribute__((weak))
boot(void)
{
#ifndef WITHOUT_BRICKGUARD
	guard();
#endif
#ifndef WITHOUT_BOOTCONFIG
	clock();
	u32 hfclk = prci_measure_hfclk(3000);
	flash(hfclk, FLASH_BAUDRATE);
	tty(hfclk, UART_BAUDRATE);
#endif
	plic();
	riscv();
}
