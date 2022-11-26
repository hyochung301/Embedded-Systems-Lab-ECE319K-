// UART1.c
// Runs on LM4F120/TM4C123
// Use UART1 to implement bidirectional data transfer to and from 
// another microcontroller in Lab 9.  This time, interrupts and FIFOs
// are used.
// Daniel Valvano
// 8/24/2022

/* Lab solution, Do not post
 http://users.ece.utexas.edu/~valvano/
*/

// U1Rx (VCP receive) connected to PC4
// U1Tx (VCP transmit) connected to PC5
#include <stdint.h>
#include "Fifo.h"
#include "UART1.h"
#include "../inc/tm4c123gh6pm.h"


#define CR  0x0D


// Initialize UART1
// Baud rate is 1000 bits/sec
void UART1_Init(void){
	SYSCTL_RCGCUART_R |= 0x02; 
	SYSCTL_RCGCGPIO_R |= 0x0004;
	while((SYSCTL_PRGPIO_R&0x04) == 0){};
	UART1_CTL_R &= ~0x001;
	UART1_IBRD_R = 2500;
	UART1_FBRD_R = 0;
	UART1_LCRH_R = 0x0070; //this could be 0
	UART1_IM_R |= 0x10;// turn on RTRIS
	UART1_CTL_R |= 0x0301;
	GPIO_PORTC_AFSEL_R |= 0x30;// turn on function on PC5 and PC4 (FRIENDLY)
	GPIO_PORTC_PCTL_R = (GPIO_PORTC_PCTL_R & 0xFF00FFFF) +0x220000;
	GPIO_PORTC_DEN_R |= 0x30; //enable PC4 and PC5 (FRIENDLY)
	GPIO_PORTC_AMSEL_R &= ~0x30; //take out or turn off analog on PC4 and PC5 (FRIENDLY)
	NVIC_PRI1_R = (NVIC_PRI1_R & 0xFFFF00FF) | 0x04000;
	NVIC_EN0_R |= 0x40;

}

//------------UART1_InChar------------
// Wait for new input, interrupt driven
// Use your FIFO
// then return ASCII code
// Input: none
// Output: char read from UART
char UART_InChar(void){

  while((UART1_FR_R&0x0010) != 0);      // wait until RXFE is 0

  return((char)(UART1_DR_R&0xFF));
}
//------------UART1_InMessage------------
// Accepts ASCII characters from the serial port
//    and adds them to a string until > is typed
//    or until max length of the string is reached.
// Input: pointer to empty buffer of 8 characters
// Output: Null terminated string
void UART1_InMessage(char *bufPt){
  // write this
	// 
	//DO NOT IMPLEMENT
}
//------------UART1_OutChar------------
// Output 8-bit to serial port
// Do not use interrupts or FIFO, use busy wait
// Input: letter is an 8-bit ASCII character to be transferred
// Output: none
void UART1_OutChar(char data){
  // write this
  while((UART1_FR_R&UART_FR_TXFF) != 0);
  UART1_DR_R = data;
}
#define PF1       (*((volatile uint32_t *)0x40025008))
#define PF2       (*((volatile uint32_t *)0x40025010))
#define PF3       (*((volatile uint32_t *)0x40025020))
// UART1 receiver has timed out
// Use your FIFO
	uint32_t RxCounter = 0;
void UART1_Handler(void){char letter;
  PF2 ^= 0x04;  // Heartbeat
// write this
//toggle a heartbeat (change from 0 to 1, or from 1 to 0), 
//as long as the RXFE bit in the UART1_FR_R is zero (should be exactly 8 bytes, but could be more or less)(while loop, 8 times)
//Read a byte from UART1_DR_R 
//Put the byte into your software FIFO 
//Increment a RxCounter, used as debugging monitor of the number of UART messages received
//acknowledge the interrupt by clearing the flag which requested the interrupt 
//UART1_ICR_R = 0x40;   // this clears bit 6 (RTRIS) in the RIS register
//return from interrupt
while(UART1_FR_R == 0){
	Fifo_Put(UART1_DR_R);
}
	RxCounter++;
	UART1_ICR_R = 0x40;
}

//------------UART1_OutString------------
// Output String (NULL termination)
// Input: pointer to a NULL-terminated string to be transferred
// Output: none
void UART1_OutString(char *pt){
  while(*pt){
    UART1_OutChar(*pt);
    pt++;
  }
}



