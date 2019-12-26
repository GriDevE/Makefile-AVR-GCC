/*
 * main.h
 *
 * Created: 2019.12.25 13:00:00
 *  Author: GriDev
 */

#pragma once


//////// Ports



//// LED
#ifndef BLINK_TINY13

#define PORT_LED PORTB
#define PIN_LED  PB1

#else

#define PORT_LED PORTB
#define PIN_LED  PB0

#endif
#define LED_ON    DDR(PORT_LED) |= (1<<PIN_LED)
#define LED_OFF   DDR(PORT_LED) &=~(1<<PIN_LED)
#define LED_INV   DDR(PORT_LED) ^= (1<<PIN_LED)


//////// Read / Write of Ports

#define DDR(x) (*(&x - 1))      // address of data direction register of port x
#if defined(__AVR_ATmega64__) || defined(__AVR_ATmega128__)
    // on ATmega64/128 PINF is on port 0x00 and not 0x60
    #define PIN(x) ( &PORTF==&(x) ? _SFR_IO8(0x00) : (*(&x - 2)) )
#else
    #define PIN(x) (*(&x - 2))  // address of input register of port x
#endif
