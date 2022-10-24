; BusyWait.s
; Student names: Daniel Davis and Hyokwon Chung
; Last modification date: 10/22/2022

; Runs on TM4C123
; Use SPI to send an 8-bit code to the LCD.

; As part of Lab 7, students need to implement these outcommand and outdata
; This driver assumes two low-level LCD functions
; this file is in the inc folder so it automatically will be applied to labs 7 8 9 and 10


      EXPORT   SPIOutCommand
      EXPORT   SPIOutData

      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      ALIGN
; Used in ECE319K Labs 7,8,9,10. You write these two functions

; ***********SPIOutCommand*****************
; This is a helper function that sends an 8-bit command to the LCD.
; Inputs: R0 = 32-bit command (number)
;         R1 = 32-bit SPI status register address
;         R2 = 32-bit SPI data register address
;         R3 = 32-bit GPIO port address for D/C
; Outputs: none
; Assumes: SPI and GPIO have already been initialized and enabled
; Note: must be AAPCS compliant
; Note: access to bit 6 of GPIO must be friendly
SPIOutCommand
; --UUU-- Code to write a command to the LCD
;1) Read the SPI status register (R1 has address) and check bit 4, 
;2) If bit 4 is high, loop back to step 1 (wait for BUSY bit to be low)
;3) Clear D/C (GPIO bit 6) to zero, be friendly (R3 has address)
;4) Write the command to the SPI data register (R2 has address)
;5) Read the SPI status register (R1 has address) and check bit 4, 
;6) If bit 4 is high, loop back to step 5 (wait for BUSY bit to be low)
	PUSH {R4-R11, LR}
Step1OutCommand
	LDR R4, [R1] ;Load data from SPI status
	AND R4, #0x10 ;Isolate bit
	CMP R4, #0x10 ;Check bit 4
	BEQ Step1OutCommand  ;If bit 4 is high, loop back
	
	LDR R5, [R3] ;D/C Address data
	AND R5, #0xBF ;Clear the 6th bit
	STR R5, [R3] ;Store D/C data back into address
	
	STR R0, [R2] ;Store the command into SPI Data
	
Step5OutCommand
	LDR R6, [R1] ;Load data from SPI status
	AND R6, #0x10 ;Isolate bit
	CMP R6, #0x10 ;Check bit 4
	BEQ Step5OutCommand ;If bit 4 high, loop back
	POP {R4-R11, LR}
    BX  LR             ;   return



; ***********SPIOutData*****************
; This is a helper function that sends an 8-bit data to the LCD.
; Inputs: R0 = 32-bit data (number)
;         R1 = 32-bit SPI status register address
;         R2 = 32-bit SPI data register address
;         R3 = 32-bit GPIO port address for D/C
; Outputs: none
; Assumes: SPI and GPIO have already been initialized and enabled
; Note: must be AAPCS compliant
; Note: access to bit 6 of GPIO must be friendly
SPIOutData
; --UUU-- Code to write data to the LCD
;1) Read the SPI status register (R1 has address) and check bit 1, 
;2) If bit 1 is low, loop back to step 1 (wait for TNF bit to be high)
;3) Set D/C (GPIO bit 6) to one, be friendly (R3 has address)
;4) Write the data to the SPI data register (R2 has address)
    PUSH {R4-R11, LR}
Step1OutData
	LDR R4, [R1] ;Check data from status register
	AND R4, #0x02 ;Isolate bit
	CMP R4, #0x02 ;Check bit 1
	BNE Step1OutData ;If bit 1 is low then loop back
	
	LDR R5, [R3] ;Get data from D/C address
	ORR R5, #0x40 ;Make bit 6 high
	STR R5, [R3] ;Store data back into D/C address
	
	STR R0, [R2] ;Store the data into the SPI data address
	POP {R4-R11, LR}
    BX  LR             ;return
;****************************************************

    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
