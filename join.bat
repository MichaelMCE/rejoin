@ECHO OFF
SET XBLDIR=r:\xblite
SET PATH=r:\xblite\bin;%PATH%
SET LIB=r:\xblite\lib
SET INCLUDE=r:\xblite\include
xmake -f join.mak all clean