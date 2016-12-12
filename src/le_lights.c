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

typedef struct pixel_struct {
    uint8_t G;
    uint8_t R;
    uint8_t B;
    uint8_t W;
} pixel_t;

int main(void)
{
    uint8_t counter = 0;
    // configure port B as output (on pin 5)
    uint8_t *resp = 0;
    pixel_t *pixData = (pixel_t *)0x0100;
    uint8_t pixdat[4] = {0};
    DDRB = 0x21;
    PORTB = 0x20;
//    initData();
    // setup data
    for (counter = 0; counter != 4; counter++)
    {
        pixdat[counter] = 0xFF;
        pixData[counter].G = 0x00; //(counter % 4 == 0) ? 0x04 : 0x00;
        pixData[counter].R = 0x00; //(counter % 4 == 1) ? 0x04 : 0x00;
        pixData[counter].B = 0x00; //(counter % 4 == 2) ? 0x04 : 0x00;
        pixData[counter].W = 0xFF; //(counter % 4 == 3) ? 0x04 : 0x00;
    }

   // while (1) {
        // send NRZ message ad nauseum
        sendNRZ((uint8_t*)pixData, (uint8_t*)pixData+4); 
    
    return 0;
}


