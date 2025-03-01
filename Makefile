# See LICENSE file for copyright and license details.

include config.mk

ASRC = $(wildcard $(addsuffix /*.S, $(SRCS)))
CSRC = $(wildcard $(addsuffix /*.c, $(SRCS)))
OBJS = $(addprefix $(OBJ_DIR)/, $(ASRC:.S=.o) $(CSRC:.c=.o))

all: options $(ELF) $(HEX) $(LST)
	$(SIZE) $(ELF)

$(ELF): $(OBJS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ $(LDLIBS)

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

$(LST): $(ELF)
	$(OBJDUMP) $(OBJDUMP_OPT) $< > $@

$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJ_DIR)/%.o: %.S
	@mkdir -p $(@D)
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -rf $(OBJ_DIR) $(OUT_DIR)

options:
	@echo "$(PROGRAM) build options:"
	@echo
	@echo "ASFLAGS = $(ASFLAGS)"
	@echo "CFLAGS  = $(CFLAGS)"
	@echo "LDFLAGS = $(LDFLAGS)"
	@echo "LDLIBS  = $(LDLIBS)"
	@echo

.PHONY: all clean options
