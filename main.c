/*
 * main.c
 *
 * Created: 2019.12.25 13:00:00
 *  Author: GriDev
 */

#include <avr/interrupt.h>

#include "timer.h"
#include "main.h"

////////

int main(void)
{
    cli();

    timer_init();

    sei();

    for ( ; ; ) {

        blink_loop();
    }
}
