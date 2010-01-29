package {

    import flash.system.Security;
    import flash.external.ExternalInterface;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.ProgressEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.net.URLRequest;
    import flash.utils.Timer;
	
	import org.casalib.util.StageReference;
	import org.casalib.util.FlashVarUtil;
	import org.casalib.display.CasaSprite;
	import org.casalib.display.CasaMovieClip;
	import org.casalib.load.ImageLoad;
	import org.casalib.events.LoadEvent;
		
	
    public class WlPlayer extends CasaMovieClip {

		// fashvars
		
        private var playerWidth:Number = 500;
        private var playerHeight:Number = 80;
        private var playerBackgroundColor:Number = 0xFFFFFF;
        
        private var buttonWidth:Number = 80;
        private var buttonHeight:Number = 80;
        
        private var loadingIndicatorColor:Number = 0x666666;
        private var loadingIndicatorUpdateInterval:Number = 400;
        
        private var progressIndicatorColor:Number = 0xFF0000;
        private var progressIndicatorUpdateInterval:Number = 400;
        
		private var url:String;
		private var imageUrl:String;
		private var backgroundUrl:String;
        private var playerID:String;
        
		// end flashvars
		
		
        private var loadingWidth:Number;
        private var loadingY:Number;
        
		private var bgSprite:CasaSprite;
        private var playStarted:Boolean = false;
        private var song:SoundChannel;
        private var request:URLRequest;
        private var paused:Boolean = false;
        private var stopped:Boolean = true;
        private var position:Number;
        private var soundFactory:Sound;
        private var imageLoader:Loader;
        private var progressLine:CasaSprite;
        private var loadingSprite:CasaSprite;
        private var progressUpdateTimer:Timer;
        private var loadingProgress:Number;
        private var loadingUpdateTimer:Timer;
        private var btnSprite:CasaSprite;
		private var _imageLoad:ImageLoad;
		private var _bgLoad:ImageLoad;
		
        [Embed(source='../assets/play.png')]
        private var playImg:Class;
        private var playBitmap:BitmapData;
        
        [Embed(source='../assets/pause.png')]
        private var pauseImg:Class;
        private var pauseBitmap:BitmapData; 
        
		
        public function WlPlayer() {
            
			StageReference.setStage(stage);
			
			url = FlashVarUtil.getValue('url');
			imageUrl = FlashVarUtil.getValue('imageUrl');
			backgroundUrl = FlashVarUtil.getValue('backgroundUrl');
			playerID = FlashVarUtil.getValue('playerID');
			
			var optionalVars:Array = ['playerWidth', 'playerHeight', 'playerBackgroundColor',
									  'buttonWidth', 'buttonHeight',
									  'loadingIndicatorColor', 'loadingIndicatorUpdateInterval',
									  'progressIndicatorColor',
									  'progressIndicatorUpdateInterval'];
			
			optionalVars.map(function(name:String, index:Number, all:Array):void {
				if (FlashVarUtil.hasKey(name)) {
					this[name] = Number(FlashVarUtil.getValue(name));
				}
			}, this);
			
            with (StageReference.getStage()) {
                align = StageAlign.TOP_LEFT;
                scaleMode = StageScaleMode.NO_SCALE;
                addEventListener(MouseEvent.CLICK, onMouseClick);
            }
            with (graphics) {
                beginFill(playerBackgroundColor);
                drawRect(0, 0, playerWidth, playerHeight);
                endFill();
            }
            
            loadingWidth = playerWidth - buttonWidth;
            loadingY = playerHeight;
            
            playBitmap = new playImg().bitmapData;
            pauseBitmap = new pauseImg().bitmapData;
            btnSprite = new CasaSprite();
            addChild(btnSprite);
            
            progressUpdateTimer = new Timer(progressIndicatorUpdateInterval);
            progressUpdateTimer.addEventListener(TimerEvent.TIMER,
                                                 drawProgressLine);
            
            loadingUpdateTimer = new Timer(loadingIndicatorUpdateInterval);
            loadingUpdateTimer.addEventListener(TimerEvent.TIMER,
                                                onLoadProgress);
            
            drawPlay();
            createLoadingSprite();
            createProgressLine();
			
			_bgLoad = new ImageLoad(backgroundUrl);
			_bgLoad.addEventListener(LoadEvent.COMPLETE, function(event:LoadEvent):void {
				bgSprite = new CasaSprite();
				bgSprite.cacheAsBitmap = true;
				with (bgSprite.graphics) {
					beginBitmapFill(_bgLoad.contentAsBitmapData);
					drawRect(0, 0, playerWidth, playerHeight);
					endFill();
				}
				_imageLoad = new ImageLoad(imageUrl);
				_imageLoad.addEventListener(LoadEvent.COMPLETE, function(event:LoadEvent):void {
					_imageLoad.loaderInfo.content.width = playerWidth - buttonWidth;
					_imageLoad.loaderInfo.content.height = playerHeight;
					var maskMc:CasaMovieClip = new CasaMovieClip();
					maskMc.x = buttonWidth;
					maskMc.addChild(_imageLoad.loader);
					maskMc.cacheAsBitmap = true;
					addChild(maskMc);
					bgSprite.mask = maskMc;
					addChild(bgSprite);
					setChildIndex(progressLine, numChildren - 1);
				});
				_imageLoad.start();
			});
			_bgLoad.start();
			
			ExternalInterface.addCallback('pause', function():void {
			    _pause();
			});
			ExternalInterface.addCallback('play', function():void {
                if (!stopped) {
                    _play();
                } else {
                    playMP3();
                }
			});
			
        }
                
        private function get length():Number {
            return soundFactory.length * soundFactory.bytesTotal / soundFactory.bytesLoaded;
        }
        
        private function get loaded():Boolean {
            return soundFactory && 
                soundFactory.bytesLoaded == soundFactory.bytesTotal;
        }


        private function createProgressLine():void {
            progressLine = new CasaSprite();
            progressLine.x = buttonWidth;
            addChild(progressLine);
        }
        
        private function createLoadingSprite():void {
            loadingSprite = new CasaSprite();
            loadingSprite.x = buttonWidth;
            with (loadingSprite.graphics) {
                beginFill(loadingIndicatorColor, .5);
                drawRect(0, 0, playerWidth - buttonWidth, playerHeight);
                endFill();
            }
            addChild(loadingSprite);
        }
        
        private function drawPause():void {
            with (btnSprite.graphics) {
                clear();
                beginBitmapFill(pauseBitmap);
                drawRect(0, 0, buttonWidth, buttonHeight);
                endFill();
            }
        }
        
        private function drawPlay():void {
            with (btnSprite.graphics) {
                clear();
                beginBitmapFill(playBitmap);
                drawRect(0, 0, buttonWidth, buttonHeight);
                endFill();
            }
        }
                
        private function onMouseClick(event:MouseEvent):void {
            if (event.stageX <= buttonWidth && event.stageY <= buttonHeight) {
                pause();
            } else if (!paused && !stopped &&
                       event.stageX <= playerWidth &&
                       event.stageY <= playerHeight) {
                if (loaded) {
                    var requestedPos:Number = (event.stageX - buttonWidth) /
                        (playerWidth - buttonWidth);
                    if (soundFactory.bytesLoaded >
                        soundFactory.bytesTotal * requestedPos) {
                        song.stop();
                        song = soundFactory.play(length * requestedPos);
                    }
                }
            }
        }
        
        private function drawProgressLine(event:TimerEvent):void {
            with (progressLine.graphics) {
                clear();
                beginFill(progressIndicatorColor, .5);
                drawRect(0, 0, song.position *
                    (playerWidth - buttonWidth) / length, playerHeight);
                endFill();
            }
        }

        private function playMP3():void {
            if (playStarted) {
                return;
            }
            ExternalInterface.call('AudioPlayer.onPlay', playerID);
            playStarted = true;
            stopped = false;
            paused = false;
            position = 0;
            var request:URLRequest = new URLRequest(url);
            soundFactory = new Sound();
            soundFactory.load(request);
            song = soundFactory.play();
            loadingUpdateTimer.start();
            song.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
            drawPause();
            progressUpdateTimer.start();
        }
                
        private function onLoadProgress(event:TimerEvent):void {
            loadingSprite.x = buttonWidth + soundFactory.bytesLoaded * loadingWidth / soundFactory.bytesTotal;
            if (soundFactory.bytesLoaded == soundFactory.bytesTotal) {
                loadingUpdateTimer.stop();
            }
        }
                
        private function soundCompleteHandler(event:Event):void {
            position = 0;
        }
        
        private function pause():void {
            if (!stopped) {
                if (!paused) {
                    _pause();
                } else {
                    _play();
                }
            } else {
                playMP3();
            }
        }
        
        private function _pause():void {
            ExternalInterface.call('AudioPlayer.onPause', playerID);
            paused = true;
            position = song.position;
            song.stop();
            drawPlay();
            progressUpdateTimer.stop();
        }
        
        private function _play():void {
            ExternalInterface.call('AudioPlayer.onPlay', playerID);
            paused = false;
            song = soundFactory.play(position);
            song.addEventListener(Event.SOUND_COMPLETE,
                                  soundCompleteHandler);
            drawPause();
            progressUpdateTimer.start();
        }
            
    }
}