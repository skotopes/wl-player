package {    
    import flash.external.ExternalInterface;
    import flash.events.*;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.net.URLRequest;
    import flash.utils.Timer;
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.display.LoaderInfo
    import flash.display.MovieClip;
    import flash.display.Sprite;
    
    import org.casalib.display.CasaSprite;
    import org.casalib.display.CasaMovieClip;
    import org.casalib.load.ImageLoad;
    import org.casalib.load.CasaLoader;
    import org.casalib.events.LoadEvent;    
    import org.casalib.util.FlashVarUtil;
    import org.casalib.util.StageReference;

    import WlGui;

    public class WlPlayer extends CasaMovieClip {
        
        private var soundFile:String;
        private var maskFile:String;
        private var backFile:String;
        private var playerID:String;

        private var playerWidth:Number = 600;
        private var playerHeight:Number = 80;
        private var playerBackgroundColor:Number = 0xFFFFFF;
        
        private var buttonWidth:Number = 80;
        private var buttonHeight:Number = 80;

        private var playStarted:Boolean = false;
        private var song:SoundChannel;
        private var request:URLRequest;
        private var paused:Boolean = false;
        private var stopped:Boolean = true;
        private var position:Number;
        private var soundFactory:Sound;
        private var progressUpdateTimer:Timer;
        private var loadingProgress:Number;
        private var loadingUpdateTimer:Timer;
        
        private var playerGui:WlGui;
        
        /**
         * Class contructor
         *
         */ 
        
        public function WlPlayer() {
            StageReference.setStage(stage);

            var requiredVars:Array = ['soundFile', 'maskFile',
                                      'backFile', 'playerID'];
            
            requiredVars.map(function(name:String, index:Number, all:Array):void {
                if (! FlashVarUtil.hasKey(name)) {
                    throw new Error('param ' + name + ' is required'); 
                }
                this[name] = FlashVarUtil.getValue(name);
            }, this);
            
            var optionalVars:Array = ['playerWidth', 'playerHeight',
                                      'buttonWidth', 'buttonHeight',
                                      'playerBackgroundColor',
                                      'loadingIndicatorColor',
                                      'loadingIndicatorUpdateInterval',
                                      'progressIndicatorColor',
                                      'progressIndicatorUpdateInterval'];
            
            optionalVars.map(function(name:String, index:Number, all:Array):void {
                if (FlashVarUtil.hasKey(name)) {
                    this[name] = Number(FlashVarUtil.getValue(name));
                }
            }, this);
            
            playerGui = new WlGui(playerWidth, playerHeight);
            addChild(playerGui);

            /**
             * Load mask and spectrogram
             */
            var backUrlReq:URLRequest = new URLRequest(backFile);
            var maskUrlReq:URLRequest = new URLRequest(maskFile);            
            var histBackLoad:Loader = new Loader();
            var histMaskLoad:Loader = new Loader();
            histBackLoad.contentLoaderInfo.addEventListener(Event.COMPLETE,
                                                            histBackLoaded);
            histMaskLoad.contentLoaderInfo.addEventListener(Event.COMPLETE,
                                                            histMaskLoaded);
            histBackLoad.load(backUrlReq);
            histMaskLoad.load(maskUrlReq);
            
            with (playerGui.guiButtons) {
                addEventListener(MouseEvent.CLICK, onSSWButtonClick);
            }

            with (playerGui.guiHistogram) {
                addEventListener(MouseEvent.CLICK, onHistogramClick);
            }
            
            ExternalInterface.addCallback('pause', function():void {
                if (playStarted) {
                    _pause();
                }
            });
            
            ExternalInterface.addCallback('play', function():void {
                if (!stopped) {
                    _play();
                } else {
                    playMP3();
                }
            });            
        }
                
        /**
         * Abstract shit
         * so lonely here, probably it has sense to remove it at all? 
         */ 
        
        private function get length():Number {
            return soundFactory.length * soundFactory.bytesTotal / soundFactory.bytesLoaded;
        }
        
        /**
         * On click handlers
         *
         */ 
        
        private function onSSWButtonClick(event:MouseEvent):void {
            pause();
        }
        
        private function onHistogramClick(event:MouseEvent):void {    
            if (!stopped) {
                var requestedPos:Number = (event.stageX - playerHeight) / (playerWidth - playerHeight);
                if (soundFactory.bytesLoaded > soundFactory.bytesTotal * requestedPos) {
                    song.stop();
                    position = length * requestedPos;
                    _play();
                }
            }
        }

        /**
         * Other Events handlers 
         *
         */ 
        
        private function onLoadProgress(event:ProgressEvent):void {
            playerGui.guiHistogram.setProgress(event.bytesLoaded / event.bytesTotal);
        }
        
        private function onCompleatProgress(event:Event):void {
            playerGui.guiHistogram.setProgress(1);
        }
        
        private function updatePosition(event:TimerEvent):void {
            playerGui.guiHistogram.setPosition(song.position / length);
        }        
        
        private function soundCompleteHandler(event:Event):void {
            position = 0;
        }

        private function histBackLoaded(event:Event):void {
            var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
            playerGui.guiHistogram.histBack = loaderInfo.content as Bitmap;
            trace("back is loaded");
        }

        private function histMaskLoaded(event:Event):void {
            var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
            playerGui.guiHistogram.histMask = loaderInfo.content as Bitmap;
            trace("mask is loaded");
        }
        
        /**
         * Abstract shit
         *
         */ 
        
        private function playMP3():void {
            if (playStarted) {
                return;
            }
            ExternalInterface.call('AudioPlayer.onPlay', playerID);
            playStarted = true;
            stopped = false;
            paused = false;
            position = 0;
            var request:URLRequest = new URLRequest(soundFile);
            soundFactory = new Sound();
            soundFactory.load(request);
            soundFactory.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
            soundFactory.addEventListener(Event.COMPLETE, onCompleatProgress);
            
            song = soundFactory.play();
            song.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
            
            progressUpdateTimer = new Timer(400);
            progressUpdateTimer.addEventListener(TimerEvent.TIMER, updatePosition);
            progressUpdateTimer.start();

            playerGui.guiButtons.state = 'pause'; // setStatePause();
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
            playerGui.guiButtons.state = 'play'; // setStatePlay();
        }
        
        private function _play():void {
            ExternalInterface.call('AudioPlayer.onPlay', playerID);
            paused = false;
            song = soundFactory.play(position);
            song.addEventListener(Event.SOUND_COMPLETE,
                                  soundCompleteHandler);
            playerGui.guiButtons.state = 'pause'; // setStatePause();
            playerGui.guiHistogram.setPosition(song.position / length);
        }
            
    }
}