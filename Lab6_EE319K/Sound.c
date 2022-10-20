// Sound.c
// This module contains the SysTick ISR that plays sound
// Runs on TM4C123
// Program written by: Hyokwon Chung and Daniel Davis
// Date Created: 3/6/17 
// Last Modified: 10/16/22 
// Lab number: 6
// Hardware connections
// TO STUDENTS "REMOVE THIS LINE AND SPECIFY YOUR HARDWARE********

// Code files contain the actual implemenation for public functions
// this file also contains an private functions and private data
#include <stdint.h>
#include "../inc/dac.h"
#include "../inc/tm4c123gh6pm.h"


// **************Sound_Init*********************
// Initialize digital outputs and SysTick timer
// Called once, with sound/interrupts initially off
// Input: none
// Output: none

// Sin wave table, sin index and *Pt defined here
const uint8_t SinWave[64] = {32,35,38,41,44,47,49,52,54,56,58,59,
															61,62,62,63,63,63,62,62,61,59,58,56,
															54,52,49,47,44,41,38,35,32,29,26,23,
															20,17,15,12,10,8,6,5,3,2,2,1,1,1,2,2,
															3,5,6,8,10,12,15,17,20,23,26,29};
uint16_t Index=0;           // Index varies from 0 to 63

void Sound_Init(void){uint32_t period;
//initialize NVIC and dac_init
  DAC_Init();          // Port B is DAC

  Index = 0;

  NVIC_ST_CTRL_R = 0;         // disable SysTick during setup

  NVIC_ST_RELOAD_R = period-1;// reload value

  NVIC_ST_CURRENT_R = 0;      // any write to current clears it

  NVIC_SYS_PRI3_R = (NVIC_SYS_PRI3_R&0x00FFFFFF)|0x20000000; // priority 1

  NVIC_ST_CTRL_R = 0x0007; // enable SysTick with core clock and interrupts
}

// **************Sound_Start*********************
// Start sound output, and set Systick interrupt period 
// Sound continues until Sound_Start called again, or Sound_Off is called
// This function returns right away and sound is produced using a periodic interrupt
// Input: interrupt period
//           Units of period to be determined by YOU
//           Maximum period to be determined by YOU
//           Minimum period to be determined by YOU
//         if period equals zero, disable sound output
// Output: none
void Sound_Start(uint32_t period){
	//check a flag and set NVIC_ST_RELOAD_R to period value passed from main file

	//if (period == 0){
	//NVIC_ST_RELOAD_R = 0;
	//}
	//else {
	NVIC_ST_RELOAD_R = period-1;
	//}
}

// **************Sound_Voice*********************
// Change voice
// EE319K optional
// Input: voice specifies which waveform to play
//           Pointer to wave table
// Output: none
void Sound_Voice(const uint8_t *voice){
  //***NOT NEEDED***
}
// **************Sound_Off*********************
// stop outputing to DAC
// Output: none
void Sound_Off(void){
	NVIC_ST_RELOAD_R = 0;
}
// **************Sound_GetVoice*********************
// Read the current voice
// EE319K optional
// Input: 
// Output: voice specifies which waveform to play
//           Pointer to current wavetable
const uint8_t *Sound_GetVoice(void){
  return 0; // replace
	//***NOT NEEDED***
}
#define PF4 (*((volatile uint32_t *)0x40025040))
#define PF3 (*((volatile uint32_t *)0x40025020))
#define PF2 (*((volatile uint32_t *)0x40025010))
#define PF1 (*((volatile uint32_t *)0x40025008))
#define PF0 (*((volatile uint32_t *)0x40025004))

// Interrupt service routine
// Executed every 12.5ns*(period)
void SysTick_Handler(void){
//set the dac_out to wave[index of sin wave] and then increment to the next element in the wave
	DAC_Out(SinWave[Index]);    // output one value each interrupt
	Index = (Index+1);
	if (Index >63) {
		Index = 0;
	}
}
