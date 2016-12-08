# Samuel Richerd
# Makefile for le_lights project
CC=avr-gcc
CFLAGS=#-shared -fPIC

LDIR =lib

_SRC = $(wildcard src/*.c)
SRC_OBJ = $(patsubst src/%.c, %.o, $(_SRC))


all: src 

$(SRC_OBJ):
	$(CC) $(CFLAGS) -o $(LDIR)/$@ $(patsubst %.o, src/%.c, $@)

src: $(SRC_OBJ)


.PHONY: clean

# delete compiled libraries
clean:
	rm -f $(LDIR)/*.o *~ 

# Load code onto the arduino
load:
	avrdude -p m328p -c arduino -P /dev/ttyACM0 -U flash:w:lib/main.o


