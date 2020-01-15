#include "stm32l476xx.h"
#include "utility.h"

#define VALID_DISTANCE 20
#define TIME_SEC 5
int Distance;

void timer_init()
{
	RCC->APB1ENR1 |= 0b1;
	TIM3->ARR = (uint32_t) (TIME_SEC * (4000000 / 40000)); // reload value
	TIM3->PSC = (uint32_t) 39999; // prescaler
	TIM3->EGR = TIM_EGR_UG; // reinitialize the counter
}

void timer_start()
{
	TIM3->CR1 |= TIM_CR1_CEN;
	display(0, -1003);
	if (TIME_SEC <= 0 || TIME_SEC > 10000)
	{
		TIM3->CR1 &= ~TIM_CR1_CEN;
		return;
	}
	int pre_val = 0;
	while (1)
	{
		int now_val = TIM3->CNT;
		if (pre_val > now_val)
		{
			TIM3->CR1 &= ~TIM_CR1_CEN;
			return;
		}
		pre_val = now_val;



		//display(now_val, -1000 - len);
	}
}

int main(void) {
	gpio_init();
	GPIO_init();
	max7219_init();
	counter_init();
	sg90_timer_init();

	while(1){
		max7219_init();
		display_trash();


		while(HCSR04GetDistance(0,1)>=VALID_DISTANCE);

		sg90_move(102);


		while(HCSR04GetDistance(0,1)<VALID_DISTANCE);

		//Delay_Ms((uint16_t) 80);
		timer_init();
		timer_start();
		sg90_move(65);
		Delay_Ms((uint16_t) 10);
		max7219_init();
		display_trash();
		Delay_Ms((uint16_t) 10);



	}


	/*sg90_move(50);
	Delay_Ms((uint16_t) 100);
	sg90_move(75);
	Delay_Ms((uint16_t) 100);

	Delay_Ms((uint16_t) 100);
	sg90_move(50);*/
}


