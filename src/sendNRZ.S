; sendNRZ.asm
; Samuel Richerd
; Assembly for Arduino UNO (Atmega328P)

#include <avr/io.h>

.section .text

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; sendNRZ
    ;  uint8_t* sendNRZ(uint8_t* start_ptr, uint8_t* stop_ptr)
    ;   start_ptr:  pointer to the address of the 1st byte to be sent
    ;   stop_ptr:   pointer to the next address AFTER the last byte to be sent 
    ;   @return pointer at which data transmission stopped (should be = stop_ptr)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Sends NRZ message to the LED ribbon.
    .global sendNRZ
sendNRZ:
    sbi _SFR_IO_ADDR(DDRB), 5 ; Set bit 5 (LED OUT)
    sbi _SFR_IO_ADDR(DDRB), 0
    ; Grab parameters passed to us:
    ; uint8_t* sendNRZ(uint8_t* start_ptr, uint8_t* stop_ptr)
    ; Set starting X address
    mov XL, r24; uint8_t* start_ptr is in r25:24
    mov XH, r25
    ; Set stop address: 0x0110
    mov r20, r23 ; uint8_t* stop_ptr is in r23:22
    mov r19, r22 
  ;
  ; Initialize the other registers:
  ;
    ld  r17, X+      ; get first word 
    ; set "constant" registers
    ldi r16, 0x01  
    ldi r21, 0x00
    ;set default values for the bit-encoding registers
    ldi r18, 0x80
    ldi r22, 0x80 ; copy of r18
    rjmp sendBit ; Get going!

doneWithAllData:
    nop ; sbi _SFR_IO_ADDR(PORTB), 5   ; Turn ON LED!
    ldi r18, 0xFF
resetDelay:
    nop
    nop
    nop
    nop
    dec r18
    brne resetDelay
    ;mov r25, XH 
    movw r24, XL ; Return value: ending address (not read) (16 bit address)
    ret

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
    nop
    cp  r19, XL
    cpc r20, XH
    breq doneWithAllData
    ld  r17, X+
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

;    .global __vector_default
;__vector_default:
;    reti

.end
