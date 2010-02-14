wlplayer:
	mxmlc -debug=true -static-link-runtime-shared-libraries -compiler.optimize\
	      -compiler.strict -metadata.creator barbuza\
              -metadata.title wlplayer\
	      -target-player 10 -output bin/wlplayer.swf src/WlPlayer.as 2>&1 | iconv -f "MacCyrillic" -t utf8

clean:
	rm bin/wlplayer.swf
