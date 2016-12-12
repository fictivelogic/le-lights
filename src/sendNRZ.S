; sendNRZ.asm
; Samuel Richerd
; Assembly for Arduino UNO (Atmega328P)

#include <avr/io.h>

.section .text

    .global main
main:
    ;rcall ioinit
    sbi _SFR_IO_ADDR(DDRB), 5 ; Set bit 5 (LED OUT)
    sbi _SFR_IO_ADDR(DDRB), 0
    ;sei ; set interrupts?
    ldi r22, 0x00       ; r22 = 0xFF
    ldi r23, 0x04       ; r23 = 0x00
    ; pixel 0 
    sts 0x0100, r23 ; pixel 0 G
    sts 0x0101, r22 ; pixel 0 R
    sts 0x0102, r22 ; pixel 0 B
    sts 0x0103, r22 ; pixel 0 W
    ; pixel 1
    sts 0x0104, r22 ; pixel 1 G
    sts 0x0105, r23 ; pixel 1 R
    sts 0x0106, r22 ; pixel 1 B
    sts 0x0107, r22 ; pixel 1 W
    ; pixel 2 R/G reversed?!?
    sts 0x0108, r22 ; pixel 2 G
    sts 0x0109, r22 ; pixel 2 R
    sts 0x010A, r23 ; pixel 2 B
    sts 0x010B, r22 ; pixel 2 W
    ; pixel 3 
    sts 0x010C, r23 ; pixel 3 G
    sts 0x010D, r22 ; pixel 3 R
    sts 0x010E, r22 ; pixel 3 B
    sts 0x010F, r22 ; pixel 3 W
    ; pixel 4 
    sts 0x0110, r22 ; pixel 4 G
    sts 0x0111, r23 ; pixel 4 R
    sts 0x0112, r22 ; pixel 4 B
    sts 0x0113, r22 ; pixel 4 B
    ; pixel 5 
    sts 0x0114, r22 ; pixel 4 G
    sts 0x0115, r22 ; pixel 4 R
    sts 0x0116, r23 ; pixel 4 B
    sts 0x0117, r22 ; pixel 4 B
instuff:
    ; Set stop address: 0x0110
    ldi r20, 0x01
    ldi r19, 0x18 
    ; Set starting Y address
    ldi YL, 0x00    ; reset addresses
    ldi YH, 0x01
    ld  r17, Y+      ; get first word 
    ; set "constant" registers
    ldi r16, 0x01  
    ldi r21, 0x00
    ;set default values
    ldi r18, 0x80
    ldi r22, 0x80 ; copy of r18
    rjmp sendBit ; Get going!

doneWithAllPixels:
    sbi _SFR_IO_ADDR(PORTB), 5   ; Turn ON LED!
    ldi r18, 0xFF
loop:
    nop
    nop
    nop
    nop
    dec r18
    brne loop
    rjmp instuff

sendBit:
    out _SFR_IO_ADDR(PORTB), r16   ; ON - 1 cycle Set bit 0 HIGH 1 cycle
    mov r22, r18
    and r22, r17
    brne itsa1   ; if 0, continue, else branch to itsa1
    out _SFR_IO_ADDR(PORTB), r21
    ;nop
    nop
    nop
    rjmp finishbit

itsa1:
    nop
    nop
    nop
    nop
    out _SFR_IO_ADDR(PORTB), r21
finishbit:
    lsr r18
    brcc regular0
    ldi r18, 0x80 ; reset r18
    ;adiw YL, 1
    nop
    cp  r19, YL
    cpc r20, YH
    breq doneWithAllPixels
    ld  r17, Y+
    rjmp sendBit
    
regular0:
    nop
    nop
    ;nop
    ;nop
    nop
    nop
    rjmp sendBit


ioinit:
    sbi _SFR_IO_ADDR(DDRB), 5 ; Set bit 5 (LED OUT)
    sbi _SFR_IO_ADDR(DDRB), 0
    ret;ldi r16, 

;tx1NRZ: 
; at 16MHz, each cycle is ~0.063us
; (us) min   typ  max       target it 10 cycles (630 ns)
; T1H: 0.45  0.6  0.75
; T1L: 0.45  0.6  0.75

    
;tx0NRZ: 
; at 16MHz, each cycle is ~0.063us
; (us) min   typ  max       
; T0H: 0.15  0.3  0.45      5 cycles: ~0.315us
; T0L: 0.75  0.9  1.05      13 cycles:~0.819us

    .global __vector_default
__vector_default:
    reti

.end
