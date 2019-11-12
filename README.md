

	Rejoins files split by HJSplit or any other headerless file-splitter


	To use:
	join.exe -i "input filename" -o "output path+filename"
	input filename of the first file of the set, usually ending with .001
	path+filename must be contained within quotes, ie "c:\filename"
	
	eg;
	join.exe -i "d:\tmp\imagedata.dat.001" -o "c:\imagedata.dat"

	join.exe -i "d:\tmp\imagedata.dat.001" -o "n:\data\"
	output filename set to "n:\data\imagedata.dat"

	join.exe -i "d:\tmp\imagedata.dat.001"
	output filename set to "d:\tmp\imagedata.dat"

	Michael McElligott
	Oct' 2004
	
	
	Get HJSplit from (http://www.freebyte.com/hjsplit/) 
