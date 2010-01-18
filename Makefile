wlplayer:
	mxmlc -static-link-runtime-shared-libraries -compiler.optimize\
	      -compiler.strict -metadata.creator barbuza -metadata.title wlplayer\
	      -target-player 10 -output bin/wlplayer.swf src/CatPlayer.as

clean:
	rm bin/wlplayer.swf
