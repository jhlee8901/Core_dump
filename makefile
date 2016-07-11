#***************************COPYRIGHT INFORMATION******************************
#* Copyright (c)  SK Hynix memory solutions, Inc.  All rights reserved.       *
#*                                                                            *
#* This file is the Confidential and Proprietary product of                   *
#* SK Hynix memory solutions, Inc.  Any unauthorized use, reproduction        *
#* or transfer of this file is strictly prohibited.                           *
#******************************************************************************
#you can not have empty line between VARIABLE definition

SRC_PATH = .\source
OUT_PATH = .\out
OBJ_PATH = $(OUT_PATH)\obj
OUT_NAME = mini


# Add source file name
ASMS := $(SRC_PATH)/start.s \
		$(SRC_PATH)/reset.s \
		$(SRC_PATH)/dump_reg.s \

SRCS := $(SRC_PATH)/main.c \
		$(SRC_PATH)/retarget.c \

# Added header path
INCL := $(SRC_PATH) \

######################################
# Build환경 (Win32, Linux)
# Run 환경 (ARM1, ARM2, WIN32)

AS  = armasm
CC  = armcc
LD  = armlink
CPP = armcpp

OBJS = $(addprefix $(OBJ_PATH)/,$(notdir $(SRCS:.c=.o))) $(addprefix $(OBJ_PATH)/,$(notdir $(ASMS:.s=.o)))

DEPS = $(OBJS:.o=.d)

TARGET = $(OUT_PATH)\$(OUT_NAME)

ASFLAGS = -g --cpu Cortex-R5
#ASFLAGS = --pd "TCM SETL {TRUE}"  -g --cpu Cortex-R5 --fpu None $(addprefix -i,$(INCL)) --apcs /interwork

CCFLAGS =  --depend_dir=$(OBJ_PATH) --no_depend_system_headers --md --cpu Cortex-R5 $(addprefix -I, $(INCL)) --c99 --gnu
CCFLAGS += --diag_error=549,193,47 --diag_suppress=951,1295

CCFLAGS += -O0 -g #--thumb
#CCFLAGS += -O2 --apcs /interwork -g --split_sections
#####CCFLAGS += -O2 --apcs /interwork -o main.o main.c
#CCFLAGS += -D_TARGET_HR5_

LDFLAGS = --entry=vector_table --cpu=cortex-r5 --scatter=$(SCAT_FILE) --remove --callgraph --callgraph_output=text --map --verbose --info=sizes --info=totals --info=unused --info=compression --info=stack --info=inline --list=$(TARGET).lst --library_type=microlib
#LDFLAGS = --entry=vector_table --info totals --info unused --info sizes --callgraph --scatter $(SCAT_FILE) --map --symbols  --list $(TARGET).lst

LIBS =

SCAT_FILE = mini.scat

#default:
#	echo default
all: directory $(OBJS) $(TARGET).axf $(TARGET).bin
	@if exist $(TARGET).axf echo Build completed

directory:
	@if not exist $(OUT_PATH) mkdir $(OUT_PATH)
	@if not exist $(subst /,\,$(OBJ_PATH)) mkdir $(subst /,\,$(OBJ_PATH))

rebuild: clean all

clean:
	@del $(OUT_PATH)\*.o $(OUT_PATH)\*.a $(OUT_PATH)\*.dat $(OUT_PATH)\*.htm $(OUT_PATH)\*.d /s
	@del $(TARGET).axf $(TARGET).bin
#@del $(TARGET).axf $(TARGET).bin $(TARGET).hex $(TARGET)_???.hex $(TARGET).txt $(TARGET)_???.txt $(TARGET).lst $(TARGET).sym $(TARGET).asm

cleanall:
	@del $(OUT_PATH)\*.o $(OUT_PATH)\*.a $(OUT_PATH)\*.dat $(OUT_PATH)\*.htm $(OUT_PATH)\*.d $(OUT_PATH)\*.axf $(OUT_PATH)\*.bin $(OUT_PATH)\*.hex $(OUT_PATH)\*.txt $(OUT_PATH)\*.lst $(OUT_PATH)\*.sym $(OUT_PATH)\*.asm /s
#@del $(TARGET).axf $(TARGET).bin $(TARGET).hex $(TARGET)_???.hex $(TARGET).txt $(TARGET)_???.txt $(TARGET).lst $(TARGET).sym $(TARGET).asm
#@if exist $(OUT_PATH) @rmdir /S /Q $(OUT_PATH)

#add option to make disassembled version (soc_lite_asm.txt) and list of all variables (soc_lite_vars.txt)
map:
	@fromelf -c $(TARGET).axf -o soc_lite_asm.txt

parts:
	@echo see platform.h for nandpart description

$(TARGET).axf: $(OBJS)
	$(LD) $(OBJS) $(LIBS) $(LDFLAGS) -o $(TARGET).axf

$(TARGET).bin: $(TARGET).axf
	fromelf $(TARGET).axf --bin -o $(TARGET).bin
	fromelf $(TARGET).axf --i32 -o $(TARGET)_i32.hex
	fromelf $(TARGET).axf --vhx --32x1 -o $(TARGET)_vhx.hex
	fromelf $(TARGET).axf -c -o $(TARGET).asm
	fromelf $(TARGET).axf -s -o $(TARGET).sym
	fromelf $(TARGET).axf -a --select * -o $(TARGET)_var.txt
	fromelf $(TARGET).axf -z

#	elf2hex -Mx $(TARGET).axf -o  $(TARGET).mif
#	copy $(TARGET).axf $(TARGET).axf

VPATH=$(SRC_PATH)

$(OBJ_PATH)/%.o: %.c
	$(CC) -c $(CCFLAGS) $< -o $@

$(OBJ_PATH)/%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

-include $(DEPS)
