; StringConversion.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on TM4C123
; EE319K lab 7 number to string conversions
;
; Used in ECE319K Labs 7,8,9,10. You write these two functions

 
    EXPORT   Dec2String
    EXPORT   Fix2String
    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB
    PRESERVE8
  
;-----------------------Dec2String-----------------------
; Convert a 32-bit number into unsigned decimal format
; String the string into the empty array add null-termination
; Input: R0 (call by value) 32-bit unsigned number
;        R1 pointer to empty array
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
Dec2String
;R0 IS THE CALLED VALUE
;R1 IS THE ARRAY POINTER TO EMPTY ARRAY, USE AS SUCH
;DO NOT PERM MODIFY R4-R11
	PUSH {R4-R11} ;makes code friendly
;	MOV R0, #15
;	MOV R11, SP
;	SUB SP, #4 ;allocation
;counter EQU 0 ;LOCAL VAR COUNTER
;	MOV R12, #0 ;INDEX
;	MOV R10, #0
;	STR R10, [R11, #counter] ;clearing local var
;	STR R10, [R11, #counter+1] ;clearing local var
;	STR R10, [R11, #counter+2] ;clearing local var
;	STR R10, [R11, #counter+3] ;clearing local var
;Start
;	MOV R2, #10
;	UDIV R3, R0, R2 ;MOD FUNC
;	MUL R4, R3, R2 ;MOD FUNC
;	SUB R4, R0, R4 ;MOD FUNC
;	UDIV R0, R0, R3 ;N=N/10
;	PUSH {R5, R4};PUSH D
;	LDR R6, [R11, #counter] ;load counter value
;	ADD R6, R6, #1 ;increment counter
;	STR R6, [R11, #counter] ;store counter value
;	CMP R0, #0 ;cmp value if its done computing
;	BNE Start 
;PopStart
;	POP {R5, R4} ;pop the first value off the stack (ex: 15, first value will be the 1)
;	ADD R4, R4, #'0'
;	STR R4, [R1] ;storing ascii char into array
;	ADD R1, R1, #4 ;incrementing index
;	LDR R6, [R11, #counter] ;load counter value
;	SUB R6, R6, #1 ;decrement counter
;	STR R6, [R11, #counter] ;store counter value
;	CMP R6, #0 ;check if c is 0
;	BNE PopStart
;	MOV R5, #0
;	STR R5, [R1] ;null end the buff[i]
;	ADD SP, #4 ;deallocate
	
	SUB SP, #4 ;allocation
	ADD R11, SP, #0 ;setting up fp
C EQU 0 ;LOCAL VAR COUNTER
	MOV R10, #0
	;MOV R5, R1 ;KEEP R1 SAFE
	STRB R10, [R11, #C] ;clearing local var
	STRB R10, [R11, #C+1] ;clearing local var
	STRB R10, [R11, #C+2] ;clearing local var
	STRB R10, [R11, #C+3] ;clearing local var
Start
	MOV R3, #10
	UDIV R6, R0, R3 ;MOD FUNC
	MUL R12, R6, R3 ;MOD FUNC
	SUB R12, R0, R12 ;MOD FUNC
	
	UDIV R0, R0, R3 ;n=n/10
	
	PUSH {R9, R12} ;push D
	
	LDRB R4, [R11, #C] ;LOADING R4 WITH LOCAL VAR COUNTER
	ADD R4, R4, #1 ;c=c+1
	STRB R4, [R11, #C]
	CMP R0, #0
	BNE Start
PopStart
	POP{R9, R12} ;r7 = x, pop into x
	ADD R12, R12, #'0' ;x+'0' to make it ascii
	STRB R12,[R1] ;storing into array buf[i]
	ADD R1, R1, #1 ;i=i+1
	LDRB R4, [R11, #C]
	SUB R4, R4, #1 ;SUBTRACTING THE COUNTER
	STRB R4, [R11, #C]
	CMP R4, #0
	BNE PopStart
	
	MOV R5, #0
	STR R5, [R1] ;store 0 into last buf[i]
	
	ADD SP, #4 ;deallocation
	
	POP {R4-R11}
    BX LR
;* * * * * * * * End of Dec2String * * * * * * * *


; -----------------------Fix2String----------------------
; Create characters for LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
;          R1 pointer to empty array
; Outputs: none
; E.g., R0=0,    then create "0.000 "
;       R0=3,    then create "0.003"
;       R0=89,   then create "0.089"
;       R0=123,  then create "0.123"
;       R0=9999, then create "9.999"
;       R0>9999, then create "*.***"
; Invariables: This function must not permanently modify registers R4 to R11
Fix2String
	PUSH {R4-R11}
	SUB SP, #4 ;allocation
	ADD R11, SP, #0 ;setting up fp
NVal EQU 0
	MOV R12, #0 ;Init NVal
	STRB R12, [R11, #NVal] ;init NVal to 0
	STRB R10, [R11, #NVal+1] ;clearing
	STRB R10, [R11, #NVal+2] ;clearing
	STRB R10, [R11, #NVal+3] ;clearing
	
	MOV R2, #9999 
	CMP R0, R2 ;CHECK IF R0>9999, EDGE CASE
	BHI StarSkip
	
	MOV R2, #1000
	UDIV R3, R0, R2 ;D=N/1000
	ADD R3, R3, #'0'
	STRB R3, [R1] ;buf[0] = d + '0'
	ADD R1, R1, #1 ;increment index
	;modulo function
	UDIV R4, R0, R2 ;R4=N/1000
	MUL R5, R4, R2 ;R5=(N/1000)*1000
	SUB R3, R0, R5 ;R3=N-((N/1000)*1000)
	STRH R3, [R11, #NVal]
	
	MOV R12, #'.'
	STRB R12, [R1] ;buf[1] = '.'
	ADD R1, R1, #1
	
	MOV R2, #100
	LDRH R4, [R11, #NVal]
	UDIV R3, R4, R2 ;D=N/100
	ADD R3, R3, #'0'
	STRB R3, [R1] ;buf[2] = d + '0'
	ADD R1, R1, #1 ;increment index
	UDIV R4, R0, R2 ;R4=N/100
	MUL R5, R4, R2 ;R5=(N/100)*100
	SUB R3, R0, R5 ;R3=N-((N/100)*100)
	STRB R3, [R11, #NVal]
	
	MOV R2, #10
	LDRB R4, [R11, #NVal]
	UDIV R3, R4, R2 ;D=N/10
	ADD R3, R3, #'0'
	STRB R3, [R1] ;buf[3] = d + '0'
	ADD R1, R1, #1 ;increment index
	UDIV R4, R0, R2 ;R4=N/10
	MUL R5, R4, R2 ;R5=(N/10)*10
	SUB R3, R0, R5 ;R3=N-((N/10)*10)
	STRB R3, [R11, #NVal]
	
	MOV R2, #1
	LDRB R4, [R11, #NVal]
	UDIV R3, R4, R2 ;D=N/1
	ADD R3, R3, #'0'
	STRB R3, [R1] ;buf[4] = d + '0'
	ADD R1, R1, #1 ;increment index
	UDIV R4, R0, R2 ;R4=N/1
	MUL R5, R4, R2 ;R5=(N/1)*1
	SUB R3, R0, R5 ;R3=N-((N/1)*1)
	STRB R3, [R11, #NVal]
	
	MOV R3, #0x20 ;space
	STRB R3, [R1] ;store space as last value
	ADD R1, R1, #1
	
	MOV R3, #0
	STRB R3, [R1]
	
	B FixDone
	
StarSkip
	MOV R2, #'*'
	STRB R2, [R1]
	ADD R1, R1, #1
	MOV R2, #'.'
	STRB R2, [R1]
	ADD R1, R1, #1
	MOV R2, #'*'
	STRB R2, [R1]
	ADD R1, R1, #1
	MOV R2, #'*'
	STRB R2, [R1]
	ADD R1, R1, #1
	MOV R2, #'*'
	STRB R2, [R1]
	ADD R1, R1, #1
	MOV R2, #0
	STRB R2, [R1]
FixDone
	
	ADD SP, #4 ;deallocate
	POP {R4-R11}

    BX LR


     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
