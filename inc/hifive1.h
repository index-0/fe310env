/* See LICENSE file for copyright and license details. */

#ifndef BOARD_GPIO_H
#define BOARD_GPIO_H

#include <fe310/core/plic.h>
#include <fe310/periph/gpio.h>

#define LED_R GPIO_PIN(22)
#define LED_G GPIO_PIN(19)
#define LED_B GPIO_PIN(21)

#define PIN_0 GPIO_PIN(16)
#define PIN_1 GPIO_PIN(17)
#define PIN_2 GPIO_PIN(18)
#define PIN_3 GPIO_PIN(19)
#define PIN_4 GPIO_PIN(20)
#define PIN_5 GPIO_PIN(21)
#define PIN_6 GPIO_PIN(22)
#define PIN_7 GPIO_PIN(23)

#define PIN_8 GPIO_PIN(0)
#define PIN_9 GPIO_PIN(1)
#define PIN_10 GPIO_PIN(2)
#define PIN_11 GPIO_PIN(3)
#define PIN_12 GPIO_PIN(4)
#define PIN_13 GPIO_PIN(5)

/* #define PIN_14 NO_CONNECT */
#define PIN_15 GPIO_PIN(9)
#define PIN_16 GPIO_PIN(10)
#define PIN_17 GPIO_PIN(11)
#define PIN_18 GPIO_PIN(12)
#define PIN_19 GPIO_PIN(13)

#define PLIC_IRQ_PIN(pin) (\
	(pin) == PIN_0 ? PLIC_IRQ_GPIO16 : \
	(pin) == PIN_1 ? PLIC_IRQ_GPIO17 : \
	(pin) == PIN_2 ? PLIC_IRQ_GPIO18 : \
	(pin) == PIN_3 ? PLIC_IRQ_GPIO19 : \
	(pin) == PIN_4 ? PLIC_IRQ_GPIO20 : \
	(pin) == PIN_5 ? PLIC_IRQ_GPIO21 : \
	(pin) == PIN_6 ? PLIC_IRQ_GPIO22 : \
	(pin) == PIN_7 ? PLIC_IRQ_GPIO23 : \
	(pin) == PIN_8 ? PLIC_IRQ_GPIO0 : \
	(pin) == PIN_9 ? PLIC_IRQ_GPIO1 : \
	(pin) == PIN_10 ? PLIC_IRQ_GPIO2 : \
	(pin) == PIN_11 ? PLIC_IRQ_GPIO3 : \
	(pin) == PIN_12 ? PLIC_IRQ_GPIO4 : \
	(pin) == PIN_13 ? PLIC_IRQ_GPIO5 : \
	(pin) == PIN_15 ? PLIC_IRQ_GPIO9 : \
	(pin) == PIN_16 ? PLIC_IRQ_GPIO10 : \
	(pin) == PIN_17 ? PLIC_IRQ_GPIO11 : \
	(pin) == PIN_18 ? PLIC_IRQ_GPIO12 : \
	(pin) == PIN_19 ? PLIC_IRQ_GPIO13 : \
	PLIC_IRQ_NONE)

#define PLIC_IRQ_PIN_BIT(pin) (PLIC_IRQ_BIT(PLIC_IRQ_PIN(pin)))

#endif /* BOARD_GPIO_H */
