// IO.c
// This software configures the switch and LED
// You are allowed to use any switch and any LED, 
// although the Lab suggests the SW1 switch PF4 and Red LED PF1
// Runs on TM4C123
// Program written by: Daniel Davis and Hyokwon Chung
// Date Created: 
// Last Modified:  October 22, 2022
// Lab number: 7


#include "../inc/tm4c123gh6pm.h"
#include <stdint.h>


void Wait10ms(uint32_t);

//------------IO_Init------------
// Initialize GPIO Port for a switch and an LED
// Input: none
// Output: none
void IO_Init(void) { volatile uint32_t delay;
 // --UUU-- Code to initialize PF4 (switch) and PF2 (led) and pull up register (GPIO_PORTF_PUR_R)
	SYSCTL_RCGCGPIO_R |= 0x20;
	delay = SYSCTL_RCGCGPIO_R;
	GPIO_PORTF_DIR_R &= ~0x10;
	GPIO_PORTF_DIR_R |= 0x04;
  GPIO_PORTF_DEN_R |= 0x14;
	GPIO_PORTF_PUR_R |= 0x11;
}

//------------IO_HeartBeat------------
// Toggle the output state of the  LED.
// Input: none
// Output: none
void IO_HeartBeat(void) {
 // --UUU-- PF2 is heartbeat
	GPIO_PORTF_DATA_R ^= 0x04;
}


//------------IO_Touch------------
// wait for release and press of the switch
// Input: none
// Output: none
void IO_Touch(void) {
 // --UUU-- wait for release; delay for 20ms; and then wait for press
	while ((GPIO_PORTF_DATA_R & 0x11) != 0x10){
	}
	Wait10ms(2);
	while ((GPIO_PORTF_DATA_R & 0x11) == 0x10){
	}
}  

//Must really wait for 10ms x count
void Wait10ms(uint32_t count){
  uint32_t i;
  for(i=0; i <count*32000; i++){}
}
