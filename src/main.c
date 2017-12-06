// main.c 
// Samuel Richerd
// sricherd@gmail.com
// Le Lights (Addressable Colored LED project)

//#define __AVR_ATmega328P__ // Arduino UNO ATMEGA328P
//#define ARDUINO 328

#include <avr/io.h>
#include "serial.h"
#include <math.h>

#define COUNT_BLINK     160000

// sendNRZ is implemented in sendNRZ.S (in AVR assembly, for timing considerations)
extern uint8_t* sendNRZ(uint8_t* start_ptr, uint8_t* stop_ptr);
//extern uint8_t initData(void);

#define NUM_LEDS        60
#define LED_INTENSITY   40

enum pattern_modes {
     MODE_COLOR_STREAKS,
     MODE_CHRISTMAS_STATIC,
     MODE_CHRISTMAS_STREAKS,
     NUM_MODES };

typedef struct pixel_struct {
    uint8_t G;
    uint8_t R;
    uint8_t B;
    uint8_t W;
} pixel_t;

typedef struct rgb_struct {
    uint8_t r;
    uint8_t g;
    uint8_t b;
} rgb_t;

// borrowed code from stackoverflow
// http://stackoverflow.com/questions/3018313/algorithm-to-convert-rgb-to-hsv-and-hsv-to-rgb-in-range-0-255-for-both
rgb_t hsv2rgb(uint8_t h, uint8_t s, uint8_t v)
{
    rgb_t rgb;
    uint8_t region, remainder, p, q, t;

    if (s == 0)
    {
        rgb.r = v;
        rgb.g = v;
        rgb.b = v;
        return rgb;
    }

    region = h / 43;
    remainder = (h - (region * 43)) * 6; 

    p = (v * (255 - s)) >> 8;
    q = (v * (255 - ((s * remainder) >> 8))) >> 8;
    t = (v * (255 - ((s * (255 - remainder)) >> 8))) >> 8;

    switch (region)
    {
        case 0:
            rgb.r = v; rgb.g = t; rgb.b = p;
            break;
        case 1:
            rgb.r = q; rgb.g = v; rgb.b = p;
            break;
        case 2:
            rgb.r = p; rgb.g = v; rgb.b = t;
            break;
        case 3:
            rgb.r = p; rgb.g = q; rgb.b = v;
            break;
        case 4:
            rgb.r = t; rgb.g = p; rgb.b = v;
            break;
        default:
            rgb.r = v; rgb.g = p; rgb.b = q;
            break;
    }

    return rgb;
}

int main(void)
{
    unsigned int counter = 0;
    uint8_t offset = 0;
    uint8_t pixel_idx = 0; // Index of pixel being lit-up, 
    uint8_t going_up = 1; // going up or going down
    uint8_t pattern_mode = MODE_CHRISTMAS_STATIC; // default is color streaks
    uint8_t led_intensity = 40;
    uint8_t rx_char = 0;
    // goes 0->1->...->59->58->...->1->0->1...

    volatile unsigned int longcount = 0;
    uint8_t *resp = 0;
    rgb_t tmp_rgb = {0};
    pixel_t pixData[NUM_LEDS] ;

    // Disable interrupts globally
//    asm volatile("cli");
    // configure port B as output (on pin 5 and pin 0)
    DDRB = 0x21;
    PORTB = 0x20;

    uart_init();

    uart_putchar('c');
    uart_putchar((char)((((uint16_t)pixData) & 0xFF00) >> 8));
    uart_putchar((char)((((uint16_t)pixData) & 0x00FF)));
    uart_putchar((char)((((uint16_t)resp) & 0xFF00) >> 8));
    uart_putchar((char)((((uint16_t)resp) & 0x00FF)));


    // Setup data:
    for (counter = 0; counter != NUM_LEDS; counter++)
    {
        pixData[counter].R = 0; //(counter % 4 == 1) ? LED_INTENSITY : 0x00;
        pixData[counter].G = 0; //(counter % 4 == 0) ? LED_INTENSITY : 0x00;
        pixData[counter].B = 0; //(counter % 4 == 2) ? LED_INTENSITY : 0x00;
        pixData[counter].W = 0; //(counter % 4 == 3) ? LED_INTENSITY : 0x00;
    }

    // Sends message 
    resp = sendNRZ((uint8_t*)pixData, (uint8_t*)&pixData[NUM_LEDS]); 
    // Check for errors in response
    if (resp == (uint8_t*)pixData+4*NUM_LEDS)
        PORTB = 0x20;

    while (1)
    {
        // Check for UART input
        rx_char = uart_ischar();
        if (rx_char != 0)
        {
            switch(rx_char)
            {
                case '-':
                    // decrease intensity
                    if (led_intensity != 0)
                        led_intensity--;
                break;
                case '+':
                    // increase intensity
                    if (led_intensity != 255)
                        led_intensity++;
                break;
                case 'm':
                    // switch modes:
                    pattern_mode++;
                    if (pattern_mode == NUM_MODES)
                        pattern_mode = 0;
                break;
                default:
                    uart_putchar('?');
            }
        }
        
        // Dim all pixels
        switch (pattern_mode) 
        {
            case MODE_COLOR_STREAKS:
                // Original Color streaks 
                for (counter = 0; counter != NUM_LEDS; counter++)
                {
                    pixData[counter].W = 0; // Clear the Whites
                    if (counter == pixel_idx) 
                    {
                        // new color: 
                        tmp_rgb = hsv2rgb(counter+1, 255, 255);
                        pixData[counter].R = tmp_rgb.r; //(counter % 4 == 1) ? LED_INTENSITY : 0x00;
                        pixData[counter].G = tmp_rgb.g; //(counter % 4 == 0) ? LED_INTENSITY : 0x00;
                        pixData[counter].B = tmp_rgb.b; //(counter % 4 == 2) ? LED_INTENSITY : 0x00;
                    } else if (59-counter == pixel_idx) {
                        tmp_rgb = hsv2rgb(255-offset, 255, 255);
                        pixData[counter].R = tmp_rgb.r; //(counter % 4 == 1) ? LED_INTENSITY : 0x00;
                        pixData[counter].G = tmp_rgb.g; //(counter % 4 == 0) ? LED_INTENSITY : 0x00;
                        pixData[counter].B = tmp_rgb.b; //(counter % 4 == 2) ? LED_INTENSITY : 0x00;
                    } else {
                        pixData[counter].R = pixData[counter].R >> 1; //(counter % 4 == 1) ? LED_INTENSITY : 0x00;
                        pixData[counter].G = pixData[counter].G >> 1; //(counter % 4 == 0) ? LED_INTENSITY : 0x00;
                        pixData[counter].B = pixData[counter].B >> 1; //(counter % 4 == 2) ? LED_INTENSITY : 0x00;
                    }
                }
            break;
            case MODE_CHRISTMAS_STATIC:
                for (counter = 0; counter != NUM_LEDS; counter++)
                {
                    if (counter % 3 == 0)
                    {
                        pixData[counter].R = led_intensity;
                        pixData[counter].G = 0;
                        pixData[counter].B = 0;
                        pixData[counter].W = 0;
                    } else if (counter % 3 == 1) {
                        pixData[counter].R = 0;
                        pixData[counter].G = led_intensity;
                        pixData[counter].B = 0;
                        pixData[counter].W = 0;
                    } else {
                        pixData[counter].R = 0;
                        pixData[counter].G = 0;
                        pixData[counter].B = 0;
                        pixData[counter].W = led_intensity;
                    }
                }
            break;
            case MODE_CHRISTMAS_STREAKS:
                for (counter = 0; counter != NUM_LEDS; counter++)
                {
                    if (counter == pixel_idx) 
                    {
                        if (counter % 3 == 0)
                        {
                            pixData[counter].R = led_intensity;
                            pixData[counter].G = 0;
                            pixData[counter].B = 0;
                            pixData[counter].W = 0;
                        } else if (counter % 3 == 1) {
                            pixData[counter].R = 0;
                            pixData[counter].G = led_intensity;
                            pixData[counter].B = 0;
                            pixData[counter].W = 0;
                        } else {
                            pixData[counter].R = 0;
                            pixData[counter].G = 0;
                            pixData[counter].B = 0;
                            pixData[counter].W = led_intensity;
                        }
                    } else {
                        if (pixData[counter].R != 0)
                            pixData[counter].R--;
                        if (pixData[counter].G != 0)
                            pixData[counter].G--;
                        if (pixData[counter].W != 0)
                            pixData[counter].W--;
                    }
                }
            break;
        }


        // update LEDs
        resp = sendNRZ((uint8_t*)pixData, (uint8_t*)&pixData[NUM_LEDS]); 

        // Update color offset
        offset++;
        if (offset == 255)
            offset = 0;

        switch (pattern_mode) 
        {
            case MODE_COLOR_STREAKS:
                // Update pixel index:
                if (going_up == 1)
                {
                    if (pixel_idx == NUM_LEDS-1)
                    {
                        pixel_idx = NUM_LEDS-2;
        //                uart_putchar((char)'d');
        //                uart_putchar((char)((((uint16_t)pixData) & 0xFF00) >> 8));
        //                uart_putchar((char)((((uint16_t)pixData) & 0x00FF)));
        //                uart_putchar((char)((((uint16_t)resp) & 0xFF00) >> 8));
        //                uart_putchar((char)((((uint16_t)resp) & 0x00FF)));
                        going_up = 0;
                    } else {
                        pixel_idx++;
                    }
                } else {
                    if (pixel_idx == 0)
                    {
        //                uart_putchar((char)'u');
        //                uart_putchar((char)((((uint16_t)pixData) & 0xFF00) >> 8));
        //                uart_putchar((char)((((uint16_t)pixData) & 0x00FF)));
        //                uart_putchar((char)((((uint16_t)resp) & 0xFF00) >> 8));
        //                uart_putchar((char)((((uint16_t)resp) & 0x00FF)));
                        pixel_idx = 1;
                        going_up = 1;
                    } else {
                        pixel_idx--;
                    }
                }
            break;
            case MODE_CHRISTMAS_STREAKS:
                if (pixel_idx == 0)
                    pixel_idx = 0x13;
                pixel_idx >>= 1;
                if (pixel_idx & 0x01)
                    pixel_idx ^= 0x8E;
            break;
        }


        // delay
        for(longcount = 0; longcount < 20000; longcount++)
            {
                }
    }
    
    return 0;
}

