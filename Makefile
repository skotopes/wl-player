wlplayer:
	mxmlc -static-link-runtime-shared-libraries -compiler.optimize\
	      -compiler.strict -metadata.creator barbuza\
	      -library-path+=libs/casa.swc\
              -library-path+=libs/ru.barbuza.EventJoin.swc\
              -metadata.title wlplayer\
	      -target-player 10 -output bin/wlplayer.swf src/WlPlayer.as

clean:
	rm bin/wlplayer.swf
