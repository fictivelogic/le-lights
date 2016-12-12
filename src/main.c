// main.c 
// Samuel Richerd
// sricherd@gmail.com
// Le Lights (Addressable Colored LED project)

#define __AVR_ATmega328P__ // Arduino UNO ATMEGA328P
#define ARDUINO 328

#include <avr/io.h>

#define COUNT_BLINK     160000

int main(void)
{
    uint8_t counter = 0;
    // configure port B as output (on pin 5)

    DDRB = 0x21;
    PORTB = 0x20;
    while (1) {

        //if (counter == COUNT_BLINK)
        //{
        //    counter = 0;
        //    PORTB ^= 0x20;
        //}
        //counter = counter + 1;
        PORTB = counter++;
    }
    return 0;
}


