# Samuel Richerd
# Makefile for le_lights project
CC=avr-gcc
CFLAGS= -mmcu=atmega328p
OUTPUT_NAME= le_lights

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

LIBDIR=lib
OUTDIR=bin

_SRC = src/main.c #src/Adafruit_NeoPixel.cpp # $(wildcard src/*.c)
SRC_OBJ =   main.o \
            sendNRZ.o  #Adafruit_NeoPixel.o # $(patsubst src/%.c, %.o, $(_SRC))

all: $(OUTPUT_NAME)


$(OUTPUT_NAME): sendNRZ.o
	$(CC) $(CFLAGS) -o bin/$@.elf $(patsubst %, src/%.c, $@) lib/sendNRZ.o


sendNRZ.o: 
	$(CC) $(CFLAGS) -c -o $(LIBDIR)/$@ $(patsubst %.o, src/%.S, $@)

#flashable: sendNRZ.o main.o
#	$(CC) $(CFLAGS) lib/sendNRZ.o lib/main.o -o $@.o  


## unused:
#sendNRZ.hex: sendNRZ.elf
#	avr-objcopy -j .text -j .data -O ihex lib/sendNRZ.elf lib/flashable.hex


.PHONY: clean

# delete compiled libraries
clean:
	$(RM_CMD) $(LIBDIR)\*.o 
	$(RM_CMD) $(OUTDIR)\$(OUTPUT_NAME)

# Load code onto the arduino
load: $(OUTPUT_NAME)
	avrdude $(AVRDUDE_CONFIG) -p m328p -c arduino -P $(SERIAL_PORT) -U flash:w:$(OUTDIR)/$(OUTPUT_NAME).elf


