package {

    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;

    public class Histogram extends Sprite {

        private var positionIndicatorColor:Number = 0xFF0000;
        private var loadingIndicatorColor:Number = 0x336666;

        private var histogramSprite:Sprite;
        private var loadingSprite:Sprite;
        private var positionSprite:Sprite;
        private var clickSprite:Sprite;
                
        [Embed(source='../assets/histogram_background.svg')]
        private var backgroundSvg:Class;

        public function Histogram(histWidth:Number, histHeight:Number) {
            histogramSprite = new Sprite();
            loadingSprite = new Sprite();
            positionSprite = new Sprite();
            clickSprite = new Sprite();
            
            with (histogramSprite) {
                var defaultBack:Sprite = new backgroundSvg();
                defaultBack.width = histWidth;
                defaultBack.height = histHeight;
                addChildAt(defaultBack, 0);
            }
            
            with (clickSprite.graphics) {
                drawRect(0, 0, histWidth, histHeight);
            }
            
            with (loadingSprite.graphics) {
                beginFill(loadingIndicatorColor);
                drawRect(0, 0, histWidth, histHeight);
                endFill();
            }
            loadingSprite.alpha = 0.5;

            with (positionSprite.graphics) {
                beginFill(positionIndicatorColor);
                drawRect(0, 0, 1, histHeight);
                endFill();
            }
            
            // Fucking magick
            histogramSprite.width = histWidth;
            histogramSprite.height = histHeight;
            loadingSprite.width = histWidth;
            loadingSprite.height = histHeight;
            clickSprite.width = histWidth;
            clickSprite.height = histHeight;
            
            histogramSprite.cacheAsBitmap = true;
            clickSprite.mouseEnabled = false;
                                    
            addChildAt(histogramSprite, 0);
            addChildAt(loadingSprite, 1);
            addChildAt(positionSprite, 2);
            addChildAt(clickSprite, 3);
                        
            buttonMode = true;
            hitArea = clickSprite;
        }
        
        public function set histMask(image:Bitmap):void {
            image.smoothing = true;
            image.width = histogramSprite.width;
            image.height = histogramSprite.height;
            image.cacheAsBitmap = true;

            addChild(image);

            histogramSprite.mask = image;
        }
        
        public function set histBack(image:Bitmap):void {
            image.smoothing = true;
            image.width = histogramSprite.width;
            image.height = histogramSprite.height;
            image.cacheAsBitmap = true;

            histogramSprite.addChildAt(image, 1);
        }
        
        public function set playPosition(pos:Number):void {
        positionSprite.x = loadingSprite.width * pos;
        }
        
        public function set loadProgress(pos:Number):void {
            loadingSprite.x = loadingSprite.width * pos;
        }
    }
}