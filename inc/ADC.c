// ADC.c
// Runs on TM4C123
// Provide functions that initialize ADC0
// Last Modified: 8/24/2022  
// Student names: change this to your names or look very silly
// Last modification date: change this to the last modification date or look very silly
// Labs 8, 9, and 10 specify PD2
#include <stdint.h>
#include "../inc/tm4c123gh6pm.h"

// ADC initialization function using PD2 
// Input: none
// Output: none
void ADC_Init(void){ 
// write this
}
//------------ADC_In------------
// Busy-wait Analog to digital conversion
// Input: none
// Output: 12-bit result of ADC conversion
// measures from PD2, analog channel 5
uint32_t ADC_In(void){  
	// 1) initiate SS3
  // 2) wait for conversion done
  // 3) read result
  // 4) acknowledge completion
  return 0;
}


