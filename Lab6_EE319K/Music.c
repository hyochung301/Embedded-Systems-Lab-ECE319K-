// Music.c
// playing your favorite song.
//
// For use with the TM4C123
// EE319K lab6 extra credit
// Program written by: Hyokwon Chung and Daniel Davis
// 1/11/22

#include "Sound.h"
#include "../inc/DAC.h"
#include <stdint.h>
#include "../inc/tm4c123gh6pm.h"



void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
void Music_Init(void){uint32_t delay;

}



// Play song, while button pushed or until end
void Music_PlaySong(void){
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	Sound_Start (1000);
	
}

// Stop song
void Music_StopSong(void){
  Sound_Off();
}





