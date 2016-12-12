# Samuel Richerd
# Makefile for le_lights project
CC=avr-gcc
CFLAGS=#-shared -fPIC

LDIR =lib

_SRC = src/main.c #src/Adafruit_NeoPixel.cpp # $(wildcard src/*.c)
SRC_OBJ = main.o #Adafruit_NeoPixel.o # $(patsubst src/%.c, %.o, $(_SRC))


all: src 

$(SRC_OBJ):
	$(CC) $(CFLAGS) -o $(LDIR)/$@ $(patsubst %.o, src/%.c, $@)

asm: sendNRZ.hex


sendNRZ.elf: src/sendNRZ.S
	$(CC) -mmcu=atmega328p src/sendNRZ.S -o lib/sendNRZ.elf 

sendNRZ.hex: sendNRZ.elf
	avr-objcopy -j .text -j .data -O ihex lib/sendNRZ.elf lib/flashable.hex

src: $(SRC_OBJ)


.PHONY: clean

# delete compiled libraries
clean:
	rm -f $(LDIR)/*.o *~ 

# Load code onto the arduino
load: asm
	avrdude -p m328p -c arduino -P /dev/ttyACM0 -U flash:w:lib/flashable.hex


