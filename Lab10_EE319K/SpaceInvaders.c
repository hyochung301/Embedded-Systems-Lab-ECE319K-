// SpaceInvaders.c
// Runs on TM4C123
// Jonathan Valvano and Daniel Valvano
// This is a starter project for the EE319K Lab 10

// Last Modified: 11/30/2022 
// http://www.spaceinvaders.de/
// sounds at http://www.classicgaming.cc/classics/spaceinvaders/sounds.php
// http://www.classicgaming.cc/classics/spaceinvaders/playguide.php

// ******* Possible Hardware I/O connections*******************
// Slide pot pin 1 connected to ground
// Slide pot pin 2 connected to PD2/AIN5
// Slide pot pin 3 connected to +3.3V 
// buttons connected to PE0-PE3
// 32*R resistor DAC bit 0 on PB0 (least significant bit)
// 16*R resistor DAC bit 1 on PB1
// 8*R resistor DAC bit 2 on PB2 
// 4*R resistor DAC bit 3 on PB3
// 2*R resistor DAC bit 4 on PB4
// 1*R resistor DAC bit 5 on PB5 (most significant bit)
// LED on PD1
// LED on PD0


#include <stdint.h>
#include "../inc/tm4c123gh6pm.h"
#include "../inc/ST7735.h"
#include "Random.h"
#include "TExaS.h"
#include "../inc/ADC.h"
#include "Images.h"
#include "Sound.h"
#include "Timer1.h"
typedef enum {dead, alive, dying} life_t;
struct enemy{
	int16_t y;//y 0 (top) to 159 (bottom)
	int16_t x;//x 0 (left) to 127 (right)
	uint32_t points;
	const unsigned short *image;
	const unsigned short *bimage;
	life_t life;
};
typedef struct enemy enemy_t;
#define NUME 3
enemy_t Enemies[NUME];
struct bullet{
	int16_t y;//y 0 (top) to 159 (bottom)
	int16_t x;//x 0 (left) to 127 (right)
	int16_t vy; //up is -1, down is +1
	const unsigned short *image;
	const unsigned short *bimage;
	int16_t h,w;
	life_t life;
};
typedef struct bullet bullets_t;
#define NUMB 30
bullets_t Bullets[NUMB];

void init(void){
	for(int i = 0; i<NUMB; i++){
		Bullets[i].life = dead;
		Bullets[i].image = laser;
		Bullets[i].bimage = blacklaser;
		Bullets[i].h = 6;
		Bullets[i].w = 4;
	}
	Enemies[0].x = 5; 
	Enemies[0].y = 10;
	Enemies[0].points = 10;
	Enemies[0].image = SmallEnemy10pointA;
	Enemies[0].bimage = EnemyBlack;
	Enemies[0].life = alive;
	
	Enemies[1].x = 32; 
	Enemies[1].y = 10;
	Enemies[1].points = 30;
	Enemies[1].image = SmallEnemy30pointA;
	Enemies[1].bimage = EnemyBlack;
	Enemies[1].life = alive;
	
	Enemies[2].x = 80; 
	Enemies[2].y = 10;
	Enemies[2].points = 10;
	Enemies[2].image = SmallEnemy10pointA;
	Enemies[2].bimage = EnemyBlack;
	Enemies[2].life = alive;
//	for(int i=3; i<NUME; i++){
//		Enemies[i].life = dead;
//	}
}
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
void Delay100ms(uint32_t count); // time delay in 0.1 seconds

uint32_t KillFlag = 0;
uint32_t score = 0;

uint32_t LastP;
uint32_t PauseFlag = 0;
void PauseCheck (void){
	uint32_t NowP;
	NowP = GPIO_PORTE_DATA_R&0x01;
	if((NowP==1)&&(LastP==0)){
		if ((GPIO_PORTE_DATA_R&0x01) == 1){
			if (PauseFlag == 0){
				PauseFlag = 1;
			}
			else {
				PauseFlag = 0;
			}
		}
	}
	LastP = NowP;
}

uint32_t Data, Position, OldPosition;
uint32_t Lang;


void Gameover(void){ //needs to go in when either all the enemies are gone, or after move(), the enemy is at the botton.
ST7735_FillScreen(0x0000);            // set screen to black
  if (Lang == 1){
			ST7735_SetCursor (0,0);
      ST7735_OutString(("Gameover"));
			ST7735_SetCursor (0,5);
			ST7735_OutString(("Score:"));
      ST7735_OutUDec(score);
			while(1){}
	}
	else{
			ST7735_SetCursor (0,0);
      ST7735_OutString(("Juego terminado"));
			ST7735_SetCursor (0,5);
			ST7735_OutString(("Score:"));
			ST7735_OutUDec(score);
			while (1){}
  }
}

void CheckAllDead (void){
	if (NUME == KillFlag){
		Gameover();
	}
}

void Gamestart(void){
	ST7735_FillScreen(0x0000);            // set screen to black
	ST7735_OutString("\nPara Espanol,\npresione el\nboton inferior\n\nFor English,\nPress the\ntop button");
while(GPIO_PORTE_DATA_R == 0){}//wait for the input to come in (mask for pe0 and pe1 for read)
  if ((GPIO_PORTE_DATA_R & 0x01) == 1){
         Lang = 1;
	}
			else{
         Lang = 0;
    }
	}
void Draw(void){int32_t d;
	d= OldPosition = Position;
if (d>2 || d<-2){	
	ST7735_DrawBitmap(OldPosition, 159, PlayerShip0, 18, 8);

	ST7735_DrawBitmap(Position, 159, PlayerBlack, 18, 8);
}
else{	ST7735_DrawBitmap(Position, 159, PlayerBlack, 18, 8);
}
	
	for(int i=0; i<NUME; i++){
	if(Enemies[i].life == alive){
		ST7735_DrawBitmap(
	Enemies[i].x,
	Enemies[i].y,
	Enemies[i].image, 16, 10);
		}
	if(Enemies[i].life == dying){
		ST7735_DrawBitmap(
	Enemies[i].x,
	Enemies[i].y,
	Enemies[i].bimage, 16, 10);
		Enemies[i].life = dead;
	}
}
	
for(int i=0; i<NUMB; i++){
	if(Bullets[i].life == alive){
		ST7735_DrawBitmap(
	Bullets[i].x,
	Bullets[i].y,
	Bullets[i].image,
	Bullets[i].w, Bullets[i].h);
		}
	if(Bullets[i].life == dying){
		ST7735_DrawBitmap(
	Bullets[i].x,
	Bullets[i].y,
	Bullets[i].bimage, 4, 6);
		Bullets[i].life = dead;
	}
}
	}
uint32_t Count = 0;
#define RATE 1
void Move(void){
	if((Count%RATE)==0){
		
	for (int i=0; i<NUME; i++){
		if (Enemies[i].life == alive){
			if(Enemies[i].y>=159){ //if the position goes out goes down the speicific, game over
				Sound_Explosion();
				Gameover(); 
			}else {			Enemies[i].y++;
			}
		}
	
}

	for(int i=0; i<NUMB; i++){
		if(Bullets[i].life == alive){
			if ((Bullets[i].y<4)||(Bullets[i].y>159)){
				Bullets[i].life = dying;
			}else{
				Bullets[i].y = Bullets[i].y+Bullets[i].vy;
			}
	}
}
}
	}

//30 HZ > 2*fmax
// low priority


int Flag;
uint32_t LastE;
void ProcessInput(void){ //need to supply more than 1 bullet on the screen at once
	uint32_t Now;
	Now = GPIO_PORTE_DATA_R&0x02;
	if((Now==2)&& (LastE==0)){
		for (uint32_t i = 0; i<NUMB ;i++){
//			if (Bullets[i].life == dead){
//				Bullets[i].life = alive;
//				break;
//			}
			// search the array of bullets, looking for bullet[i].life == dead, activate that one and turn alive
			// once found, only activate one and quit the for loop
			if (Bullets[i].life == dead){
				Bullets[i].life = alive;
				Bullets[i].vy = -1; //just needed to slow the bullet to make the streaking disappear
				Bullets[i].x = Position;
				Bullets[i].y = 150;
				Sound_Shoot();
				break;
			}
		}
	}
	LastE = Now;
}

//need global for score and init it to 0
void Collision(void){
	//compare enemy x and y to bullet x and y
	//if the calculation is in between the range of the hitbox, change both enemy and bullet status to dying, then dead
	for (int i = 0; i < NUME; i++){
		//only look at enemies that are alive
		if (Enemies[i].life == alive){
			for (int j = 0; j < NUMB; j++){
				if(Bullets[j].life == alive){
					//only look at bullets that are alive
					if ((((Enemies[i].x - Bullets[j].x)*(Enemies[i].x - Bullets[j].x))+((Enemies[i].y - Bullets[j].y)*(Enemies[i].y - Bullets[j].y))) < 100){              //collision calc needed here
					Enemies[i].life = dying;
					Bullets[j].life = dying;
					score += Enemies[i].points;
					Sound_Killed();
					KillFlag = KillFlag+1;
					CheckAllDead();
					}
				}
			}
		}
	}	
}

void Timer1A_Handler(void){ // can be used to perform tasks in background 
  TIMER1_ICR_R = TIMER_ICR_TATOCINT;// acknowledge TIMER1A timeout
	Data = ADC_In();//sample ADC for slide pot (SAC=0), to move player
	OldPosition = Position;
	Position = ((127-18)*Data)/4095; //0 to 109
	//sample buttons
	
	PauseCheck();
	while(PauseFlag == 1){
	PauseCheck();
	}
	
	ProcessInput();
	Count++;
	Move();//move sprites
	// game, colissions, start sounds, points (need these)
	Collision();
	// signal to main thread that changes
  // execute user task
	Flag = 1;
}
void PortE_Init(void){
	SYSCTL_RCGCGPIO_R |= 0x10;
	while((SYSCTL_PRGPIO_R & 0x10) != 0x10){};
	GPIO_PORTE_DIR_R &= ~0x0F;
	GPIO_PORTE_DEN_R |= 0x0F;

	}

int main(void){
	
  DisableInterrupts();
  TExaS_Init(NONE);       // Bus clock is 80 MHz 
  Random_Init(1);
  Output_Init();
	Sound_Init();
  ST7735_FillScreen(0x0000);            // set screen to black
  Timer1_Init(80000000/30, 5); // 1 Hz
	Flag=0;
	ADC_Init();
	PortE_Init();
	init();
	Data = ADC_In();
	OldPosition = ((127-18)*Data)/4095; //0 to 109

	EnableInterrupts();
  //Initialize everything
	Gamestart();
	ST7735_FillScreen(0x0000);
  while(1){
		while(Flag==0){}; //waiting for semaphore
		// draw the screen 
			Draw();
			Flag = 1;
  }

}




















// You can't use this timer, it is here for starter code only 
// you must use interrupts to perform delays
void Delay100ms(uint32_t count){uint32_t volatile time;
  while(count>0){
    time = 727240;  // 0.1sec at 80 MHz
    while(time){
      time--;
    }
    count--;
  }
}
typedef enum {English, Spanish, Portuguese, French} Language_t;
Language_t myLanguage=English;
typedef enum {HELLO, GOODBYE, LANGUAGE} phrase_t;
const char Hello_English[] ="Hello";
const char Hello_Spanish[] ="\xADHola!";
const char Hello_Portuguese[] = "Ol\xA0";
const char Hello_French[] ="All\x83";
const char Goodbye_English[]="Goodbye";
const char Goodbye_Spanish[]="Adi\xA2s";
const char Goodbye_Portuguese[] = "Tchau";
const char Goodbye_French[] = "Au revoir";
const char Language_English[]="English";
const char Language_Spanish[]="Espa\xA4ol";
const char Language_Portuguese[]="Portugu\x88s";
const char Language_French[]="Fran\x87" "ais";
const char *Phrases[3][4]={
  {Hello_English,Hello_Spanish,Hello_Portuguese,Hello_French},
  {Goodbye_English,Goodbye_Spanish,Goodbye_Portuguese,Goodbye_French},
  {Language_English,Language_Spanish,Language_Portuguese,Language_French}
};

int main1(void){ char l;
  DisableInterrupts();
  TExaS_Init(NONE);       // Bus clock is 80 MHz 
  Output_Init();
  ST7735_FillScreen(0x0000);            // set screen to black
  for(phrase_t myPhrase=HELLO; myPhrase<= GOODBYE; myPhrase++){
    for(Language_t myL=English; myL<= French; myL++){
         ST7735_OutString((char *)Phrases[LANGUAGE][myL]);
      ST7735_OutChar(' ');
         ST7735_OutString((char *)Phrases[myPhrase][myL]);
      ST7735_OutChar(13);
    }
  }
  Delay100ms(30);
  ST7735_FillScreen(0x0000);       // set screen to black
  l = 128;
  while(1){
    Delay100ms(20);
    for(int j=0; j < 3; j++){
      for(int i=0;i<16;i++){
        ST7735_SetCursor(7*j+0,i);
        ST7735_OutUDec(l);
        ST7735_OutChar(' ');
        ST7735_OutChar(' ');
        ST7735_SetCursor(7*j+4,i);
        ST7735_OutChar(l);
        l++;
      }
    }
  }  
}
