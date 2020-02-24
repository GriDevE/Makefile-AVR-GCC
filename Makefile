# / / / / / / / / / / / / / / / / / / / / / / /
# Makefile for AVR-GCC. Allows build different firmware of one source.
# Created: 2019.04.06
# Version: 1.0.1
#  Author: GriDev
# \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \


# Эти make-переменные будут переданы в define исходников(при помощи флага -Ddefinition),
# с их помощю можно делать условную компиляцию, конфигурировать прошивку.
DEVICE_1 = BLINK        # Основная прошивка
DEVICE_2 = BLINK_TEST   # Тестовая прошивка
DEVICE_3 = BLINK_TINY13 # Прошивка для ATtiny13

SRC = main.c timer.c

# DEVICE_1

TARGET_1 = blink
MCU_1 = atmega168p
F_CPU_1 = 7372800UL

# DEVICE_2

TARGET_2 = test
MCU_2 = atmega168p
F_CPU_2 = 7372800UL

# DEVICE_3

TARGET_3 = tiny13
MCU_3 = attiny13
F_CPU_3 = 8000000UL


# Optimization level
OPT = s
  # 0, 1, 2, 3, s

# Стандарт языка C
STD = c11
  # c89   - "ANSI" C
  # gnu89 - c89 plus GCC extensions
  # c99   - ISO C99 standard (not yet fully implemented)
  # gnu99 - c99 plus GCC extensions
  # c11

FLAGS_COMPILER = -fpack-struct -fshort-enums -Wall

FLAGS_LINKER = -lm

# Building EEPROM hex
EEP_FILE = +


# - - - - - - - - - - - - - - - - - - - - - - -

# GNU Binutils
#Path = C:/Program Files/Atmel/AVR Tools/avr8-gnu-toolchain-win32_x86/bin/
Path = 
CC = "$(Path)avr-gcc"
OBJCOPY = "$(Path)avr-objcopy"
OBJDUMP = "$(Path)avr-objdump"
SIZE = "$(Path)avr-size"
  # '  - такие кавычки в шеле Sublime Text вызывают ошибку почему-то, лучше используем ".


all: print_begin $(TARGET_1) $(TARGET_2) $(TARGET_3) print_end


# Шаблоны суффиксов имён генерируемых файлов
TEMPLATE = _$(1)
  # $(1) - сюда подставляется TARGET с помощю call

# Указываем GNU make имена файлов-зависимостей которые он будет отслеживать в правилах
OBJS = $(SRC:.c=$(call TEMPLATE,$(1)).o)
  # $(1) - сюда подставляем TARGET с помощю call


print_begin:
	$(CC) --version
	@echo _______________________________________
	@echo ________________ begin ________________
print_end:
	@echo _________________ end _________________
	@echo .
print_target_1_compiling:
	$(call print_target_compiling_d,$(TARGET_1))
define print_target_compiling_d
	@echo --------------------------------
	@echo - - - - - - Compiling files for: $(1)
	@echo -
endef


# Compiling

define compiling
	@echo - $<
	$(CC) -mmcu=$(MCU) -O$(OPT) -std=$(STD) -DF_CPU=$(F_CPU) -D$(strip $(DEVICE)) $(FLAGS_COMPILER) \
                                     -c $< -o $@
endef

# Compiling DEVICE_1
%$(call TEMPLATE,$(TARGET_1)).o: %.c
	$(compiling)

# Compiling DEVICE_2
%$(call TEMPLATE,$(TARGET_2)).o: %.c
	$(compiling)

# Compiling DEVICE_3
%$(call TEMPLATE,$(TARGET_3)).o: %.c
	$(compiling)


# Linking

define linking
	@echo --------------------------------
	@echo - - - - - - - Linking files for: $@
	@echo -

	$(CC) -mmcu=$(MCU) -Wall -O$(OPT) -Wl,-Map=$@.map,--cref \
                                     -o $@.elf $(call OBJS,$@) $(FLAGS_LINKER)

	$(OBJCOPY) -O ihex -R .eeprom -R .fuse -R .lock -R .signature \
                                     $@.elf $@.hex

	$(OBJCOPY) -O binary -R .eeprom -R .nwram \
                                     $@.elf $@.bin

	$(OBJDUMP) -h -S $@.elf > $@.lss
endef
define generate_eeprom
	$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom=alloc,load --change-section-lma \
                                     .eeprom=0 --no-change-warnings -O ihex $@.elf $@_eep.hex
endef
define finalize
	@echo -
	@echo ----------------
	$(SIZE) --format=avr --mcu=$(MCU) $@.elf
endef

# Linking DEVICE_1
$(TARGET_1): $(eval MCU = $(MCU_1)) \
             $(eval F_CPU = $(F_CPU_1)) \
             $(eval DEVICE = $(DEVICE_1)) \
             print_target_1_compiling \
             $(call OBJS,$(TARGET_1))
	$(linking)
ifeq ($(strip $(EEP_FILE)), +)
	$(generate_eeprom)
endif
	$(finalize)
#   Меняем конфигурацию для DEVICE_2
#   В зависимостях или целях в $(TARGET_2) мы этого не сможем сделать, 
#   Потому что, видимо make делает предварительный анализ Makefile, проверяет цели и зависимости в правилах,
#   убеждается что все зависимости 'закрыты',
#   в итоге eval который был последний, обновляет переменную последним значением;
#   а вот команды он не проверяет, и вставив сюда eval можно динамически управлять содержанием Makefile.
	$(eval MCU = $(MCU_2))
	$(eval F_CPU = $(F_CPU_2))
	$(eval DEVICE = $(DEVICE_2))
	$(call print_target_compiling_d,$@)

# Linking DEVICE_2
$(TARGET_2): $(call OBJS,$(TARGET_2))
	$(linking)
ifeq ($(strip $(EEP_FILE)), +)
	$(generate_eeprom)
endif
	$(finalize)
#   Меняем конфигурацию для DEVICE_3
	$(eval MCU = $(MCU_3))
	$(eval F_CPU = $(F_CPU_3))
	$(eval DEVICE = $(DEVICE_3))
	$(print_target_compiling_d)

# Linking DEVICE_3
$(TARGET_3): $(call OBJS,$(TARGET_3))
	$(linking)
ifeq ($(strip $(EEP_FILE)), +)
	$(generate_eeprom)
endif
	$(finalize)

#

clean:
	rm -rf $(call OBJS,$(TARGET_1))  \
       $(call OBJS,$(TARGET_2))  \
       $(call OBJS,$(TARGET_3))  \
       $(TARGET_1).elf $(TARGET_2).elf $(TARGET_3).elf  \
       $(TARGET_1).map $(TARGET_2).map $(TARGET_3).map  \
       $(TARGET_1).lss $(TARGET_2).lss $(TARGET_3).lss  \
       $(TARGET_1).bin $(TARGET_2).bin $(TARGET_3).bin  \
       $(TARGET_1).hex $(TARGET_2).hex $(TARGET_3).hex  \
       $(TARGET_1)_eep.hex $(TARGET_2)_eep.hex $(TARGET_3)_eep.hex

#

flash:
	avrdude -patmega168 -cstk500 -PCOM9 -e -Uflash:w:$(TARGET_1).hex:i


# на случай если будут такие файлы, чтобы не отслеживал правила-пустышки
.PHONY: all clean flash print_begin print_end print_target_1_compiling
