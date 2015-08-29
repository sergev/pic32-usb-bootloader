
DEPFLAGS	= -MT $@ -MP -MD -MF .deps/$*.dep
CFLAGS		= -I. -O $(DEFS) $(DEPFLAGS)
ASFLAGS		= -I. $(DEFS) $(DEPFLAGS)

include $(BUILDPATH)/gcc-config.mk

CC		= $(GCCPREFIX)gcc -EL -g -mips32r2
CC		+= -nostdinc -fno-builtin -Werror -Wall -fno-dwarf2-cfi-asm
LDFLAGS         += -nostdlib
SIZE		= $(GCCPREFIX)size
OBJDUMP		= $(GCCPREFIX)objdump
OBJCOPY		= $(GCCPREFIX)objcopy
BLCFLAGS        = -Os -I. $(DEFS) $(DEPFLAGS)
BLOBJS          = bl_usb_boot.o bl_usb_device.o bl_usb_function_hid.o bl_devcfg.o

DEFS            += -DCONFIG=$(CONFIG)

all:		.deps machine bootloader.elf
		$(SIZE) bootloader.elf

clean:
		rm -rf .deps *.o *.elf *.bin *.dis *.map *.srec machine

.deps:
		mkdir .deps

machine:
		ln -s $(BUILDPATH) $@

bootloader.elf: $(BLOBJS)
		$(CC) $(LDFLAGS) -T$(BUILDPATH)/boot.ld -Wl,-Map=usbboot.map $(BLOBJS) -o $@
		chmod -x $@
		$(OBJDUMP) -d -S $@ > bootloader.dis
		$(OBJCOPY) -O ihex --change-addresses=0x80000000 $@ bootloader.hex

bl_usb_boot.o:  $(BUILDPATH)/usb_boot.c
		$(CC) $(BLCFLAGS) -o $@ -c $<

bl_usb_device.o: $(BUILDPATH)/usb_device.c
		$(CC) $(BLCFLAGS) -o $@ -c $<

bl_usb_function_hid.o: $(BUILDPATH)/usb_function_hid.c
		$(CC) $(BLCFLAGS) -o $@ -c $<

bl_devcfg.o:    devcfg.c
		$(CC) $(BLCFLAGS) -o $@ -c $<

load:           bootloader.hex
		pic32prog $(BLREBOOT) bootloader.hex

.SUFFIXES:	.i .srec .hex .dis .cpp .cxx .bin .elf

.o.dis:
		$(OBJDUMP) -d -z -S $< > $@

ifeq (.deps, $(wildcard .deps))
-include .deps/*.dep
endif
