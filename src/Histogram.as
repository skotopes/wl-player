package {
    // Casa libs import
    import flash.display.Sprite;
    
    public class Histogram extends Sprite {

        private var progressIndicatorColor:Number = 0x61AC00;        
        private var loadingIndicatorColor:Number = 0x336666;

        private var histogramSprite:Sprite;
        private var progressSprite:Sprite;
        private var loadingSprite:Sprite;

        [Embed(source='../assets/histogram_background.svg')]
        private var backgroundSvg:Class;

        public function Histogram() {
            histogramSprite = new backgroundSvg();
            progressSprite = new Sprite();
            loadingSprite = new Sprite();
            
            addChild(histogramSprite);
            addChild(progressSprite);
            addChild(loadingSprite);

            buttonMode = true;
            hitArea = this;
        }
        
        public function setMask():void {
            
        }
        
        public function setBack():void {
            
        }
        
        public function drawLoadingProgress():void {
            with (loadingSprite.graphics) {
                beginFill(loadingIndicatorColor, .5);
                drawRect(0, 0, width, height);
                endFill();
            }
        }
        
    }
}