// Key.c
// This software configures the off-board piano keys
// Lab 6 requires a minimum of 4 keys, but you could have more
// Runs on LM4F120 or TM4C123
// Program written by: Hyokwon Chung and Daniel Davis
// Date Created: 3/6/17 
// Last Modified: 10/16/22  
// Lab number: 6
// Hardware connections
// TO STUDENTS "REMOVE THIS LINE AND SPECIFY YOUR HARDWARE********

// Code files contain the actual implemenation for public functions
// this file also contains an private functions and private data
#include <stdint.h>
#include "../inc/tm4c123gh6pm.h"

// **************Key_Init*********************
// Initialize piano key inputs on PA5-2 or PE3-0
// Input: none 
// Output: none
void Key_Init(void){ volatile uint32_t delay;
//initialize your input keys and clock (sysctl)
	SYSCTL_RCGCGPIO_R |= 0x30;
	delay = SYSCTL_RCGCGPIO_R;
	GPIO_PORTE_DIR_R &= ~0x0F;
	GPIO_PORTE_DEN_R |= 0x0F;
	GPIO_PORTF_DIR_R |= 0x0E;
  GPIO_PORTF_DEN_R |= 0x0E;
}
// **************Key_In*********************
// Input from piano key inputs on PA5-2 or PE3-0
// Input: none 
// Output: 0 to 15 depending on keys
//   0x01 is just Key0, 0x02 is just Key1, 0x04 is just Key2, 0x08 is just Key3
uint32_t Key_In(void){ 
//shift key inputs if needed, and them with whatever, and then place them into a value and return that value
  uint32_t KeyData;
	KeyData	= GPIO_PORTE_DATA_R & 0x0F;
	return KeyData;
}

//------------LaunchPad_Init------------
// Initialize Switch input and LED output
// Input: none
// Output: none
void LaunchPad_Init(void){uint32_t delay;
// implement if needed
	SYSCTL_RCGCGPIO_R |= 0x10;
	delay = SYSCTL_RCGCGPIO_R;
	GPIO_PORTE_DIR_R &= ~0x0F;
	GPIO_PORTE_DEN_R |= 0x0F;
}


//------------LaunchPad_Input------------
// Input from Switches, 
// Convert hardware negative logic to software positive logic 
// Input: none
// Output: 0x00 none
//         0x01 SW2 pressed (from PF4)
//         0x02 SW1 pressed (from PF1)
//         0x03 both SW1 and SW2 pressed
uint8_t LaunchPad_Input(void){
// implement if needed
	GPIO_PORTE_DATA_R &= 0x01;
	if (GPIO_PORTE_DATA_R == 0x01){
		return GPIO_PORTE_DATA_R;
	}
	else{
  return 0; // replace
	}
}
//------------LaunchPad__Output------------
// Output to LaunchPad LEDs 
// Positive logic hardware and positive logic software
// Input: 0 off, bit0=red,bit1=blue,bit2=green
// Output: none
void LaunchPad_Output(uint8_t data){  // write three outputs bits of PORTF
// implement if needed

}
