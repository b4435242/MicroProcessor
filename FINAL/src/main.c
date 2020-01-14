#include "stm32l476xx.h"
#include "utility.h"

#define VALID_DISTANCE 20

int Distance;

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

		Delay_Ms((uint16_t) 80);

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


