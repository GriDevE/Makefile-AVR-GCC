# / / / / / / / / / / / / / / / / / / / / / / / 
# Makefile to build different firmware of one source
# Created: 2019.04.06
# Author: GriDev
# \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \


# Эти make-переменные будут переданы в define исходников(при помощи флага -Ddefinition),
# с их помощю мы сможем делать условную компиляцию.
DEVICE_1 = ROUTER_485  # main router, connected to modem
DEVICE_2 = ROUTER      # end device

SRC = main.c uart_fifo.c apc240.c utils.c pack.c aes.c at24cxxx.c

# DEVICE_1

TARGET_1 = router_485
MCU_1 = atmega168p
F_CPU_1 = 7372800UL

# DEVICE_2

TARGET_2 = router
MCU_2 = atmega168p
F_CPU_2 = 8000000UL


# Optimization level -On, n to can be [0, 1, 2, 3, s]. 
OPT = -Os  

# Building EEPROM hex
EEP_FILE = #yes  

#-----------------------------------------------

# GNU Binutils
CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
SIZE = avr-size



all: $(TARGET_1) $(TARGET_2)


# шаблоны суффиксов имён файлов
TEMPLATE_1 = _$(TARGET_1)
TEMPLATE_2 = _$(TARGET_2)

# указываем GNU make имена файлов-зависимостей которые он будет отслеживать в правилах
OBJS_1 = $(SRC:.c=$(TEMPLATE_1).o)  
OBJS_2 = $(SRC:.c=$(TEMPLATE_2).o)


# Linking DEVICE_1

print_target_1:
	@echo _______________________________________
	@echo                  begin
	@echo --------------------------------
	@echo             Compiling files for: $(TARGET_1)
	@echo -

$(TARGET_1): $(eval MCU = $(MCU_1)) \
             $(eval F_CPU = $(F_CPU_1)) \
             $(eval DEVICE = $(DEVICE_1)) \
             $(eval TEMPLATE = $(TEMPLATE_1)) \
             $(eval OBJS = $(OBJS_1)) \
             $(eval TARGET = $(TARGET_1)) \
             print_target_1 \
             $(OBJS_1)
	@echo --------------------------------
	@echo               Linking files for: $(TARGET)
	@echo -

	$(CC) -mmcu=$(MCU) -Wall $(OPT) -Wl,-Map=$(TARGET).map,--cref \
                                     -o $(TARGET).elf $(OBJS) -lm

	$(OBJCOPY) -O ihex -R .eeprom -R .fuse -R .lock -R .signature \
                                     $(TARGET).elf $(TARGET).hex

	$(OBJCOPY) -O binary -R .eeprom -R .nwram \
                                     $(TARGET).elf $(TARGET).bin

ifeq ($(strip $(EEP_FILE)), yes)
	$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom=alloc,load --change-section-lma \
                                     .eeprom=0 --no-change-warnings -O ihex $(TARGET).elf $(TARGET)_eep.hex
endif

	$(OBJDUMP) -h -S $(TARGET).elf > $(TARGET).lss

	@echo -
	@echo ----------------
	$(SIZE) -C --mcu=$(MCU) $(TARGET).elf

#   Меняем конфигурацию для DEVICE_2
#   В зависимостях или целях в $(TARGET_2) мы этого не сможем сделать, 
#   Потому что, видимо make делает предварительный анализ Makefile, проверяет цели и зависимости в правилах,
#   убеждается что все зависимости 'закрыты',
#   в итоге eval который был последний обновляет переменную последним значением;
#   а вот в команды он не проверяет, и вставив сюда eval можно динамически управлять содержанием Makefile.
	$(eval MCU = $(MCU_2))
	$(eval F_CPU = $(F_CPU_2))
	$(eval DEVICE = $(DEVICE_2))
	$(eval TEMPLATE = $(TEMPLATE_2))
	$(eval OBJS = $(OBJS_2))
	$(eval TARGET = $(TARGET_2))


# Linking DEVICE_2

print_target_2:
	@echo --------------------------------
	@echo             Compiling files for: $(TARGET)
	@echo -

$(TARGET_2): print_target_2 $(OBJS_2)
	@echo --------------------------------
	@echo               Linking files for: $(TARGET)
	@echo -

	$(CC) -mmcu=$(MCU) -Wall $(OPT) -Wl,-Map=$(TARGET).map,--cref \
                                     -o $(TARGET).elf $(OBJS) -lm

	$(OBJCOPY) -O ihex -R .eeprom -R .fuse -R .lock -R .signature \
                                     $(TARGET).elf $(TARGET).hex

	$(OBJCOPY) -O binary -R .eeprom -R .nwram \
                                     $(TARGET).elf $(TARGET).bin

ifeq ($(strip $(EEP_FILE)), yes)
	$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom=alloc,load --change-section-lma \
                                     .eeprom=0 --no-change-warnings -O ihex $(TARGET).elf $(TARGET)_eep.hex
endif

	$(OBJDUMP) -h -S $(TARGET).elf > $(TARGET).lss

	@echo -
	@echo ----------------
	$(SIZE) -C --mcu=$(MCU) $(TARGET).elf

	@echo _________________ end _________________
	@echo .


# Compiling DEVICE_1

%$(TEMPLATE_1).o: %.c
	@echo Compiling file:  $<
	$(CC) -mmcu=$(MCU) -Wall $(OPT) -DF_CPU=$(F_CPU) -D$(DEVICE) \
                                     -c $< -o $@

# Compiling DEVICE_2

%$(TEMPLATE_2).o: %.c
	@echo Compiling file:  $<
	$(CC) -mmcu=$(MCU) -Wall $(OPT) -DF_CPU=$(F_CPU) -D$(DEVICE) \
                                     -c $< -o $@


# 

clean:
	rm -rf *.elf *.hex $(OBJS_1) $(OBJS_2) *.map *.lss *.bin


# на случай если будут такие файлы, чтобы не отслеживал правила-пустышки
.PHONY : all clean flash print_target_1 print_target_2 
