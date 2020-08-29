# / / / / / / / / / / / / / / / / / / / / / / /
# Makefile for projects on AVR-GCC. Allows build different firmware of one source.
# Created: 2019.04.06 - 2020.08.29
# Version: 1.0.3
#  Author: GriDev
#    Link: https://github.com/GriDevE/Makefile-AVR-GCC
# \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \

include Makeconf

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

FLAGS_COMPILER = -Wall -gstabs
FLAGS_COMPILER += -funsigned-char
FLAGS_COMPILER += -funsigned-bitfields
FLAGS_COMPILER += -fpack-struct
FLAGS_COMPILER += -fshort-enums
#FLAGS_COMPILER += -ffunction-sections
#FLAGS_COMPILER += -fdata-sections

FLAGS_LINKER = -lm
#FLAGS_LINKER += -Wl,--gc-sections

# Building EEPROM hex
EEP_FILE = +
# Generate listing files
LSS_FILE = +
# Generate bin files
BIN_FILE = +
# Generate map files
MAP_FILE = +

# - - - - - - - - - - - - - - - - - - - - - - -

# GNU Binutils
Path = 
#Path = C:/Program Files/Atmel/AVR Tools/avr8-gnu-toolchain-win32_x86/bin/
CC = "$(Path)avr-gcc"
OBJCOPY = "$(Path)avr-objcopy"
OBJDUMP = "$(Path)avr-objdump"
SIZE = "$(Path)avr-size"
  # '  - Такие кавычки в шеле Sublime Text вызывают ошибку почему-то, лучше используем ".

PHONY := all
all: print_begin $(TARGET_1) $(TARGET_2) $(TARGET_3) print_end


# Шаблон суффикса имëн генерируемых файлов
TEMPLATE = _$(1)
  # $(1) - Сюда подставляется TARGET с помощю call

# Имена объектных файлов
OBJSa = $(ASRCS:.s=$(call TEMPLATE,$(1)).o)
OBJSA = $(OBJSa:.S=$(call TEMPLATE,$(1)).o)
OBJS = $(SRCS:.c=$(call TEMPLATE,$(1)).o) $(call OBJSA,$(1))
  # $(1) - Сюда подставляем TARGET с помощю call

## Вывод заголовков
PHONY += print_begin print_end print_target_1_compiling print_target_2_compiling print_target_3_compiling
print_begin:
	$(CC) --version
	@echo _______________________________________
	@echo ________________ begin ________________
print_end:
	@echo _________________ end _________________
	@echo .
print_target_1_compiling:
	$(call print_target_compiling_d,$(TARGET_1))
print_target_2_compiling:
	$(call print_target_compiling_d,$(TARGET_2))
print_target_3_compiling:
	$(call print_target_compiling_d,$(TARGET_3))
define print_target_compiling_d
	@echo --------------------------------
	@echo - - - - - - Compiling files for: $(1)
	@echo -
endef


## Additionally
ifeq ($(strip $(BIN_FILE)), +)
define generate_bin
	$(OBJCOPY) -O binary -R .eeprom -R .nwram \
                                     $@.elf $@.bin
endef
endif
ifeq ($(strip $(LSS_FILE)), +)
LSS_AFLAG = -Wa,-adhlns=$(basename $<).lss,-gstabs,--listing-cont-lines=100
define generate_lss
	$(OBJDUMP) -h -S $@.elf > $@.lss
endef
endif
ifeq ($(strip $(EEP_FILE)), +)
define generate_eeprom
	$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom=alloc,load --change-section-lma \
                                     .eeprom=0 --no-change-warnings -O ihex $@.elf $@_eep.hex
endef
endif
ifeq ($(strip $(MAP_FILE)), +)
MAP_LFLAG = -Wl,-Map=$@.map,--cref
endif
define finalize
	@echo -
	@echo ----------------
	$(SIZE) --format=avr --mcu=$(MCU) $@.elf
endef


## Compiling and Assembling

define compiling
	@echo $<
	$(CC) -mmcu=$(MCU) -O$(OPT) -std=$(STD) -DF_CPU=$(F_CPU)UL -D$(strip $(DEVICE)) $(FLAGS_COMPILER) \
                                     -c $< -o $@
endef
define assembling
	@echo $<
	$(CC) -mmcu=$(MCU) -x assembler-with-cpp $(LSS_AFLAG) \
                                     -c $< -o $@
endef

# Compiling DEVICE_1
%$(call TEMPLATE,$(TARGET_1)).o: %.c
	$(compiling)
$(call OBJSA,$(TARGET_1)): $(ASRCS)
	$(assembling)

# Compiling DEVICE_2
%$(call TEMPLATE,$(TARGET_2)).o: %.c
	$(compiling)
$(call OBJSA,$(TARGET_2)): $(ASRCS)
	$(assembling)
	
# Compiling DEVICE_3
%$(call TEMPLATE,$(TARGET_3)).o: %.c
	$(compiling)
$(call OBJSA,$(TARGET_3)): $(ASRCS)
	$(assembling)


## Linking

define linking
	@echo --------------------------------
	@echo - - - - - - - Linking files for: $@
	@echo -

	$(CC) -mmcu=$(MCU) -Wall -O$(OPT) $(MAP_LFLAG) $(FLAGS_LINKER) \
                                     -o $@.elf $(call OBJS,$@)

	$(OBJCOPY) -O ihex -R .eeprom -R .fuse -R .lock -R .signature \
                                     $@.elf $@.hex
	$(generate_bin)
	$(generate_lss)
	$(generate_eeprom)
endef

# Building DEVICE_1
$(TARGET_1): $(eval MCU = $(MCU_1)) \
             $(eval F_CPU = $(F_CPU_1)) \
             $(eval DEVICE = $(DEVICE_1)) \
             print_target_1_compiling \
             $(call OBJS,$(TARGET_1))
	$(linking)
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

# Building DEVICE_2
$(TARGET_2): print_target_2_compiling \
             $(call OBJS,$(TARGET_2))
	$(linking)
	$(finalize)
#   Меняем конфигурацию для DEVICE_3
	$(eval MCU = $(MCU_3))
	$(eval F_CPU = $(F_CPU_3))
	$(eval DEVICE = $(DEVICE_3))

# Building DEVICE_3
$(TARGET_3): print_target_3_compiling \
             $(call OBJS,$(TARGET_3))
	$(linking)
	$(finalize)

#
CLEAN_LIST = $(call OBJS,$(1))  \
             $(basename $(call OBJSA,$(1))).lss  \
             $(1).elf  \
             $(1).map  \
             $(1).lss  \
             $(1).bin  \
             $(1).hex  \
             $(1)_eep.hex

PHONY += clean
clean:
	rm -rf $(call CLEAN_LIST,$(TARGET_1))  \
       $(call CLEAN_LIST,$(TARGET_2))  \
       $(call CLEAN_LIST,$(TARGET_3))

#

PHONY += flash
flash:
	avrdude -patmega168 -cstk500 -PCOM9 -e -Uflash:w:$(TARGET_1).hex:i
