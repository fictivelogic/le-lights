# Samuel Richerd
# Makefile for le_lights project
CC=avr-gcc
CFLAGS= -mmcu=atmega328p
OUTPUT_NAME= le_lights.elf

# Set directories
ODIR=lib
SRCDIR=src

#
# List all C source files (C files must have accompanying H files)
#
_C_SRCS=main.c \
        serial.c

#
# List All ASM source files
#
_ASM_SRCS=sendNRZ.S 


# Check OS for Serial port determination and whatnot
ifeq ($(OS), Windows_NT)
    AVRDUDE_CONFIG=-C "C:\Program Files (x86)\Arduino\hardware\tools\avr/etc/avrdude.conf"
    SERIAL_PORT=COM17 
    RM_CMD=del
else
    AVRDUDE_CONFIG=""
    SERIAL_PORT=/dev/ttyACM0
    RM_CMD=rm -f
endif




# Add the "src/%" directory prefix
C_SRCS=$(patsubst %, $(SRCDIR)/%, $(_C_SRCS))
C_OBJS=$(patsubst %.c, $(ODIR)/%.o, $(_C_SRCS))
H_SRCS=$(patsubst %.c, $(SRCDIR)/%.h, $(_C_SRCS))

# Add the "src/%" directory prefix
ASM_SRCS= $(patsubst %, $(SRCDIR)/%, $(_ASM_SRCS))
ASM_OBJS= $(patsubst %.S, $(ODIR)/%.o, $(_ASM_SRCS))


all: $(OUTPUT_NAME)


$(OUTPUT_NAME): $(C_OBJS) $(ASM_OBJS)
	$(CC) $(CFLAGS) -o $@ $^



$(C_OBJS): $(ODIR)/%.o: $(SRCDIR)/%.c $(SRCDIR)/%.h
	$(CC) $(CFLAGS) -c -o $@ $<


#lib/sendNRZ.o: src/sendNRZ.S 
$(ASM_OBJS): $(ODIR)/%.o: $(SRCDIR)/%.S 
	$(CC) $(CFLAGS) -c -o $@ $<


## unused:
#sendNRZ.hex: sendNRZ.elf
#	avr-objcopy -j .text -j .data -O ihex lib/sendNRZ.elf lib/flashable.hex


.PHONY: clean

# delete compiled libraries
clean:
	$(RM_CMD) $(ODIR)\*.o 
	$(RM_CMD) $(OUTPUT_NAME)

# Load code onto the arduino
load: $(OUTPUT_NAME)
	avrdude $(AVRDUDE_CONFIG) -p m328p -c arduino -P $(SERIAL_PORT) -U flash:w:$(OUTPUT_NAME)


