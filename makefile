src:=./src
bin:=./bin
assemblerdefinition:=arm-t32
microcontroller:=STM32F401
defines:=define $(microcontroller)
outasmFile:=out.S
skip:=0x20000000
outElfFile:=out.elf
outYamaBinfile:=outYama.bin
outGccBinFile:=outGcc.bin
includes:=inc ./armlibrary

all: clean init build

init:
	git submodule update --init
	mkdir -p $(bin)

build: compile assembly toBinfile

toBinfile:
	arm-none-eabi-objcopy -O binary $(bin)/$(outElfFile) $(bin)/$(outGccBinFile)

assembly:
	arm-none-eabi-gcc -nostartfiles -nostdlib -mcpu=cortex-m4 -Ttext=$(skip) -o $(bin)/$(outElfFile) $(bin)/$(outasmFile)

compile:
	yama build skip $(skip) out $(bin)/$(outYamaBinfile) ao $(bin)/$(outasmFile) $(defines) def $(assemblerdefinition) inc $(src) $(includes)

test:
	yama assemble skip $(skip) out $(bin)/$(outYamaBinfile) $(defines) def $(assemblerdefinition) asm/program.S
	arm-none-eabi-gcc -nostartfiles -nostdlib -mcpu=cortex-m4 -Ttext=$(skip) -o $(bin)/$(outElfFile) asm/program.S
	arm-none-eabi-objcopy -O binary $(bin)/$(outElfFile) $(bin)/$(outGccBinFile)

clean:
	rm -rf $(bin)
