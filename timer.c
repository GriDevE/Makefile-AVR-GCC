/*
 * timer.c
 *
 * Created: 2019.11.14 16:00:00
 *  Author: GriDev
 */

#include <avr/interrupt.h>

#include "main.h"
#include "timer.h"


//////// Variables

uint8_t G_counter = 0; // для подсчёта временных интервалов в TIME_T мс

uint16_t G_time_blink = 0; 


//////// Interrupts

#ifndef BLINK_TINY13

ISR(TIMER0_COMPA_vect)

#else

ISR(TIM0_COMPA_vect)

#endif
{
    G_counter++;
}


//////// Functions

void timer_init(void)
{
    DDR(PORT_LED) &= ~(1<<PIN_LED);
    PORT_LED &= ~(1<<PIN_LED);

    TCCR0A = (0<<COM0A1)|(0<<COM0A0)|(0<<COM0B1)|(0<<COM0B0) | (1<<WGM01)|(0<<WGM00);
    TCCR0B = (0<<CS02)|(1<<CS01)|(1<<CS00) | (0<<WGM02);
      //[ FOC0A FOC0B - - WGM02 CS0[2:0] ] 7372.8кГц/64 = 115.2кГц
    TIMSK0 = (1<<OCIE0A);
    //
    TCNT0 = 0;
    OCR0A = (TIME_T*(F_CPU/64)/1000); 
      // x * 1/(7372.8кГц/64) = T мс,  x(T)=(T*7372800/64)/1000,  x(2мс)=230
}

void blink_loop(void)
{
    static uint8_t counter = 0;

    if(G_counter != counter) {
        uint8_t tmp = G_counter;
        uint8_t diff = (uint8_t)(tmp - counter);
        counter = tmp;
        
        G_time_blink += diff;
        if (G_time_blink >= BLINK_T/TIME_T) {
            G_time_blink -= BLINK_T/TIME_T;

            LED_INV;
        }
    }
}
