# See LICENSE file for copyright and license details.

PROGRAM := firmware
TARGET  ?= fe310-g002

BSP_DIR = bsp
OBJ_DIR = obj
OUT_DIR = out
SRC_DIR = src
SYS_DIR = sys

SRCS := $(SYS_DIR) $(SRC_DIR)

ELF = $(OUT_DIR)/$(PROGRAM).elf
HEX = $(OUT_DIR)/$(PROGRAM).hex
LST = $(OUT_DIR)/$(PROGRAM).lst

STACK_SIZE ?= 0x400
TIMER_TICK ?= 0x4e200

CROSS_COMPILE ?= riscv32-unknown-elf-
CC      := $(CROSS_COMPILE)gcc
GDB     := $(CROSS_COMPILE)gdb
OBJCOPY := $(CROSS_COMPILE)objcopy
OBJDUMP := $(CROSS_COMPILE)objdump
SIZE    := $(CROSS_COMPILE)size

OBJDUMP_OPT = --source --all-headers --demangle --line-numbers --wide

ASFLAGS += -DTIMER_TICK=$(TIMER_TICK)
CFLAGS  += -pipe --specs=nano.specs -std=c99 -Wpedantic -Wall
CFLAGS  += -mabi=ilp32 -march=rv32imac_zicsr_zifencei -mcpu=sifive-e31
CFLAGS  += -mtune=sifive-3-series -mcmodel=medlow
ifeq ($(DEBUG), 1)
	CFLAGS += -g -Og
else
	CFLAGS += -Os
endif
CFLAGS  += -ffunction-sections -fdata-sections
LDFLAGS += -nostdlib -Wl,--gc-sections -Wl,-Map,$(OUT_DIR)/$(PROGRAM).map
LDFLAGS += -T$(BSP_DIR)/fe310.ld -Wl,--defsym=__stack_size=$(STACK_SIZE)
ifeq ($(TARGET), fe310-g000)
	LDFLAGS += -Wl,--defsym=__rom_size=0x20000000
endif
LDLIBS += -Wl,--start-group -lc -lgcc -lm -lgloss_nano -Wl,--end-group
