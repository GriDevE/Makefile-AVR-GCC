# Makefile for AVR-GCC
#### v1.0.0 (2019.04.06 - 2020.02.23)
---

Makefile для AVR-GCC.  

## Features

* Makefile написан понятно и читабельно для человека, чтобы было удобно вручную кастомизировать его под свои нужды.
  В то же время многие аспекты предоставлены на усмотрение пользователя,
  чтобы не ограничивать в возможностях и подтолкнуть к более глубокому пониманию работы Gnu make и AVR-GCC.

* Вывод команды make all структурирован чтобы было просто понять, что происходит и где возникают ошибки.

* Значимые настройки процесса сборки для удобства вынесены и структурированны в верхней части Makefile.

* Даёт возможность одной командой собирать несколько прошивок с различной конфигурацией из одного исходного кода.

* 

## ??Предлагаемые правила ведения проекта??



## Команды

`make` или `make all`
Собрать прошивку(и).
Чтобы пересобрать проект, сделайте `make clean`, затем `make all`.

??Подробнее описать в каких случаях make all не пересобирёт прошивку корректно??
    
`make clean`
Очистить выходные сборочные файлы.

`make flash`
Прошить устройство hex-файлом, используя avrdude.  
Сначала настройте параметры avrdude!

## AVR-GCC, описание команд компилятора



## Описание синтаксиса Makefile и используемого инструментария Gnu make
### Основные понятия Makefile


## avrdude


## Frequently Asked Questions

