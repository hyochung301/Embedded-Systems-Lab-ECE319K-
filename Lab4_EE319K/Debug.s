;****************** Debug.s ***************
; Program written by: **-UUU-*Hyokwon Chung**Garrett Williams***
; Date Created: 09/04/2022
; Last Modified: 09/22/2022

; You may assume your debug functions have exclusive access to SysTick
; However, please make your PortF initialization/access friendly,
; because you have exclusive access to only one of the PortF pins.

; Your Debug_Init should initialize all your debug functionality
; Everyone writes the same version of Debug_ElapsedTime
; Everyone writes Debug_Beat, but the pin to toggle is revealed in the UART window
; There are four possible versions of Debug_Dump. 
; Which version you implement is revealed in the UART window

; ****************Option 0******************
; This is the first of four possible options
; Input: R0 is the data be 8-bit strategic information 
; Output: none
; Dump R0 into an array if this value is different from the previous value
; Please Dump R0 on the first call

; ****************Option 1******************
; This is the second of four possible options
; Input: R0 7-bit strategic information 
; Output: none
; If R0 bit 6 is low, 
; - observe the value in bits 5-0 of R0 (value from 0 to 63): 
;     maintain a histogram recording the number of times each value as occurred
;     since N will be less than 200, no histogram count can exceed the 8-bit 255 maximum,  
; If R0 bit 6 is high,
; - Do nothing

; ****************Option 2******************
; This is the third of four possible options
; Input: R0 is the data be 8-bit strategic information 
; Output: none 
; Dump R0 into an array if R0 bit 6 is low and bit 0 is high

; ****************Option 3******************
; This is the fourth of four possible options
; Input: R0 7-bit strategic information 
; Output: none
; - calculate the absolute value difference between this value and the value at the previous call to Debug_Dump
;     for the first call to Dump_Dump, assume the previous value was 0
;     the differences will range from 0 to 63
;     maintain a histogram recording the number of times each difference as occurred
;     since N will be less than 200, no histogram count can exceed the 8-bit 255 maximum,  


SYSCTL_RCGCGPIO_R  EQU 0x400FE608
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_DEN_R   EQU 0x4002551C
SYSCTL_RCGCTIMER_R EQU 0x400FE604
TIMER2_CFG_R       EQU 0x40032000
TIMER2_TAMR_R      EQU 0x40032004
TIMER2_CTL_R       EQU 0x4003200C
TIMER2_IMR_R       EQU 0x40032018
TIMER2_TAILR_R     EQU 0x40032028
TIMER2_TAPR_R      EQU 0x40032038
TIMER2_TAR_R       EQU 0x40032048

; RAM Area
            AREA    DATA, ALIGN=2
;place your debug variables in RAM here
            EXPORT DumpBuf
            EXPORT Histogram
            EXPORT MinimumTime
            EXPORT MaximumTime         
DumpBuf     SPACE 200 ; 200 8-bit I/O values, your N will be less than 200
Histogram   SPACE 64  ; count of the number of times each value has occured
MinimumTime SPACE 4   ; smallest elapsed time between called to Debug_ElapsedTime
MaximumTime SPACE 4   ; largest elapsed time between called to Debug_ElapsedTime
; you will need additional globals, but do not change the above definitions
NTH			SPACE 172
NST 		SPACE 200
LastTime	SPACE 4
NowTime		SPACE 4
; ROM Area
        EXPORT Debug_Init
        EXPORT Debug_Dump 
        EXPORT Debug_ElapsedTime
        EXPORT Debug_Beat
;-UUU-Import routine(s) from other assembly files (like SysTick.s) here
        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT EID1
EID1    DCB "hc27426",0  ;replace ABC123 with your EID
        EXPORT EID2
EID2    DCB "gaw2322",0  ;replace ABC123 with your EID
;---------------Your code for Lab 4----------------
;Debug initialization for all your debug routines
;This is called once by the Lab4 grader to assign points (if you pass #2 into TExaS_Init
;It is later called at the beginning of the main.s
;for options 0 and 2, place 0xFF into each element of DumpBuf
;for options 1 and 3, place 0 into each element of Histogram
; save all registers (not just R4-R11)
; you will need to initialize global variables, Timer2 and Port F here
Debug_Init 
      PUSH {R0,R1,R2,LR}
	  
      BL   Timer2_Init ;TIMER2_TAR_R is 32-bit down counter
;you write this
      PUSH {R0-R12}
	  
	LDR R0, = SYSCTL_RCGCGPIO_R
	LDRB R1, [R0]
	ORR R1, #0x20 ; enable Port E clock
	STRB R1, [R0]
	NOP
	NOP
	;Define direction(out) output 1(Led)
	LDR R0, =GPIO_PORTF_DIR_R
	LDR R1, [R0]
	ORR R1, #0x02 ; set output bits to 1
	STR R1, [R0] ;
;DIGITAL ENABLE FOR TURNING ON 
	LDR R0, =GPIO_PORTF_DEN_R ;READ
	LDRB R1, [R0]
	ORR R1, #0x02 ;MODIFY TURN ON PF 1
	STRB R1, [R0] ; WRITE

	LDR R0, =NTH
	LDR R1, [R0]
	AND R1, #0x00
	STR R1, [R0]
;filling 0
	LDR R0, =NTH
	LDR R1, [R0]
	AND R1, #0
	STR R1, [R0]
	
	LDR R0, =NST
	LDR R1, [R0]
	AND R1, #0
	STR R1, [R0]
	
	LDR R0, =LastTime
	LDR R1, [R0]
	AND R1, #0
	STR R1, [R0]
	
	LDR R0, =NowTime
	LDR R1, [R0]
	AND R1, #0
	STR R1, [R0]
	
	LDR R0, =MaximumTime
	LDR R1, [R0]
	AND R1, #0
	STR R1, [R0]
	
	LDR R0, =MinimumTime
	LDR R1, [R0]
	ORR R1, #0xFFFFFFFF
	STR R1, [R0]

;putting 0xFF into all the other elements
	MOV R2, #200
	LDR R0, =DumpBuf
NX1	LDR R1, [R0]
	MOV R1, #0xFF
	STRB R1, [R0]
	SUBS R2, #1
	BEQ DINI
	ADD R0, R0, #1
	B NX1
	
	



DINI   POP {R0-R12}
	  
      POP {R0,R1,R2,PC}
    
; There are four possible options: 0,1,2 or 3
; Debug_Dump is called after every output.
; Stop recording and measuring after N observations
; Don't stop after N calls to Debug_Dump, but stop after N changes to your data structures
; N will be revealed to you in the UART window)
; Save all registers (not just R4-R11)

Debug_Dump
	PUSH {R0-R4,LR}
	PUSH {R0-R12}
;you write this
;assume capture is called about every 2.5ms (real board)
;Let M = number of instructions in your Debug_Dump
;Calculate T = M instructions * 2cycles/instruction * 12.5ns/cycle 
;Calculate intrusiveness is T/2.5ms = ???

		
	LDR R6, =NST; Getting the NST(Global counter of Nth stored.)
		LDR R7, [R6] ; get the NST (how many times it has been stored)
		MOV R3, #172 ; Set counter for comparison in R3
		CMP R7, R3 ; Skip dump if 172 has been stored. 
		BEQ DUSKIP ; skip dump
		; proceed to dump if branch is not taken
		MOV R1, R0
		BIC R1, #0xBE ; Isolate bits 0 and 6 ; 
		

		
		;Compare R0 bits with R1 bits
		CMP R1, #0x01 ; determine if the value is odd
		BNE DUSKIP ; branch to end of dump if not odd
		
		LDR R4, =DumpBuf ; load DumpBuf2 array into register
	
		ADD R4, R4, R7 ; Get the Nth value of the array 
		STRB R0, [R4] ;Store the value of the Nth variable 
		ADD R7, R7, #0x01 ; increment counter for how many times it has been stored
		STR R7, [R6]
		; end of dump, proceed to pop
	
DUSKIP 	POP {R0-R12}
      		POP {R0-R4,PC}
		


; Your Debug_ElapsedTime is called after every output.
; Input: none 
; Output: none
; - observe the current time as a 32-bit unsigned integer: 
;     NowTime = TIMER2_TAR
; - Starting with the second call you will be able to measure elapsed time:
;     calcalate ElapsedTime = LastTime-NowTime (down counter)
;     determine the Minimum and Maximum ElapsedTime
; - Set LastTime = NowTime (value needed for next call)
; - Stop recording after N calls (N revealed to you in the UART window)
; save all registers (not just R4-R11)
Debug_ElapsedTime 
      PUSH {R0-R4,LR}
	  PUSH {R0-R12}
	  
	  ;Check for NTH (N - #time it has bveen called)
	  LDR R0, =NTH
	  LDR R5, [R0] ;Check how many times it has been called
	  CMP R5, #0 ; Check if it is the first time
	  BNE NOTZ
	  ;If it is the first time, 
	  
	  B DT
	  
NOTZ	  SUBS R6, R5, #172
	  BHS DT ; if it has been called Nth time, skip the whole Elapsed Time
	  
      LDR R0, =TIMER2_TAR_R ;call the current time
	  LDR R1, [R0] ;NowTime
	  
	
MIN	  

	LDR R0, =LastTime
	LDR R3, [R0]
	SUBS R7, R3, R1 ; current elapsed time
	;Current minimum time
	LDR R4, =MinimumTime
	LDR R5, [R4]


	  ;if not, compare
CALMIN
	CMP R7, R5; Current Elapsed - Previous min
	BHS MAX
	STR R7, [R4] ; if current elapsed is smaller, save to Minimum
	
	
	  ;current elapsed - current, min = current if negative (skip when positive or equal)

	  ;check if the current time is max ;R7 Current Elapsed, R1 Curren time
MAX	  LDR R0, =MaximumTime
	  LDR R5, [R0]
	  CMP R5, R7 ;Current - previous max
	  ;max = current if positive (MIN when negative or equal)
	  BHI DT
	  STR R7, [R0]
	  B DT
	  
DT	LDR R0, =TIMER2_TAR_R
	LDR R1, [R0]
	  LDR R0, =LastTime
	  STR R1, [R0];Store now time to Last time	  
		LDR R0, =NTH
	  LDR R5, [R0];
	  ADD R5, R5, #1 ;Increment NTH by 1
	  STR R5,[R0] 
	  
	  ;Save Current time to Previous time

	  POP {R0-R12}
      POP {R0-R4,PC}
    
; Your Debug_Beat function is called every time through the main loop to
; indicate to the operator if the main program is running (not stuck or dead).
; Inputs: none
; Outputs: none
; However, slow down the flashing so the LED flashes at about 1 Hz. goal
; 1Hz means repeating: high for 500ms, low for 500ms
; Basically, toggle an LED every Mth call to your Debug_Beat 
; Find the constant M, so the flashing rate is between 0.5 and 2 Hz. - allowed
; The Port F pin you need to use will be revealed to you in the UART window.
; Save all registers (not AAPCS) 
Debug_Beat
	  
	PUSH {R0-R2,LR}
	PUSH {R0-R12}
	;check the counter
	LDR R0, =NTH
	LDR R1, [R0]
	MOV R3, #400
	UDIV R2, R1, R3 ; R2 is NTH/400
	MLS R3, R2, R3, R1 ; R3 is the remainder
	CMP R3, #0
	BNE NOBL
	  ;every 400th time BEAT it is called, toggle
	LDR R0, =GPIO_PORTF_DATA_R
	LDR R2, [R0]
	EOR R2, R2, #0x02
	STR R2, [R0]
	  
;implement flashing
NOBL
	POP {R0-R12}
	  POP  {R0-R2,PC}



;------------Timer2_Init------------
; This subroutine is functional and does not need editing
; Initialize Timer2 running at bus clock.
; Make it so TIMER2_TAR can be used as a 32-bit time
; TIMER2_TAR counts down continuously
; Input: none
; Output: none
; Modifies: R0,R1
Timer2_Init
    LDR R1,=SYSCTL_RCGCTIMER_R
    LDR R0,[R1]
    ORR R0,R0,#0x04
    STR R0,[R1]    ; activate TIMER2
    NOP
    NOP
    LDR R1,=TIMER2_CTL_R
    MOV R0,#0x00
    STR R0,[R1]    ; disable TIMER2A during setup
    LDR R1,=TIMER2_CFG_R
    STR R0,[R1]    ; configure for 32-bit mode
    LDR R1,=TIMER2_TAMR_R
    MOV R0,#0x02
    STR R0,[R1]    ; configure for periodic mode, default down-count settings
    LDR R1,=TIMER2_TAILR_R
    LDR R0,=0xFFFFFFFE
    STR R0,[R1]    ; reload value
    LDR R1,=TIMER2_TAPR_R
    MOV R0,#0x00
    STR R0,[R1]    ; no prescale, bus clock resolution
    LDR R1,=TIMER2_IMR_R
    MOV R0,#0x00
    STR R0,[R1]    ; no interrupts
    LDR R1,=TIMER2_CTL_R
    MOV R0,#0x01
    STR R0,[R1]    ; enable TIMER2A
    BX  LR          
  
    ALIGN      ; make sure the end of this section is aligned
    END        ; end of file

































;****************** Debug.s ***************
; Program written by: **-UUU-*Hyokwon Chung**Garrett Williams***
; Date Created: 09/04/2022
; Last Modified: 09/22/2022

; You may assume your debug functions have exclusive access to SysTick
; However, please make your PortF initialization/access friendly,
; because you have exclusive access to only one of the PortF pins.

; Your Debug_Init should initialize all your debug functionality
; Everyone writes the same version of Debug_ElapsedTime
; Everyone writes Debug_Beat, but the pin to toggle is revealed in the UART window
; There are four possible versions of Debug_Dump. 
; Which version you implement is revealed in the UART window

; ****************Option 0******************
; This is the first of four possible options
; Input: R0 is the data be 8-bit strategic information 
; Output: none
; Dump R0 into an array if this value is different from the previous value
; Please Dump R0 on the first call

; ****************Option 1******************
; This is the second of four possible options
; Input: R0 7-bit strategic information 
; Output: none
; If R0 bit 6 is low, 
; - observe the value in bits 5-0 of R0 (value from 0 to 63): 
;     maintain a histogram recording the number of times each value as occurred
;     since N will be less than 200, no histogram count can exceed the 8-bit 255 maximum,  
; If R0 bit 6 is high,
; - Do nothing

; ****************Option 2******************
; This is the third of four possible options
; Input: R0 is the data be 8-bit strategic information 
; Output: none 
; Dump R0 into an array if R0 bit 6 is low and bit 0 is high

; ****************Option 3******************
; This is the fourth of four possible options
; Input: R0 7-bit strategic information 
; Output: none
; - calculate the absolute value difference between this value and the value at the previous call to Debug_Dump
;     for the first call to Dump_Dump, assume the previous value was 0
;     the differences will range from 0 to 63
;     maintain a histogram recording the number of times each difference as occurred
;     since N will be less than 200, no histogram count can exceed the 8-bit 255 maximum,  


SYSCTL_RCGCGPIO_R  EQU 0x400FE608
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_DEN_R   EQU 0x4002551C
SYSCTL_RCGCTIMER_R EQU 0x400FE604
TIMER2_CFG_R       EQU 0x40032000
TIMER2_TAMR_R      EQU 0x40032004
TIMER2_CTL_R       EQU 0x4003200C
TIMER2_IMR_R       EQU 0x40032018
TIMER2_TAILR_R     EQU 0x40032028
TIMER2_TAPR_R      EQU 0x40032038
TIMER2_TAR_R       EQU 0x40032048

; RAM Area
            AREA    DATA, ALIGN=2
;place your debug variables in RAM here
            EXPORT DumpBuf
            EXPORT Histogram
            EXPORT MinimumTime
            EXPORT MaximumTime         
DumpBuf     SPACE 200 ; 200 8-bit I/O values, your N will be less than 200
Histogram   SPACE 64  ; count of the number of times each value has occured
MinimumTime SPACE 4   ; smallest elapsed time between called to Debug_ElapsedTime
MaximumTime SPACE 4   ; largest elapsed time between called to Debug_ElapsedTime
; you will need additional globals, but do not change the above definitions
NTH			SPACE 4
NST 		SPACE 4
LastTime	SPACE 4
NowTime		SPACE 4
; ROM Area
        EXPORT Debug_Init
        EXPORT Debug_Dump 
        EXPORT Debug_ElapsedTime
        EXPORT Debug_Beat
;-UUU-Import routine(s) from other assembly files (like SysTick.s) here
        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT EID1
EID1    DCB "hc27426",0  ;replace ABC123 with your EID
        EXPORT EID2
EID2    DCB "gaw2322",0  ;replace ABC123 with your EID
;---------------Your code for Lab 4----------------
;Debug initialization for all your debug routines
;This is called once by the Lab4 grader to assign points (if you pass #2 into TExaS_Init
;It is later called at the beginning of the main.s
;for options 0 and 2, place 0xFF into each element of DumpBuf
;for options 1 and 3, place 0 into each element of Histogram
; save all registers (not just R4-R11)
; you will need to initialize global variables, Timer2 and Port F here
Debug_Init 
      PUSH {R0,R1,R2,LR}
	  
      BL   Timer2_Init ;TIMER2_TAR_R is 32-bit down counter
;you write this
      PUSH {R0-R12}
	  
	LDR R0, = SYSCTL_RCGCGPIO_R
	LDRB R1, [R0]
	ORR R1, #0x20 ; enable Port E clock
	STRB R1, [R0]
	NOP
	NOP
	;Define direction(out) output 1(Led)
	LDR R0, =GPIO_PORTF_DIR_R
	LDR R1, [R0]
	ORR R1, #0x02 ; set output bits to 1
	STR R1, [R0] ;
;DIGITAL ENABLE FOR TURNING ON 
	LDR R0, =GPIO_PORTF_DEN_R ;READ
	LDRB R1, [R0]
	ORR R1, #0x02 ;MODIFY TURN ON PF 1
	STRB R1, [R0] ; WRITE

	LDR R0, =NTH
	LDR R1, [R0]
	AND R1, #0x00
	STR R1, [R0]
;filling 0
	LDR R0, =NTH
	LDR R1, [R0]
	AND R1, #0
	STR R1, [R0]
	
	LDR R0, =NST
	LDR R1, [R0]
	AND R1, #0
	STR R1, [R0]
	
	LDR R0, =LastTime
	LDR R1, [R0]
	AND R1, #0
	STR R1, [R0]
	
	LDR R0, =NowTime
	LDR R1, [R0]
	AND R1, #0
	STR R1, [R0]

;putting 0xFF into all the other elements
	MOV R2, #200
	LDR R0, =DumpBuf
NX1	LDR R1, [R0]
	MOV R1, #0xFF
	STRB R1, [R0]
	SUBS R2, #1
	BEQ DINI
	ADD R0, R0, #1
	B NX1
	
	



DINI   POP {R0-R12}
	  
      POP {R0,R1,R2,PC}
    
; There are four possible options: 0,1,2 or 3
; Debug_Dump is called after every output.
; Stop recording and measuring after N observations
; Don't stop after N calls to Debug_Dump, but stop after N changes to your data structures
; N will be revealed to you in the UART window)
; Save all registers (not just R4-R11)

Debug_Dump
	PUSH {R0-R4,LR}
	PUSH {R0-R12}
;you write this
;assume capture is called about every 2.5ms (real board)
;Let M = number of instructions in your Debug_Dump
;Calculate T = M instructions * 2cycles/instruction * 12.5ns/cycle 
;Calculate intrusiveness is T/2.5ms = ???

		
	LDR R6, =NST; Getting the NST(Global counter of Nth stored.)
		LDR R7, [R6] ; get the NST (how many times it has been stored)
		MOV R3, #172 ; Set counter for comparison in R3
		CMP R7, R3 ; Skip dump if 172 has been stored. 
		BEQ DUSKIP ; skip dump
		; proceed to dump if branch is not taken
		MOV R1, R0
		BIC R1, #0xBE ; Isolate bits 0 and 6 ; 
		

		
		;Compare R0 bits with R1 bits
		CMP R1, #0x01 ; determine if the value is odd
		BNE DUSKIP ; branch to end of dump if not odd
		
		LDR R4, =DumpBuf ; load DumpBuf2 array into register
	
		ADD R4, R4, R7 ; Get the Nth value of the array 
		STRB R0, [R4] ;Store the value of the Nth variable 
		ADD R7, R7, #0x01 ; increment counter for how many times it has been stored
		STR R7, [R6]
		; end of dump, proceed to pop
	
DUSKIP 	POP {R0-R12}
      		POP {R0-R4,PC}
		


; Your Debug_ElapsedTime is called after every output.
; Input: none 
; Output: none
; - observe the current time as a 32-bit unsigned integer: 
;     NowTime = TIMER2_TAR
; - Starting with the second call you will be able to measure elapsed time:
;     calcalate ElapsedTime = LastTime-NowTime (down counter)
;     determine the Minimum and Maximum ElapsedTime
; - Set LastTime = NowTime (value needed for next call)
; - Stop recording after N calls (N revealed to you in the UART window)
; save all registers (not just R4-R11)
Debug_ElapsedTime 
      PUSH {R0-R4,LR}
	  PUSH {R0-R12}
	  
	  ;Check for NTH (N - #time it has bveen called)
	  LDR R0, =NTH
	  LDR R5, [R0] ;Check how many times it has been called
	  CMP R5, #0 ; Check if it is the first time
	  BNE NOTZ
	  ;If it is the first time, 
	  
	  B DT
	  
NOTZ	  SUBS R6, R5, #172
	  BHS DT ; if it has been called Nth time, skip the whole Elapsed Time
	  
      LDR R0, =TIMER2_TAR_R ;call the current time
	  LDR R1, [R0] ;NowTime
	  
	
MIN	  

	LDR R0, =LastTime
	LDR R3, [R0]
	SUBS R7, R3, R1 ; current elapsed time
	;Current minimum time
	LDR R4, =MinimumTime
	LDR R5, [R4]

	  ;if not, compare
CALMIN
	CMP R7, R5; Current Elapsed - Previous min
	BHS MAX
	STR R7, [R4] ; if current elapsed is smaller, save to Minimum
	
	
	  ;current elapsed - current, min = current if negative (skip when positive or equal)

	  ;check if the current time is max ;R7 Current Elapsed, R1 Curren time
MAX	  LDR R0, =MaximumTime
	  LDR R5, [R0]
	  CMP R5, R7 ;Current - previous max
	  ;max = current if positive (MIN when negative or equal)
	  BHI DT
	  STR R7, [R0]
	  B DT
	  
DT	LDR R0, =TIMER2_TAR_R
	LDR R1, [R0]
	  LDR R0, =LastTime
	  STR R1, [R0];Store now time to Last time	  
		LDR R0, =NTH
	  LDR R5, [R0];
	  ADD R5, R5, #1 ;Increment NTH by 1
	  STR R5,[R0] 
	  
	  ;Save Current time to Previous time

	  POP {R0-R12}
      POP {R0-R4,PC}
    
; Your Debug_Beat function is called every time through the main loop to
; indicate to the operator if the main program is running (not stuck or dead).
; Inputs: none
; Outputs: none
; However, slow down the flashing so the LED flashes at about 1 Hz. goal
; 1Hz means repeating: high for 500ms, low for 500ms
; Basically, toggle an LED every Mth call to your Debug_Beat 
; Find the constant M, so the flashing rate is between 0.5 and 2 Hz. - allowed
; The Port F pin you need to use will be revealed to you in the UART window.
; Save all registers (not AAPCS) 
Debug_Beat
	  
	PUSH {R0-R2,LR}
	PUSH {R0-R12}
	;check the counter
	LDR R0, =NTH
	LDR R1, [R0]
	MOV R3, #400
	UDIV R2, R1, R3 ; R2 is NTH/400
	MLS R3, R2, R3, R1 ; R3 is the remainder
	CMP R3, #0
	BNE NOBL
	  ;every 400th time BEAT it is called, toggle
	LDR R0, =GPIO_PORTF_DATA_R
	LDR R2, [R0]
	EOR R2, R2, #0x02
	STR R2, [R0]
	  
;implement flashing
NOBL
	POP {R0-R12}
	  POP  {R0-R2,PC}



;------------Timer2_Init------------
; This subroutine is functional and does not need editing
; Initialize Timer2 running at bus clock.
; Make it so TIMER2_TAR can be used as a 32-bit time
; TIMER2_TAR counts down continuously
; Input: none
; Output: none
; Modifies: R0,R1
Timer2_Init
    LDR R1,=SYSCTL_RCGCTIMER_R
    LDR R0,[R1]
    ORR R0,R0,#0x04
    STR R0,[R1]    ; activate TIMER2
    NOP
    NOP
    LDR R1,=TIMER2_CTL_R
    MOV R0,#0x00
    STR R0,[R1]    ; disable TIMER2A during setup
    LDR R1,=TIMER2_CFG_R
    STR R0,[R1]    ; configure for 32-bit mode
    LDR R1,=TIMER2_TAMR_R
    MOV R0,#0x02
    STR R0,[R1]    ; configure for periodic mode, default down-count settings
    LDR R1,=TIMER2_TAILR_R
    LDR R0,=0xFFFFFFFE
    STR R0,[R1]    ; reload value
    LDR R1,=TIMER2_TAPR_R
    MOV R0,#0x00
    STR R0,[R1]    ; no prescale, bus clock resolution
    LDR R1,=TIMER2_IMR_R
    MOV R0,#0x00
    STR R0,[R1]    ; no interrupts
    LDR R1,=TIMER2_CTL_R
    MOV R0,#0x01
    STR R0,[R1]    ; enable TIMER2A
    BX  LR          
  
    ALIGN      ; make sure the end of this section is aligned
    END        ; end of file










