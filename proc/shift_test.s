DEPTH 4096

.define LED_ADDRESS 0x1000
.define HEX_ADDRESS 0x2000
.define SW_ADDRESS  0x3000

// this code tests the lsl, lsr, asr, and ror instructions. The type of operation is
// selected with SW[6:5] (00 == lsl, 01 == lsr, 10 = asr, 11 == ror). The processor must
// be reset each time these switches are changed, to restart the code.
// The value to be shifted is displayed on HEX3-0; this value is placed into r0 at the 
// start of the code. The amount to be shifted in each loop iteration is set by SW[3:0].

START: mv   sp, =0x1000       // initialize sp to bottom of memory

MAIN:  mv   r0, =0x9010
       bl   DELAY
      
LOOP:  mv   r1, =SW_ADDRESS
       ld   r1, [r1]
       mv   r2, =LED_ADDRESS
       st   r1, [r2]
       mv   r2, r1
       add  r2, #1
       lsr  r2, #5            // get shift type (SW bits 6:5)

       cmp  r2, #0b00
       bne  LSR
       lsl  r0, r1
       b    CONT

LSR:   cmp  r2, #0b01
       bne  ASR
       lsr  r0, r1
       b    CONT

ASR:   cmp  r2, #0b10
       bne  ROR
       asr  r0, r1
       b    CONT

ROR:   ror  r0, r1

CONT:  bl   DELAY

       cmp  r0, #0
       beq  MAIN
       cmp  r0, #-1
       beq  MAIN

END:   b    LOOP

// causes a delay
DELAY: push r1
// the delay loop below works well for DESim. Use a longer delay if running on a 
// DE1-SoC board
       mvt  r1, #0x04       // r1 <- 2^10 = 1024
WAIT:  sub  r1, #1
       bne  WAIT
       pop  r1
       mv   pc, lr