MCFLAGS = -static-link-runtime-shared-libraries -compiler.optimize -compiler.strict -target-player 11.1 
MCMETA = -metadata.creator skotopes -metadata.title WlPlayer -metadata.publisher skotopes
SOURCE = src/WlPlayer.as
OUTPUT = -output bin/wlplayer.swf

wlplayer:
	mxmlc $(MCFLAGS) $(MCMETA) $(OUTPUT) $(SOURCE) 2>&1 | iconv -f "MacCyrillic" -t utf8

debug:
	mxmlc -debug=true $(MCFLAGS) $(MCMETA) $(OUTPUT) $(SOURCE) 2>&1 | iconv -f "MacCyrillic" -t utf8

clean:
	rm bin/wlplayer.swf
