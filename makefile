# Samuel Richerd
# Makefile for le_lights project
CC=avr-gcc
CFLAGS=-shared -fPIC

LDIR =lib

_SRC = $(wildcard tests/*.c)
SRC_OBJ = $(patsubst tests/%.c, %.so, $(_SRC))


all: src 

$(SRC_OBJ):
	$(CC) $(CFLAGS) -o $(LDIR)/$@ $(patsubst %.so, tests/%.c, $@)

src: $(SRC_OBJ)


.PHONY: clean

# delete compiled libraries
clean:
	rm -f $(LDIR)/*.so *~ 
