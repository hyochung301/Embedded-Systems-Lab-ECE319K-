// FiFo.c
// Runs on LM4F120/TM4C123
// Provide functions that implement the Software FiFo Buffer
// Last Modified: 8/24/2022
// Student names: change this to your names or look very silly
// Last modification date: change this to the last modification date or look very silly
#include <stdint.h>

// Declare state variables for FiFo
//        size, buffer, put and get indexes
#define FIFO_SIZE 9
static uint8_t PutI;
static uint8_t GetI;
static char Fifo[FIFO_SIZE];

// *********** FiFo_Init**********
// Initializes a software FIFO of a
// fixed size and sets up indexes for
// put and get operations
void Fifo_Init() {
PutI = GetI = 0;
}

// *********** FiFo_Put**********
// Adds an element to the FIFO
// Input: Character to be inserted
// Output: 1 for success and 0 for failure
//         failure is when the buffer is full
uint32_t Fifo_Put(char data) {
		if (((PutI+1) % FIFO_SIZE) == GetI) return 0;
	Fifo[PutI]=data; //save in Fifo
	PutI = (PutI+1)%FIFO_SIZE; //next place to put
   return(1);
}

// *********** Fifo_Get**********
// Gets an element from the FIFO
// Input: Pointer to a character that will get the character read from the buffer
// Output: 1 for success and 0 for failure
//         failure is when the buffer is empty
uint32_t Fifo_Get(int32_t *datapt)
{
	if(GetI == PutI) return 0; // fail if empty
  *datapt = Fifo[GetI];      // retrieve data
  GetI = (GetI+1)%FIFO_SIZE; // next place to get
  return 1;  
}
