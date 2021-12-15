OUTPUT = Tack
OUTDIR = Bin
SRCDIR = Src
OBJDIR = Obj

CC = gcc
CSTD = c99
CFLAGS := -std=$(CSTD) -Wall -Wextra -O0 -g3 -Wcast-align -Wlogical-op -Wmissing-include-dirs -Wredundant-decls -Wundef -fdata-sections -ffunction-sections -fmessage-length=0
DEFINES = -DUNICODE -D_UNICODE

rwildcard=$(foreach d,$(wildcard $(1:=/*)), $(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
getdirs=$(foreach d,$(wildcard $(1:=*/)), $(call getdirs,$d,$2) $d)

OBJS := $(patsubst $(SRCDIR)%.c, $(OBJDIR)%.o, $(call rwildcard,$(SRCDIR),*.c))
DEPS := $(patsubst %.o, %.d, $(OBJS))
-include $(DEPS)
DEPFLAGS = -MMD -MF $(@:.o=.d)

MKDIR = mkdir -p
DIRS := $(OUTDIR) $(subst $(SRCDIR),$(OBJDIR),$(call getdirs,$(SRCDIR)))
RM = rm -f

.PHONY: all release r debug d dirs clean fclean

all: dirs $(OUTDIR)/$(OUTPUT)

release: CFLAGS := -std=$(CSTD) -Wall -Wextra -O2 -g0 -ffunction-sections -fdata-sections -fmessage-length=0
release: DEFINES += -DNDEBUG
release: clean all

r: release

debug: DEFINES += -DDEBUG
debug: clean all

d: debug

$(OUTDIR)/$(OUTPUT): $(OBJS)
	@echo
	@echo Linking!
	@echo $(OBJS)
	$(CC) -o $(OUTDIR)/$(OUTPUT) -dead_strip $^

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@echo Compiling $<
	$(CC) $(CFLAGS) -w -o $(@:.o=_e.c) -E $<
	$(CC) $(CFLAGS) -w -o $(@:.o=.s) -S $<
	$(CC) $(CFLAGS) -o $@ -c $< $(DEPFLAGS)

dirs: $(DIRS)

$(DIRS):
	$(MKDIR) $@

clean:
	$(RM) $(OUTDIR)/$(OUTPUT) $(OBJS)

fclean: clean
	$(RM) $(OBJS:.o=_e.c) $(OBJS:.o=.s) $(OBJS:.o=.d)
	rmdir $(call getdirs,$(OBJDIR))
