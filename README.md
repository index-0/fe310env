# [FE310 Development Environment](https://codeberg.org/idx/fe310-newlib)
Minimalist C environment for the FE310-G000 and FE310-G002 SoCs, using newlib-nano.

## Prerequisites
- RISC-V toolchain targeting `rv32imac_zicsr_zifencei`
- QEMU with support for the `sifive_e` machine

### Building a RISC-V Toolchain
If you don’t already have a toolchain, you can build one as follows:
```sh
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv \
            --with-arch=rv32imac_zicsr_zifencei \
            --with-abi=ilp32 \
            --with-cmodel=medlow
make -j$(nproc)
```
> Add `--enable-llvm` to include Clang support. For other options, see the [riscv-gnu-toolchain](https://github.com/riscv/riscv-gnu-toolchain) repository.

Finally, add `/opt/riscv/bin` to your `PATH`:
```sh
export PATH=/opt/riscv/bin:$PATH
```

## Usage
### Configuration
Run `./configure` with the target board to generate the development environment:
``` sh
./configure hifive1-revb
```
> Run `./configure --help` to see all available options.

Place your C source files in `<srcdir>`, your headers in `<incdir>`, and the output will be written to `<outdir>`. These directories are defined during configuration.

### Building
To build the firmware:
```sh
make
```

This will produce the following files in `<outdir>`:
- `<program>.elf`: Executable (for debugging)
- `<program>.hex`: Flashable firmware
- `<program>.lst`: Assembly listing
- `<program>.map`: Memory map

### Cleaning
To remove build artifacts and output files, run:
```sh
make clean
```

### Simulation
You can run your firmware in QEMU with a single command:
```sh
make simulate
```
This target will launch QEMU in a halted state, waiting for a debugger connection.

To debug in GDB, open a second terminal and start:
```sh
riscv32-unknown-elf-gdb build/firmware.elf
```
Then connect to QEMU and set the program counter before continuing:
```sh
(gdb) target extended-remote :1234
(gdb) set $pc=0x20000000
```

> **Why adjust `$pc`?**  
> QEMU resets to `0x1004` and expects a bootloader to jump to firmware at `0x20010000` or `0x20400000`, depending on the board. Since this environment replaces the original bootloader, the firmware starts directly at `0x20000000`, so we must set `$pc` manually to begin execution at the correct address.

## Communication
### Serial Console
To communicate with the board via its USB serial interface, configure the baud rate and mode:
```sh
stty -F /dev/ttyACM<n> <BAUDRATE> cs8 -cstopb raw -echo
```
> If using the default boot configuration, the baud rate for `/dev/ttyACM0` is 500000.

#### Reading Data
To read data:
``` sh
cat /dev/ttyACM<n>
```

#### Writing Data
To send data, frame the message with `STX/ETX` like so:
```sh
printf "\002<data>\003" > /dev/ttyACM0
```
