package {
    
    import flash.events.*;
    import flash.net.URLRequest;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.MovieClip;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.external.ExternalInterface;
    import FramerateThrottler;
    import widgets.PEvent;
    import WlGui;
    
    public class WlPlayer extends MovieClip {
        // Required params
        private var playerID:String;
        private var soundFile:String;
        // Optional params
        private var maskFile:String;
        private var backFile:String;
        private var gWidth:Number;
        private var gHeight:Number;
        // Sound objects
        private var audioFactory:Sound;
        private var audioChannel:SoundChannel;
        private var audioTrans:SoundTransform;
        // Audio state and stuff
        private static const STATE_STOPPED:int   = 0;
        private static const STATE_PAUSED:int    = 1;
        private static const STATE_PLAYING:int   = 2;
        private var audioState:int = STATE_STOPPED;
        private var position:Number = 0;
        // GUI
        private var playerGui:WlGui;

        /**
         * Class contructor
         *
         */ 
        
        public function WlPlayer() {

            stage.focus = stage;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;            

            FramerateThrottler.initialize(stage, 1);
            
            var requiredVars:Array = ['soundFile', 'playerID'];
            
            requiredVars.map(function(name:String, index:Number, all:Array):void {
                                if (! stage.loaderInfo.parameters[name] ? true : false) {
                                    throw new Error('param ' + name + ' is required'); 
                                }
                                this[name] = stage.loaderInfo.parameters[name];
                             }, this);
            
            var optionalVars:Array = ['maskFile', 'backFile', 'gWidth', 'gHeight'];
                        
            optionalVars.map(function(name:String, index:Number, all:Array):void {
                                 if (stage.loaderInfo.parameters[name] ? true : false) {
                                    this[name] = stage.loaderInfo.parameters[name];
                                 }
                             }, this);
            
            if (!gWidth || !gHeight) {
                gWidth = stage.stageWidth;
                gHeight = stage.stageHeight;
            }
            
            playerGui = new WlGui(gWidth, gHeight);
            addChild(playerGui);

            audioFactory = new Sound();
            audioTrans = new SoundTransform(1);
                        
            if (backFile) {
                var backUrlReq:URLRequest = new URLRequest(backFile);
                var histBackLoad:Loader = new Loader();

                with (histBackLoad.contentLoaderInfo) {
                    addEventListener(Event.COMPLETE, histBackLoaded);
                    addEventListener(IOErrorEvent.IO_ERROR, histBackIOError);
                }
                
                histBackLoad.load(backUrlReq);
            }
            
            if (maskFile) {
                var maskUrlReq:URLRequest = new URLRequest(maskFile);
                var histMaskLoad:Loader = new Loader();

                with (histMaskLoad.contentLoaderInfo) {
                    addEventListener(Event.COMPLETE, histMaskLoaded);
                    addEventListener(IOErrorEvent.IO_ERROR, histMaskIOError);
                }

                histMaskLoad.load(maskUrlReq);
            }
        
            with (playerGui) {
                guiButtons.addEventListener(MouseEvent.CLICK, onSSWButtonClick);
                guiHistogram.addEventListener(PEvent.ABS_PERCENT, onHistogramClick);
                guiVolume.addEventListener(PEvent.ABS_PERCENT, onVolumeClick);
            }
            
            ExternalInterface.addCallback('pause', pauseHandler);
            ExternalInterface.addCallback('setVolume', volumeHandler);

            playerGui.guiVolume.level = 1;
        }
        
        /**
         * Setters/Getters
         *
         */ 
        
        private function get length():Number {
            return audioFactory.length * audioFactory.bytesTotal / audioFactory.bytesLoaded;
        }
        
        /**
         * Event handlers
         *
         */

        // Click events
        private function onSSWButtonClick(event:MouseEvent):void {
            if (audioState == STATE_STOPPED) {
                loadMP3();
                playMP3();
            } else if (audioState == STATE_PAUSED) {
                playMP3();
            } else if (audioState == STATE_PLAYING) {
                pauseMP3();
            }
        }
        
        private function onHistogramClick(event:PEvent):void {    
            if (audioState != STATE_STOPPED) {
                if (audioFactory.bytesLoaded > audioFactory.bytesTotal * event.percent) {
                    audioChannel.stop();
                    position = length * event.percent;
                    playMP3();
                }
            }
        }

        private function onVolumeClick(event:PEvent):void {
            ExternalInterface.call('AudioPlayer.onVolume', playerID, event.percent);
            audioTrans.volume = event.percent;
            if (audioChannel) {
                audioChannel.soundTransform = audioTrans;
            }
        }
        
        // sound factory events
        private function onLoadProgress(event:ProgressEvent):void {
            playerGui.guiHistogram.loadProgress = event.bytesLoaded / event.bytesTotal;
        }
        
        private function ioErrorHandler(event:IOErrorEvent):void {
            playerGui.guiButtons.state = 'wip';
        }
        
        private function onCompleatProgress(event:Event):void {
            audioFactory.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
            playerGui.guiHistogram.loadProgress = 1;
        }
        
        private function updatePosition(event:Event):void {
            playerGui.guiHistogram.playPosition = audioChannel.position / length;
        }        
        
        private function soundCompleteHandler(event:Event):void {
            removeEventListener(Event.ENTER_FRAME, updatePosition);
            audioChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
            position = 0;
        }

        // background loading events
        private function histBackLoaded(event:Event):void {
            var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
            playerGui.guiHistogram.histBack = loaderInfo.content as Bitmap;
        }
        
        private function histBackIOError(event:IOErrorEvent):void {
            playerGui.guiButtons.state = 'wip';
        }

        // mask loading events
        private function histMaskLoaded(event:Event):void {
            var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
            playerGui.guiHistogram.histMask = loaderInfo.content as Bitmap;
        }
        
        private function histMaskIOError(event:IOErrorEvent):void {
            playerGui.guiButtons.state = 'wip';
        }
        
        /**
         * Abstract shit
         *
         */ 
        
        private function loadMP3():void {
            audioFactory.load(new URLRequest(soundFile));
            audioFactory.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
            audioFactory.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            audioFactory.addEventListener(Event.COMPLETE, onCompleatProgress);
        }
                
        private function pauseMP3():void {
            position = audioChannel.position;
            audioChannel.stop();
            audioState = STATE_PAUSED;
            playerGui.guiButtons.state = 'play';
        }
        
        private function playMP3():void {
            ExternalInterface.call('AudioPlayer.onPlay', playerID);

            audioChannel = audioFactory.play(position, 0, audioTrans);
            audioChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
            addEventListener(Event.ENTER_FRAME, updatePosition);

            audioState = STATE_PLAYING;

            playerGui.guiButtons.state = 'pause';
            playerGui.guiHistogram.playPosition = audioChannel.position / length;
        }
        
        /**
         * JS calls handlers
         *
         */ 
        
        private function pauseHandler():void {
            if (audioState != STATE_STOPPED) {
                pauseMP3();
            }
        }

        private function volumeHandler(vol:Number):void {
            audioTrans.volume = vol;
            playerGui.guiVolume.level = vol;
            if (audioChannel) {
                audioChannel.soundTransform = audioTrans;
            }            
        }
    }
}