# Note: the next six lines are modified by the makefile-generator in xcowlite.x.
APP       = join
LIBS      =  kernel32.lib msvcrt.lib xst_s.lib
OBJS      = $(APP).obj
START     = START /W
XBLITE    = xblite
SUBSYSTEM = CONSOLE

.SUFFIXES: .x .xl .xbl

# The linker
LD          = link

# Flags for the linker
LDFLAGS     = /entry:WinMain /NODEFAULTLIB /SUBSYSTEM:$(SUBSYSTEM) /INCREMENTAL:NO /RELEASE /NOLOGO /OPT:REF /ALIGN:4096

# Needed resources
RESOURCES   = $(APP).rbj

# The assembler
AS          = goasm

# All needed standard libraries.
STDLIBS     = xblib.lib kernel32.lib advapi32.lib user32.lib gdi32.lib comdlg32.lib winspool.lib

# The main directory for \xblite
DIR         = $(XBLDIR)

# Default rules to compile a XBLite files into assembly files.
.x.asm: 
	$(XBLITE) $?

.xl.asm:
	$(XBLITE) $?

.xbl.asm:
	$(XBLITE) $?

all: $(APP).exe

$(APP).exe: $(APP).obj $(RESOURCES)
	$(LD) $(LDFLAGS) -out:$(APP).exe $(OBJS) $(RESOURCES) $(LIBS) $(STDLIBS)

$(APP).rbj: $(APP).res
	cvtres -i386 -NOLOGO $(APP).res -o $(APP).rbj

$(APP).res: $(APP).rc
	rc -i$(DIR)\images -r -fo $(APP).res $(APP).rc

$(APP).obj: $(APP).asm
	$(AS) $(APP).asm

#$(APP).asm: $(APP).x
#	$(START) $(XBLITE) $(APP).x


clean:
	IF EXIST $(APP).res DEL $(APP).res
	IF EXIST $(APP).rbj DEL $(APP).rbj
	IF EXIST $(APP).obj DEL $(APP).obj
	IF EXIST $(APP).asm DEL $(APP).asm
	IF EXIST $(DIR)\programs\$(APP).exe DEL $(DIR)\programs\$(APP).exe
	COPY $(APP).exe $(DIR)\programs\$(APP).exe
	START $(DIR)\programs\$(APP).exe
