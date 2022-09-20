;****************** Lab3.s ***************
; Program written by: Put your names here
; Date Created: 2/4/2017
; Last Modified: 1/10/2022
; Brief description of the program
;   The LED toggles at 2 Hz and a varying duty-cycle
; Hardware connections (External: Two buttons and one LED)
;  Change is Button input  (1 means pressed, 0 means not pressed)
;  Breathe is Button input  (1 means pressed, 0 means not pressed)
;  LED is an output (1 activates external LED)
; Overall functionality of this system is to operate like this
;   1) Make LED an output and make Change and Breathe inputs.
;   2) The system starts with the the LED toggling at 2Hz,
;      which is 2 times per second with a duty-cycle of 30%.
;      Therefore, the LED is ON for 150ms and off for 350 ms.
;   3) When the Change button is pressed-and-released increase
;      the duty cycle by 20% (modulo 100%). Therefore for each
;      press-and-release the duty cycle changes from 30% to 70% to 70%
;      to 90% to 10% to 30% so on
;   4) Implement a "breathing LED" when Breathe Switch is pressed:
; PortE device registers
GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_DEN_R   EQU 0x4002451C
SYSCTL_RCGCGPIO_R  EQU 0x400FE608

        IMPORT  TExaS_Init
        THUMB
        AREA    DATA, ALIGN=2
;global variables go here

       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT EID1
EID1   DCB "hc27426",0  ;replace ABC123 with your EID
       EXPORT EID2
EID2   DCB "gaw2322",0  ;replace ABC123 with your EID
       ALIGN 4

     EXPORT  Start

Start
; TExaS_Init sets bus clock at 80 MHz, interrupts, ADC1, TIMER3, TIMER5, and UART0
     MOV R0,#2  ;0 for TExaS oscilloscope, 1 for PORTE logic analyzer, 2 for Lab3 grader, 3 for none
     BL  TExaS_Init ;enables interrupts, prints the pin selections based on EID1 EID2
;Initializations
	;clock
	LDR R0, = SYSCTL_RCGCGPIO_R
	LDRB R1, [R0]
	ORR R1, #0x10 ; enable Port E clock
	STRB R1, [R0]
	NOP
	NOP
	;Define direction(in and out) input 0(change) input 3(breathe) output  4(Led)
	LDR R0, =GPIO_PORTE_DIR_R
	LDR R1, [R0]
	BIC R1, #0x09 ; clear input pins
	ORR R1, #0x10 ; set output bits to 1
	STR R1, [R0] ;
;DIGITAL ENABLE FOR TURNING ON 
	LDR R0, =GPIO_PORTE_DEN_R ;READ
	LDRB R1, [R0]
	ORR R1, #0x19 ;MODIFY TURN ON PE 0, 3, 4
	STRB R1, [R0] ; WRITE
	MOV R8, #300 ;initial BRTH on value
	MOV R9, #700 ; initial BRTH off value
	MOV R10, #300 ;intial R10 value
	MOV R11, #700;initial R11 value
	






loop  
; main engine goes here
;R10 on delay R11 delay 
;Toggle LED pin


	
;Regular on and off
RUN	LDR R0, = GPIO_PORTE_DATA_R
	LDR R1, [R0]
	ORR R1, #0x10
	STR R1, [R0]
	;Delay cycle# counts
	MOV R3, R10 ; counter1 n, n*.5 wait
	BL DELAY
	

	BIC R1, #0x10
	LDR R0, = GPIO_PORTE_DATA_R ; get Data address again
	STR R1, [R0]
	MOV R3, R11; counter2 
	BL DELAY
	AND R6, R6, #0
	
	B CHK


	 B    loop
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY 
	MOV R0, #12000
	
WAIT ;subtract constantly to get a wait of .5 ms
	SUBS R0, R0, #0x01
	BNE WAIT
	
	SUBS R3, R3, #1
	BNE DELAY
	BX LR
	
;;;;;;
DELAY1
	MOV R0, #240
	
WAIT1 ;subtract constantly to get a wait of .5 ms
	SUBS R0, R0, #0x01
	BNE WAIT1
	
	SUBS R3, R3, #1
	BNE DELAY1
	BX LR
;;;;;;;;;;;;;;;
OVER ;if R10 is above 900, swtich R10 100, R11 900
	MOV R10, #100
	MOV R11, #900
	
	B RUN
;;;;;;;;;;;;;;;
BRTH 
	;chk 900
	SUBS R4, R8, #900 
	BPL ABV
	BMI BLW
	
ABV	MOV R8, #100
	MOV R9, #900
	B B2
	
BLW	ADD R8, R8, #5
	SUBS R9, R9, #5
	B B2

	;delay using R8
	
B2	LDR R0, = GPIO_PORTE_DATA_R
	LDR R1, [R0]
	ORR R1, #0x10
	STR R1, [R0]
	;Delay cycle# counts
	MOV R3, R8 ; counter1 n, n*.5 wait
	BL DELAY1
	

	BIC R1, #0x10
	LDR R0, = GPIO_PORTE_DATA_R ; get Data address again
	STR R1, [R0]
	MOV R3, R9; counter2 
	BL DELAY1
	;delay using R9
	B CHK

;;;;;;;;;;;;;;;
CHK	LDR R0, =GPIO_PORTE_DATA_R
	LDRB R1, [R0] ; load bits 7:0
	AND R1, R1,  #0x08 ; isolate PE3
	LSR R1, R1, #0x03 ; shift to bit 0 to compare later
	CMP R1, #01 ; perform operation where one is subtracted from "check" value
	BPL BRTH


	LDR R2, =GPIO_PORTE_DATA_R ;checking for 2nd button
	LDRB R1, [R0] ; load bits 7:0
	AND R1, R1, #0x01 ; isolate PE0
	CMP R1, #1 ; subtract to see if result is zero, which means it is pressed
	BPL SETFLAG ; if result was zero, then switch was pressed, set flag
;Check for flag, 

	AND R6, R6, #0x01 ;isolating the flag
	CMP R6, #0 ; check flag status
	BNE COMP ;When flag is 1, compare with 900

;if not
	BEQ RUN


;COMP() subtract 900 from R10 to see if result is postive or negative
COMP SUBS R4, R10, #900 
; branch to over if R10 is greater. if branch is not used, then proceed to set the flag in next line
	BPL OVER ;should be bz
	ADD R10, R10, #200
	SUBS R11, R11, #200
	B RUN
	
;;;;;;;;;;;;;;SETFLAG 
SETFLAG ORR R6, #1
	B CHK




	  
     ALIGN      ; make sure the end of this section is aligned
     END        ; end of file

