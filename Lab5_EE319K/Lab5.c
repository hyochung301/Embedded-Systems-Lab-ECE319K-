// Lab5.c starter program EE319K Lab 5, Fall 2022
// Runs on TM4C123
// Daniel Davis and Hyokwon Chung
// Last Modified: 10/8/2022

/* Option A1, connect LEDs to PB5-PB0, switches to PA5-3, walk LED PF321
   Option A2, connect LEDs to PB5-PB0, switches to PA4-2, walk LED PF321
   Option A6, connect LEDs to PB5-PB0, switches to PE3-1, walk LED PF321
   Option A5, connect LEDs to PB5-PB0, switches to PE2-0, walk LED PF321
   Option B4, connect LEDs to PE5-PE0, switches to PC7-5, walk LED PF321
   Option B3, connect LEDs to PE5-PE0, switches to PC6-4, walk LED PF321
   Option B1, connect LEDs to PE5-PE0, switches to PA5-3, walk LED PF321
   Option B2, connect LEDs to PE5-PE0, switches to PA4-2, walk LED PF321
  */
// east/west red light connected to bit 5
// east/west yellow light connected to bit 4
// east/west green light connected to bit 3
// north/south red light connected to bit 2
// north/south yellow light connected to bit 1
// north/south green light connected to bit 0
// pedestrian detector connected to most significant bit (1=pedestrian present)
// north/south car detector connected to middle bit (1=car present)
// east/west car detector connected to least significant bit (1=car present)
// "walk" light connected to PF3-1 (built-in white LED)
// "don't walk" light connected to PF3-1 (built-in red LED)
#include <stdint.h>
#include "SysTick.h"
#include "Lab5grader.h"
#include "../inc/tm4c123gh6pm.h"
// put both EIDs in the next two lines
char EID1[] = "DND663"; //  ;replace abc123 with your EID
char EID2[] = "HC27426"; //  ;replace abc123 with your EID

void DisableInterrupts(void);
void EnableInterrupts(void);
//struct goes here
struct state{
    uint32_t PortE_Val;
    uint32_t PortF_Val;
    uint32_t Wait;
    uint32_t Next[8];
};

typedef const struct state state_t;
#define allred 0
#define goS 1
#define waitS 2
#define allredS 3
#define goW 4
#define waitW 5
#define allredW 6
#define goP 7
#define redP1 8
#define offP1 9
#define redP2 10
#define offP2 11
#define redP3 12
#define offP3 13
#define stopP 14
state_t FSM[15] = {
	{0x24,0x02,50, {allred, goW, goS, goS, goP, goP, goS, goS}}, //0
	{0x21,0x02,50, {waitS, waitS, goS, waitS, waitS, waitS, waitS, waitS}}, //1
	{0x22,0x02,50, {allredS, allredS, allredS, allredS, allredS, allredS, allredS, allredS}}, //2
	{0x24,0x02,50, {goP, goW, goS, goW, goP, goP, goP, goP}}, //3
	{0x0C,0x02,50, {waitW, goW, waitW, waitW, waitW, waitW, waitW, waitW}}, //4
	{0x14,0x02,50, {allredW, allredW, allredW, allredW, allredW, allredW, allredW, allredW}}, //5
	{0x24,0x02,50, {goS, goW, goS, goS, goP, goP, goS, goS}}, //6
	{0x24,0x0E,50, {redP1, redP1, redP1, redP1, goP, redP1, redP1, redP1}}, //7
	{0x24,0x02,50, {offP1, offP1, offP1, offP1, offP1, offP1, offP1, offP1}}, //8
	{0x24,0x00,50, {redP2, redP2, redP2, redP2, redP2, redP2, redP2, redP2}}, //9
	{0x24,0x02,50, {offP2, offP2, offP2, offP2, offP2, offP2, offP2, offP2}}, //10
	{0x24,0x00,50, {redP3, redP3, redP3, redP3, redP3, redP3, redP3, redP3}}, //11
	{0x24,0x02,50, {offP3, offP3, offP3, offP3, offP3, offP3, offP3, offP3}}, //12
	{0x24,0x00,50, {stopP, stopP, stopP, stopP, stopP, stopP, stopP, stopP}}, //13
	{0x24,0x02,50, {goW, goW, goS, goS, goP, goW, goS, goW}}, //14

};
uint32_t S; //index current state
uint32_t input;
int main(void){ volatile uint32_t delay;
  DisableInterrupts();
  TExaS_Init(5);
  SysTick_Init();   // Initialize SysTick for software waits
  // initialize system
	SYSCTL_RCGCGPIO_R |= 0x31;

	delay = SYSCTL_RCGCGPIO_R;
	
	GPIO_PORTA_DIR_R &= ~0x1C;

  GPIO_PORTA_DEN_R |= 0x1C;
	
  GPIO_PORTE_DIR_R |= 0x3F;

  GPIO_PORTE_DEN_R |= 0x3F;

  GPIO_PORTF_DIR_R |= 0x0E; 

  GPIO_PORTF_DEN_R |= 0x0E;
	
  EnableInterrupts(); 
	S = allred;
  while(1){

		GPIO_PORTE_DATA_R = (GPIO_PORTE_DATA_R&0xC0)|FSM[S].PortE_Val;    // 1) output
		GPIO_PORTF_DATA_R = (GPIO_PORTF_DATA_R&0xF1)|FSM[S].PortF_Val;
		SysTick_Wait10ms(FSM[S].Wait);    // 2) wait
    input = (GPIO_PORTA_DATA_R&0x1C)>>2;      // 3) input // read sensors
    S = FSM[S].Next[input];     // 4) next

  }
}




