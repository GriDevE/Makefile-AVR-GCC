# Makefile for projects on AVR-GCC
#### v1.0.4 (project start: 2019.04.06)
#### Compiler: avr-gcc (AVR_8_bit_GNU_Toolchain_3.6.2_1759) 5.4.0
#### Author: GriDev
---

Makefile для проектов на AVR-GCC.  

## Features

* Makefile написан понятно и читабельно для человека, чтобы было удобно вручную кастомизировать его под свои нужды.
  В то же время многие аспекты предоставлены на усмотрение пользователя,
  чтобы не ограничивать в возможностях и подтолкнуть к более глубокому пониманию работы Gnu make и AVR-GCC.

* Вывод команды make all структурирован чтобы было просто понять, что происходит и где возникают ошибки.

* Значимые настройки процесса сборки для удобства вынесены и структурированны в верхней части Makefile.  
  Настройки относящиеся к целям вынесены в отдельный файл Makeconf.

* Даёт возможность одной командой собирать несколько прошивок с различной конфигурацией из одного исходного кода.


## Как использовать
1. Копируем Makefile и Makeconf в свой проект.
2. Конфигурируем и адаптируем Makefile для своего проекта.


## ??Предлагаемые правила ведения проекта??



## Команды

`make` или `make all`
Собрать прошивку(и).
Чтобы пересобрать проект, сделайте `make clean`, затем `make all`.

??Подробнее описать в каких случаях make all не пересобирёт прошивку корректно??
    
`make clean`
Очистить выходные файлы.

`make flash`
Прошить устройство hex-файлом, используя avrdude.  
Сначала настройте параметры avrdude!

## AVR-GCC, описание команд компилятора



## Описание синтаксиса Makefile и используемого инструментария Gnu make
### Основные понятия Makefile


## avrdude


## Frequently Asked Questions


## Links
### Документация GNU make
https://www.gnu.org/software/make/manual/html_node/
### AVR and Arm Toolchains (Compiler AVR-GCC)
https://www.microchip.com/mplab/avr-support/avr-and-arm-toolchains-c-compilers  
Документация здесь:  
C:\Program Files (x86)\avr8-gnu-toolchain-win32_x86\doc\
### Документация GCC, AVR-GCC, некоторые ссылки
https://gcc.gnu.org/onlinedocs/gcc/
https://gcc.gnu.org/onlinedocs/gcc/AVR-Options.html
https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html
### Документация AVR Libc
http://www.nongnu.org/avr-libc/user-manual/index.html

