# See LICENSE file for copyright and license details.

CSRC := $(wildcard *.c)
ASRC := $(wildcard *.S)
OBJS := $(addprefix obj/, $(ASRC:.S=.o) $(CSRC:.c=.o))

override CFLAGS += -I../../inc
override CFLAGS += -I../libfe310/inc

all: lib/libenv.a

lib/libenv.a: $(OBJS)
	@mkdir -p $(@D)
	$(AR) rcs $@ $^

obj/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $<

obj/%.o: %.S
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	@rm -frv obj lib

.PHONY: all clean
