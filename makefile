# Samuel Richerd
# Makefile for le_lights project
CC=avr-gcc
CFLAGS= -mmcu=atmega328p
OUTPUT_NAME= le_lights

LIBDIR=lib
OUTDIR=bin

_SRC = src/main.c #src/Adafruit_NeoPixel.cpp # $(wildcard src/*.c)
SRC_OBJ =   main.o \
            sendNRZ.o  #Adafruit_NeoPixel.o # $(patsubst src/%.c, %.o, $(_SRC))

all: $(OUTPUT_NAME)


$(OUTPUT_NAME): sendNRZ.o
	$(CC) $(CFLAGS) -o bin/$@ $(patsubst %, src/%.c, $@) lib/sendNRZ.o


sendNRZ.o: 
	$(CC) $(CFLAGS) -c -o $(LIBDIR)/$@ $(patsubst %.o, src/%.S, $@)

#flashable: sendNRZ.o main.o
#	$(CC) $(CFLAGS) lib/sendNRZ.o lib/main.o -o $@.o  


# unused:
sendNRZ.hex: sendNRZ.elf
	avr-objcopy -j .text -j .data -O ihex lib/sendNRZ.elf lib/flashable.hex


src: $(SRC_OBJ) sendNRZ.o


.PHONY: clean

# delete compiled libraries
clean:
	rm -f $(LIBDIR)/*.o 
	rm -f $(OUTDIR)/$(OUTPUT_NAME)

# Load code onto the arduino
load: $(OUTPUT_NAME)
	avrdude -p m328p -c arduino -P /dev/ttyACM0 -U flash:w:$(OUTDIR)/$(OUTPUT_NAME)


