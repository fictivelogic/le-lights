// Serial.c
// Serial communication library for arduino
// Author: Samuel Richerd - sricherd@gmail.com
//    a guy just trying to figure out this low-level AVR stuff

// Include global definitions
#include "glob_defs.h" 
#include "serial.h" // Include prototypes for this serial stuff

#include <avr/io.h>
//#include <util/setbaud.h>

void uart_init(void) 
{
    // 9600 Baud
    UBRR0H = 0x00;
    UBRR0L = 103;

    UCSR0A &= ~(_BV(U2X0)); // Not using 2x rate

    UCSR0C = _BV(UCSZ01) | _BV(UCSZ00); // 8-bit data
    UCSR0B = _BV(RXEN0) | _BV(TXEN0); // Enable Rx and Tx

}

void uart_putchar(char c) 
{
    while ((UCSR0A & 0x20) == 0)
    {
        asm volatile("nop");
    }

    UDR0 = c;
}

char uart_ischar() 
{
    // Returns whether there is a char or not
    if ((UCSR0A & 0x80) != 0x00)
        return UDR0;
    else
        return 0;
}







