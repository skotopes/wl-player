package {
    // Casa libs import
    import flash.display.Sprite;
    
    public class Histogram extends Sprite {

        private var positionIndicatorColor:Number = 0xAA0000;
        private var loadingIndicatorColor:Number = 0x336666;

        private var histogramSprite:Sprite;
        private var loadingSprite:Sprite;
        private var positionSprite:Sprite;
        private var clickSprite:Sprite;
                
        [Embed(source='../assets/histogram_background.svg')]
        private var backgroundSvg:Class;

        public function Histogram(histWidth:Number, histHeight:Number) {
            histogramSprite = new backgroundSvg();
            loadingSprite = new Sprite();
            positionSprite = new Sprite();
            clickSprite = new Sprite();
            
            with (clickSprite.graphics) {
                drawRect(0, 0, histWidth, histHeight);
            }
            
            with (loadingSprite.graphics) {
                beginFill(loadingIndicatorColor);
                drawRect(0, 0, histWidth, histHeight);
                endFill();
            }
            loadingSprite.alpha = 50;

            with (positionSprite.graphics) {
                beginFill(positionIndicatorColor);
                drawRect(0, 0, 1, histHeight);
                endFill();
            }
            positionSprite.alpha = 75;

            // Fucking magick
            histogramSprite.width = histWidth;
            histogramSprite.height = histHeight;
            loadingSprite.width = histWidth;
            loadingSprite.height = histHeight;
            clickSprite.width = histWidth;
            clickSprite.height = histHeight;
            
            clickSprite.mouseEnabled = false;
                                    
            addChildAt(histogramSprite, 0);
            addChildAt(loadingSprite, 1);
            addChildAt(positionSprite, 2);
            addChildAt(clickSprite, 3);
                        
            buttonMode = true;
            hitArea = clickSprite;
        }
        
        public function setMask():void {
            
        }
        
        public function setBack():void {
            
        }
        
        public function setPosition(pos:Number):void {
            positionSprite.x = loadingSprite.width * pos;
        }
        
        public function setProgress(pos:Number):void {
            loadingSprite.x = loadingSprite.width * pos;
        }
    }
}