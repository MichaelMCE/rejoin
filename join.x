

'	Rejoins files split by HJSplit (http://www.freebyte.com/hjsplit/) or any other
'	headerless file-splitter

'	to use:
'	join.exe -i "input filename" -o "output path+filename"
'	input filename of the first file of the set, usually ending with .001
'	path+filename must be contained within quotes, ie "c:\filename"
'	
'	e.g.
'	join.exe -i "d:\tmp\imagedata.dat.001" -o "c:\imagedata.dat"
'	or
'	join.exe -i "d:\tmp\imagedata.dat.001" -o "n:\data\"
'	output filename set to "n:\data\imagedata.dat"
'	or
'	join.exe -i "d:\tmp\imagedata.dat.001"
'	output filename set to "d:\tmp\imagedata.dat"
'
'	Michael McElligott
'	31/10/2004
'	

PROGRAM "join"
VERSION "0.1"
CONSOLE

	IMPORT "kernel32"
	IMPORT "msvcrt"
	
	
' EXTERNAL CFUNCTION  GIANT _lseeki64 (XLONG, GIANT, XLONG)
' EXTERNAL CFUNCTION  GIANT _telli64 (XLONG)

DECLARE FUNCTION main ()
DECLARE FUNCTION read_file (fp, GIANT offset, lpbuffer, GIANT size)
DECLARE FUNCTION open_file (lpfilename, flags)
DECLARE FUNCTION close_file (file)
DECLARE FUNCTION write_file (hfile,buffer, GIANT nbytes)
DECLARE FUNCTION GIANT GetFileSize (STRING fileName)
DECLARE FUNCTION GetCommandLine (STRING in,STRING out)
DECLARE FUNCTION getLastSlash(str$, stop)
DECLARE FUNCTION GetCommandLineArguments (argc, argv$[])
DECLARE FUNCTION DecomposePathname (pathname$, @path$, @parent$, @filename$, @file$, @extent$)


FUNCTION main ()
	STRING infile,outfile,file
	STRING path,ext
	'UBYTE buffer[]
	XLONG buffer
	GIANT tsize
	GIANT size


	GetCommandLine (@infile,@outfile)
	DecomposePathname (infile, @path, parent$, filename$,@file, @ext)
	'IF ext != ".001" THEN RETURN 0
	infile = path+"\\"+file

	IFZ outfile THEN outfile = infile
	IF RIGHT$(outfile,1) == ":" THEN outfile = outfile + "\\"
	IF RIGHT$(outfile,1) == "\\" || RIGHT$(outfile,1) == "/" THEN
		outfile = outfile + file
	END IF

	houtfile = open_file (&outfile,&"wb")
	IFZ houtfile THEN RETURN 0

	ct = 1
	DO
		file = infile+"."+RIGHT$("000"+STRING$(ct),3)
		size = GetFileSize (file)
		IFZ size THEN EXIT DO
		
		PRINT size,file

		hinfile = open_file (&file,&"rb")
		IFZ hinfile THEN EXIT DO

		' DIM buffer[size]
		buffer = malloc(size + 1)
		IF (!buffer) THEN
			PRINT "out of memory. failed to allocate";size;" bytes"
			RETURN
		ENDIF
		
		PRINT "reading";size;" bytes..."
		read_file(hinfile,0,buffer,size)
		close_file(hinfile)
		
		PRINT "writing";size;" bytes..."
		write_file(houtfile,buffer,size)
		free(buffer)
		
		tsize = tsize + size
		INC ct
	LOOP

	'DIM buffer[]
	close_file (houtfile)

	PRINT "\ntotal bytes read:";tsize;" over ";ct-1;" files"
	PRINT GetFileSize (outfile);" ";outfile
	

END FUNCTION

FUNCTION GetCommandLine (STRING in,STRING out)


	in = ""
	out = ""
	GetCommandLineArguments (@argc, @argv$[])

	IF (argc > 1) THEN
		FOR i = 1 TO argc-1												' for all command line arguments
			arg$ = TRIM$(argv$[i])										' get next argument
			IF (LEN (arg$) = 2) THEN									' if not empty
				IF (arg${0} = '-') THEN									' command line switch?
					SELECT CASE LCASE$(CHR$(arg${1}))					' which switch?
						CASE "i"	:in = TRIM$(argv$[i+1])				' input filename
						CASE "o"	:out = TRIM$(argv$[i+1])			' output filename
					END SELECT
				END IF
			END IF
		NEXT i
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION GIANT GetFileSize (STRING fileName)
	GIANT pos
	GIANT size
	
	fp = open_file (&fileName, 0)
	IF fp THEN
		pos = 0
		x = fseek(fp, 0, 2)   ' SEEK_END
		size = ftell(fp)
	END IF
	close_file (fp)

	RETURN size
END FUNCTION

FUNCTION read_file (fp, GIANT offset,lpbuffer, GIANT size)

	IFZ fp THEN RETURN 0
	fsetpos (fp, &offset)
	fread (lpbuffer, 1, size, fp)

END FUNCTION

FUNCTION open_file (lpfilename, flags)


	IFZ lpfilename THEN RETURN $$FALSE
	IFZ flags THEN
		type = &"rb"
	ELSE
		type = flags
	END IF
	
	hfile = fopen (lpfilename, type)
	IFZ hfile THEN
		RETURN 0
	ELSE
		RETURN hfile
	END IF

END FUNCTION

FUNCTION close_file (file)

	IF file THEN
		fclose (file)
		RETURN $$TRUE
	ELSE
		RETURN $$FALSE
	END IF

END FUNCTION

FUNCTION write_file (hfile, buffer, GIANT nbytes)

	'_write (hfile, buffer, nbytes)
	foffset = 0
	fgetpos (hfile,&foffset)
	
	IF (fwrite (buffer, 1, nbytes, hfile) < nbytes) THEN
		RETURN -1
	ELSE
		RETURN foffset
	END IF
END FUNCTION


FUNCTION getLastSlash(str$, stop)
	$PathSlash$   = "\\" 


	IF stop < 0 THEN
		slash1 = RINSTR(str$, "/")
		slash2 = RINSTR(str$, $PathSlash$)
	ELSE
		slash1 = RINSTR(str$, "/", stop)
		slash2 = RINSTR(str$, $PathSlash$, stop)
	END IF
	IFZ slash1 THEN
		RETURN slash2
	ELSE
		RETURN MAX(slash1, slash2)
	END IF
	
END FUNCTION

FUNCTION DecomposePathname (pathname$, @path$, @parent$, @filename$, @file$, @extent$)
'
	path$ = ""
	file$ = ""
	extent$ = ""
	parent$ = ""
	filename$ = ""
	name$ = TRIM$ (pathname$)
	dot = RINSTR (name$, ".")
	slash = getLastSlash(name$, -1)
	
	IF slash THEN preslash = getLastSlash(name$, slash-1)
	IF (dot < slash) THEN dot = 0
'
	filename$ = MID$ (name$, slash+1)
	IFZ dot THEN
		file$ = filename$
	ELSE
		file$ = MID$ (name$, slash+1, dot-slash-1)
		extent$ = MID$ (name$, dot)
	END IF
'
	IF slash THEN
		path$ = LEFT$ (name$, slash-1)
		IF preslash THEN
			parent$ = MID$ (name$, preslash+1, slash-preslash-1)
		ELSE
			parent$ = LEFT$ (name$, slash-1)
		END IF
	END IF
	
END FUNCTION

FUNCTION GetCommandLineArguments (argc, argv$[])
	SHARED  setarg
	SHARED  setargc
	SHARED  setargv$[]


	DIM argv$[]
	inc = argc
	argc = 0
'
' return already set argc and argv$[]
'
	IF (inc >= 0) THEN
		IF setarg THEN
			argc = setargc
			upper = UBOUND (setargv$[])
			ucount = upper + 1
			IF (argc > ucount) THEN argc = ucount
			IF argc THEN
				DIM argv$[upper]
				FOR i = 0 TO upper
					argv$[i] = setargv$[i]
				NEXT i
			END IF
			RETURN ($$FALSE)
		END IF
	END IF
'
' get original command line arguments from system
'
	argc = 0
	index = 0
	DIM argv$[]
	addr = GetCommandLineA()			' address of full command line
	line$ = CSTRING$(addr)
	
'	PRINT "cmd line",line$
'
	done = 0
	IF addr THEN
		DIM argv$[1023]
		quote = $$FALSE
		argc = 0
		empty = $$FALSE
		I = 0
		DO
			cha = UBYTEAT(addr, I)
			IF (cha < ' ') THEN EXIT DO

			IF (cha = ' ') AND NOT quote THEN
				IF NOT empty THEN
					INC argc
					argv$[argc] = ""
					empty = $$TRUE
				END IF
			ELSE
				IF (cha = '"') THEN
					quote = NOT quote
				ELSE
					argv$[argc] = argv$[argc] + CHR$(cha)
					empty = $$FALSE
				END IF
			END IF
			INC I
		LOOP
		IF NOT empty THEN
			argc = argc + 1
		END IF
		REDIM argv$[argc-1]

	END IF
'
' if input argc < 0 THEN don't overwrite current values
'
	IF ((setarg = $$FALSE) OR (inc >= 0)) THEN
		setarg = $$TRUE
		setargc = argc
		DIM setargv$[]
		IF (argc > 0) THEN
			DIM setargv$[argc-1]
			FOR i = 0 TO argc-1
				setargv$[i] = argv$[i]
			NEXT i
		END IF
	END IF
	
END FUNCTION

END PROGRAM