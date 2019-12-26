/*
 * timer.h
 *
 * Created: 14.11.2019 11:04:00
 *  Author: GriDev
 */

#pragma once


//////// Options

#define TIME_T 2 //(мс) единица отсчёта временных интервалов

#define BLINK_T 1000 //(мс) период мигания

//////// Functions

void timer_init(void);

void blink_loop(void);
