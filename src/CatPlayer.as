package {

    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.*;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.net.URLRequest;
    import flash.utils.Timer;
    
    public class CatPlayer extends Sprite {
                
        private const playerWidth:Number = 500;
        private const playerHeight:Number = 82;
        private const playerBackgroundColor:Number = 0x000000;
        
        private const buttonWidth:Number = 80;
        private const buttonHeight:Number = 80;
        
        private const loadingIndicatorWeight:Number = 2;
        private const loadingIndicatorColor:Number = 0x0000FF;
        private const loadingIndicatorUpdateInterval:Number = 400;
        
        private const progressIndicatorWeight:Number = 2;
        private const progressIndicatorColor:Number = 0xFF0000;
        private const progressIndicatorUpdateInterval:Number = 400;
        
        
        
        private var url:String;
        private var imageUrl:String;
        
        private var song:SoundChannel;
        private var request:URLRequest
        private var paused:Boolean = false;
        private var stopped:Boolean = true;
        private var position:Number;
        private var soundFactory:Sound;
        private var imageLoader:Loader;
        private var progressLine:Sprite;
        private var progressUpdateTimer:Timer;
        private var loadingProgress:Number;
        private var loadingUpdateTimer:Timer;
        
        [Embed(source='../assets/play.png')]
        private var playImg:Class;
        private var playBitmap:BitmapData;
        
        [Embed(source='../assets/pause.png')]
        private var pauseImg:Class;
        private var pauseBitmap:BitmapData; 
        
        public function CatPlayer() {
            
            url = String(loaderInfo.parameters.url);
            imageUrl = String(loaderInfo.parameters.imageUrl);
            
            with (stage) {
                align = StageAlign.TOP_LEFT;
                scaleMode = StageScaleMode.NO_SCALE;
                addEventListener(MouseEvent.CLICK, onMouseClick);
            }
            with (graphics) {
                beginFill(playerBackgroundColor);
                drawRect(0, 0, playerWidth, playerHeight);
                endFill();
            }
                       
            playBitmap = new playImg().bitmapData;
            pauseBitmap = new pauseImg().bitmapData;
            
            progressUpdateTimer = new Timer(progressIndicatorUpdateInterval);
            progressUpdateTimer.addEventListener(TimerEvent.TIMER, drawProgressLine);
            
            loadingUpdateTimer = new Timer(loadingIndicatorUpdateInterval);
            loadingUpdateTimer.addEventListener(TimerEvent.TIMER, onLoadProgress);
            
            drawPlay();
            createProgressLine();
            loadImage();
        }
        
                
        private function get length():Number {
            return soundFactory.length;
        }
        
        private function get loaded():Boolean {
            return soundFactory && soundFactory.bytesLoaded == soundFactory.bytesTotal;
        }

        private function createProgressLine():void {
            progressLine = new Sprite();
            progressLine.x = buttonWidth;
            progressLine.graphics.beginFill(progressIndicatorColor);
            progressLine.graphics.drawRect(0, 0, progressIndicatorWeight, playerHeight - loadingIndicatorWeight);
            addChild(progressLine);
        }
        
        private function drawPause():void {
            with (graphics) {
                beginBitmapFill(pauseBitmap);
                drawRect(0, 0, buttonWidth, buttonHeight);
                endFill();
            }
        }
        
        private function drawPlay():void {
            with (graphics) {
                beginBitmapFill(playBitmap);
                drawRect(0, 0, buttonWidth, buttonHeight);
                endFill();
            }        
        }
        
        private function loadImage():void {
            imageLoader = new Loader();
            imageLoader.load(new URLRequest(imageUrl));
            addChild(imageLoader);
            imageLoader.contentLoaderInfo.addEventListener(Event.INIT, onImageLoad);
        }
        
        private function onImageLoad(event:Event):void {
            imageLoader.content.width = playerWidth - buttonWidth;
            imageLoader.content.height = playerHeight - loadingIndicatorWeight;
            imageLoader.content.x = buttonWidth;
            setChildIndex(progressLine, numChildren - 1);
        }

        
        private function onMouseClick(event:MouseEvent):void {
            if (event.stageX <= buttonWidth && event.stageY <= buttonHeight) {
                pause();
            } else {
                if (loaded) {
                    var requestedPos:Number = (event.stageX - buttonWidth) / (playerWidth - buttonWidth);
                    if (soundFactory.bytesLoaded > soundFactory.bytesTotal * requestedPos) {
                        song.stop();
                        song = soundFactory.play(length * requestedPos);
                    }
                }
            }
        }
        
        private function drawProgressLine(event:TimerEvent):void {
            progressLine.x = buttonWidth + song.position * (playerWidth - buttonWidth - progressIndicatorWeight) / length; 
        }

        private function playMP3():void {
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
            with (graphics) {
                beginFill(loadingIndicatorColor);
                drawRect(0, playerHeight - loadingIndicatorWeight,
                         soundFactory.bytesLoaded * playerWidth / soundFactory.bytesTotal, loadingIndicatorWeight);
                endFill();
            }
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
                    paused = true;
                    position = song.position;
                    song.stop();
                    drawPlay();
                    progressUpdateTimer.stop();
                } else {
                    paused = false;
                    song = soundFactory.play(position);
                    song.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
                    drawPause();
                    progressUpdateTimer.start();
                }
            } else {
                playMP3();
            }
        }
        
        private function stop():void {
            stopped = true;
            song.stop();
            position = 0;
        }
        
    }
}