// Serial.c
// Serial communication library for arduino
// Author: Samuel Richerd - sricherd@gmail.com
//    a guy just trying to figure out this low-level AVR stuff

// Include global definitions
#include "glob_defs.h" 
#include "serial.h" // Include prototypes for this serial stuff

#include <avr/io.h>
//#include <util/setbaud.h>
#define BAUD_RATE   150000
//#define MYUBRR FOSC/(2*BAUD_RATE)-1

void sync_serial_init(void) 
{
    // 400 kBaud
    UBRR0H = 0;
    UBRR0L = 10;

   // UCSR0A &= ~(_BV(U2X0)); // Not using 2x rate

    UCSR0C = _BV(UMSEL00) | _BV(UCPOL0); // Select Sync-Serial clock, and Rising-edge latched, falling edge changing 
    UCSR0B = _BV(TXEN0); // Enable only Tx

}

void ssio_send(char c) 
{
    // Blocking send...
    while ((UCSR0A & 0x20) == 0)
    {
        asm volatile("nop");
    }

    UDR0 = c;
}








