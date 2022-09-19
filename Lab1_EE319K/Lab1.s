;****************** Lab1.s ***************
; Program initially written by: Yerraballi and Valvano
; Author: Place your name here
; Date Created: 1/15/2018 
; Last Modified: 8/21/2022
; Brief description of the program: Solution to Lab1
; The objective of this system is to implement a parity system
; Hardware connections: 
;  One output is positive logic, 1 turns on the LED, 0 turns off the LED
;  Three inputs are positive logic, meaning switch not pressed is 0, pressed is 1
GPIO_PORTD_DATA_R  EQU 0x400073FC
GPIO_PORTD_DIR_R   EQU 0x40007400
GPIO_PORTD_DEN_R   EQU 0x4000751C
GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_DEN_R   EQU 0x4002451C
SYSCTL_RCGCGPIO_R  EQU 0x400FE608
       PRESERVE8 
       AREA   Data, ALIGN=2
;Put following in RAM, aligned to 32-bits
; No global variables needed for Lab 1

       
       AREA    |.text|, CODE, READONLY, ALIGN=2
;Put following in ROM, aligned to 32-bits 
       THUMB
       EXPORT EID
EID    DCB "hc27426",0  ;replace abc123 with your EID
       EXPORT RunGrader
       ALIGN 4
RunGrader DCD 1 ; change to nonzero when ready for grading
           
      EXPORT  Lab1
Lab1 
;Initializations
	;clock
	LDR R0, = SYSCTL_RCGCGPIO_R
	LDRB R1, [R0]
	ORR R1, #0x08
	STRB R1, [R0]
	NOP
	NOP
	;Define direction(in and out) 
	LDR R0, =GPIO_PORTD_DIR_R
	LDR R1, [R0]
	; ;CLEAR R1 TO FILL 1'S EXCEPT NEEDED PLACES MOV VS AND FOR THIS, POSSIBLY TWO WAYS OF DOING IT?
	BIC R1, #0x07
	ORR R1, #0x20
	STR R1, [R0] ;STORING MODIFIED R1 VALUE INTO ORIGINAL DIR LOCATION WHICH IS IN @R0 
	;DIGITAL ENABLE FOR TURNING ON 
	LDR R0, =GPIO_PORTD_DEN_R ;READ
	LDRB R1, [R0]
	ORR R1, #0X27 ;MODIFY TURN ON PD 0 1 2 5
	STRB R1, [R0] ;WRITE
loop
;input, calculate, output    
	LDR R0, =GPIO_PORTD_DATA_R ;READ PORTD CONTENT'S ADDRESS
	LDR R1, [R0]
	AND R3, R1, #0X01 ;ISOLATE PD0 -> R3
	AND R4, R1, #0X02;ISOLATE PD1 -> R4
	AND R5, R1, #0X04;ISOLATE PD2 -> R5
	LSR R4, R4, #1 ;SHIFT RIGHT 1BIT USING SHIFT OPERATION (LSL LSR)
	LSR R5, R5, #2 ;SHIFT RIGHT 2BIT
	;FOR INPUT PINS, PERFORM EOR TO DETERMINE OUTPUT VALUE
	EOR R3, R3, R4 ;EOR RD2, PD1 
	EOR R3, R3, R5 ;EOR PD(21) AND PD(3)
	LSL R3, R3, #5 ;SHIFT LEFT 5 BIT 
	;ORR R1, R1, R3 ;WRITE PUT R3 VALUE INTO BIT5 OF PORTD
	STR R3, [R0]; STORE IT BACK
	
    B    loop


    
    ALIGN        ; make sure the end of this section is aligned
    END          ; end of file
               