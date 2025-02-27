# See LICENSE file for copyright and license details.

include config.mk

ASRC = $(wildcard $(addsuffix /*.S, $(SRCS)))
CSRC = $(wildcard $(addsuffix /*.c, $(SRCS)))
OBJS = $(addprefix $(BIN_DIR)/, $(notdir $(ASRC:.S=.o) $(CSRC:.c=.o)))

all: options $(ELF) $(HEX) $(LST)
	$(SIZE) $(ELF)

$(ELF): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ $(LDLIBS)

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

$(LST): $(ELF)
	$(OBJDUMP) $(OBJDUMP_OPT) $< > $@

$(BIN_DIR)/%.o: $(SRC_DIR)/%.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR)/%.o: $(SYS_DIR)/%.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR)/%.o: $(SRC_DIR)/%.S | $(BIN_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(BIN_DIR)/%.o: $(SYS_DIR)/%.S | $(BIN_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(BIN_DIR):
	@mkdir -p $@

clean:
	rm -rf $(BIN_DIR)

options:
	@echo "$(PROGRAM) build options:"
	@echo
	@echo "ASFLAGS = $(ASFLAGS)"
	@echo "CFLAGS  = $(CFLAGS)"
	@echo "LDFLAGS = $(LDFLAGS)"
	@echo "LDLIBS  = $(LDLIBS)"
	@echo

.PHONY: all clean options
