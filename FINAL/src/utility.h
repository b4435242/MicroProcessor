#ifndef UTILITY_H_
#define UTILITY_H_

#include "stm32l476xx.h"

/**
 * these functions are inside the assembly source file
 */
extern void gpio_init();

extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);


/**
 * GPIO pin macros
 */
#define GPIO_Pin_0  0b0000000000000001
#define GPIO_Pin_1  0b0000000000000010
#define GPIO_Pin_2  0b0000000000000100
#define GPIO_Pin_3  0b0000000000001000
#define GPIO_Pin_4  0b0000000000010000
#define GPIO_Pin_5  0b0000000000100000
#define GPIO_Pin_6  0b0000000001000000
#define GPIO_Pin_7  0b0000000010000000
#define GPIO_Pin_8  0b0000000100000000
#define GPIO_Pin_9  0b0000001000000000
#define GPIO_Pin_10 0b0000010000000000
#define GPIO_Pin_11 0b0000100000000000
#define GPIO_Pin_12 0b0001000000000000
#define GPIO_Pin_13 0b0010000000000000
#define GPIO_Pin_14 0b0100000000000000
#define GPIO_Pin_15 0b1000000000000000



/**
 * RCC PLL configuration structure definition
 */
typedef struct
{
	uint32_t PLLState;  // The new state of the PLL
	uint32_t PLLSource; // PLL entry clock source
	uint32_t PLLM;      // Division factor for PLL VCO input clock
	uint32_t PLLN;      // Multiplication factor for PLL VCO output clock
	uint32_t PLLP;      // Division factor for SAI clock
	uint32_t PLLQ;      // PLLQ: Division factor for SDMMC1, RNG and USB clocks
	uint32_t PLLR;      // Division for the main system clock
} RCC_PLLInitTypeDef;

/**
 * RCC Internal/External Oscillator configuration structure definition
 */
typedef struct
{
	uint32_t OscillatorType;      // The oscillators to be configured
	uint32_t HSEState;            // The new state of the HSE
	uint32_t LSEState;            // The new state of the LSE
	uint32_t HSIState;            // The new state of the HSI
	uint32_t HSICalibrationValue; // The calibration trimming value
	uint32_t LSIState;            // The new state of the LSI
	uint32_t MSIState;            // The new state of the MSI
	uint32_t MSICalibrationValue; // The calibration trimming value
	uint32_t MSIClockRange;       // The MSI frequency range
	uint32_t HSI48State;          // The new state of the HSI48
	RCC_PLLInitTypeDef PLL;       // Main PLL structure parameters
} RCC_OscInitTypeDef;

/**
 * RCC System, AHB and APB busses clock configuration structure definition
 */
typedef struct
{
	uint32_t ClockType;      // The clock to be configured
	uint32_t SYSCLKSource;   // The clock source used as system clock (SYSCLK)
	uint32_t AHBCLKDivider;  // The AHB clock (HCLK) divider
	uint32_t APB1CLKDivider; // The APB1 clock (PCLK1) divider
	uint32_t APB2CLKDivider; // The APB2 clock (PCLK2) divider
} RCC_ClkInitTypeDef;


int GPIO_ReadInputDataBit(GPIO_TypeDef *port, uint16_t pin) {
	return (port->IDR >> pin) & 1;
}

void GPIO_SetOutputDataBit(GPIO_TypeDef *port, uint16_t pin,int val){
	if(val==0)
		port->ODR &= ~(1<<pin);
	else if(val==1)
		port->ODR |=  (1<<pin);
}


void counter_init()
{
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM6EN;
	//TIM6->ARR = (uint32_t) (TIME_SEC * (4000000 / 40000)); // reload value
	TIM6->PSC = (uint32_t) 3; // prescaler

}

void start_counter()
{
	TIM6->EGR = TIM_EGR_UG; // reinitialize the counter
	TIM6->CR1 |= TIM_CR1_CEN;
}

void end_counter()
{
	TIM6->CR1 &= ~TIM_CR1_CEN;
}

void Delay_Us(uint16_t time)  //延時函數
{
    uint16_t i,j;
    for(i=0;i<time;i++)
          for(j=0;j<9;j++);
}

int HCSR04GetDistance(int in_pin,int out_pin) {
	int length=0;
	int constant=58;
	int Num_Avg=5;
	int sum=0;

	for(int i=0;i<Num_Avg;i++){
		//trigger
		GPIO_SetOutputDataBit(GPIOB,out_pin,1);
		Delay_Us(20);
		GPIO_SetOutputDataBit(GPIOB,out_pin,0);

		//measure
		while(!GPIO_ReadInputDataBit(GPIOB,in_pin));

		start_counter();

		while(GPIO_ReadInputDataBit(GPIOB,in_pin));

		end_counter();

		length=(TIM6->CNT/constant);
		sum+=length;
	}

	return (sum/Num_Avg);
}

int display(int data, int num_digs)
 {
     //getting the value from LSB to MSB which is right to left
     //7 seg panel from 1 to 7 (not zero base)
     int i=0,dig=0;
     for(i=1;i<=num_digs;i++)
     {
         max7219_send(i,data%10);
         dig=data%10;
         data/=10; //get the next digit
     }
     if(data>99999999 || data<-9999999)
         return -1; //out of range error
     else
         return 0; //end this function
 }

int display_clr(int num_digs)
{
 	for(int i=1;i<=num_digs;i++)
 	{
 		max7219_send(i,0xF);
 	}
 	return 0;
}

void display_trash(){
	int trash=HCSR04GetDistance(5,6);
	trash=trash>20?20:trash;


	int trashCan_height=20;
	int ratio=(trash*100)/trashCan_height;
	ratio=100-ratio;
	if(ratio%10>6)
		ratio+=10;
	ratio-=ratio%10;


	int digit;
	if(ratio>=100)
		digit=3;
	else if(ratio>=10)
		digit=2;
	else
		digit=1;

	display_clr(3);
	display(ratio,digit);
}

/*
 	 SG-90
 */

void sg90_timer_init()
{

		RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
		// enable TIM2 timer clock
		GPIOB->AFR[0] |= GPIO_AFRL_AFSEL3_0;
		// select AF1 for PB3 (PB3 is TIM2_CH2)
		TIM2->CR1 |= TIM_CR1_ARPE;
		// enable auto-reload preload (buffer TIM2_ARR)
		TIM2->ARR = (uint32_t) (1000);
		// auto-reload prescaler value
		TIM2->CCMR1 &= 0xFFFFFCFF;
		// select compare 2 (channel 2 is configured as output)
		TIM2->CCMR1 |= (TIM_CCMR1_OC2M_2 | TIM_CCMR1_OC2M_1);
		// set output compare 2 mode to PWM mode 1
		TIM2->CCMR1 |= TIM_CCMR1_OC2PE;
		// enable output compare 2 preload register on TIM2_CCR2
		TIM2->CCER |= TIM_CCER_CC2E;
		// enable compare 2 output
		TIM2->EGR = TIM_EGR_UG;
		// re-initialize the counter and generates an update of the registers


		TIM2->PSC = (uint32_t) (4000000 / 50 )/ TIM2->ARR;
		// prescaler value

		TIM2->CR1 |= TIM_CR1_CEN;

}


void  sg90_move(int duty_cycle){
	//TIM2->ARR

	TIM2->CCR2 = duty_cycle;
	// compare 2 preload value

	TIM3->CCR2 = duty_cycle;

}

void Delay_Ms(uint16_t time)  //延時函數
{
    uint16_t i,j;
    for(i=0;i<time;i++)
           for(j=0;j<10260;j++);
}

#endif /* UTILS_H_ */
