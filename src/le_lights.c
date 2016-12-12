// main.c 
// Samuel Richerd
// sricherd@gmail.com
// Le Lights (Addressable Colored LED project)

//#define __AVR_ATmega328P__ // Arduino UNO ATMEGA328P
//#define ARDUINO 328

#include <avr/io.h>

#define COUNT_BLINK     160000

// sendNRZ is implemented in sendNRZ.S (in AVR assembly, for timing considerations)
extern uint8_t* sendNRZ(uint8_t* start_ptr, uint8_t* stop_ptr);
extern uint8_t initData(void);

#define NUM_LEDS        60
#define LED_INTENSITY   4

typedef struct pixel_struct {
    uint8_t G;
    uint8_t R;
    uint8_t B;
    uint8_t W;
} pixel_t;

int main(void)
{
    uint8_t counter = 0;
    uint8_t *resp = 0;
    pixel_t pixData[NUM_LEDS] ;
    // configure port B as output (on pin 5 and pin 0)
    DDRB = 0x21;
    PORTB = 0x20;

    // Setup data:
    for (counter = 0; counter != NUM_LEDS; counter++)
    {
        pixData[counter].G = (counter % 4 == 0) ? LED_INTENSITY : 0x00;
        pixData[counter].R = (counter % 4 == 1) ? LED_INTENSITY : 0x00;
        pixData[counter].B = (counter % 4 == 2) ? LED_INTENSITY : 0x00;
        pixData[counter].W = (counter % 4 == 3) ? LED_INTENSITY : 0x00;
    }

    // Sends message only once
    resp = sendNRZ((uint8_t*)pixData, (uint8_t*)&pixData[NUM_LEDS]); 
    if (resp == pixData+4*NUM_LEDS)
        PORTB = 0x20;

    
    return 0;
}


