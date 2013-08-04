package widgets {

    import flash.utils.Dictionary;
    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.MouseEvent;
    import widgets.PEvent;

    public class Histogram extends Sprite {

        private var layers:Array = ['histogram', 'loading', 'position', 'click'];
        private var sprites:Dictionary = new Dictionary();

        private var positionIndicatorColor:Number = 0x000000;
        private var loadingIndicatorColor:Number = 0x99dddd;

        [Embed(source='Histogram_assets/histogram_background.svg')]
        private var backgroundSvg:Class;

        /**
         * Class contructor
         *
         */ 
        
        public function Histogram(histWidth:Number, histHeight:Number) {

            var sp:Sprite;
            var name:String;

            for(var i:Number=0; i<layers.length; i++) {
                name = layers[i];
                sp = new Sprite();
                sp.cacheAsBitmap = true;
                sp.mouseEnabled = false;
                
                sprites[name] = sp;
                addChild(sp);
            }
            
            with (sprites['histogram']) {
                var defaultBack:Sprite = new backgroundSvg();
                defaultBack.width = histWidth;
                defaultBack.height = histHeight;
                addChildAt(defaultBack, 0);
            }
                        
            with (sprites['loading'].graphics) {
                beginFill(loadingIndicatorColor);
                drawRect(0, 0, histWidth, histHeight);
                endFill();
            }
            sprites['loading'].alpha = 0.5;

            with (sprites['position'].graphics) {
                beginFill(positionIndicatorColor);
                drawRect(0, 0, 1, histHeight);
                endFill();
            }
            sprites['position'].alpha = 0.9;
            
            with (sprites['click'].graphics) {
                beginFill(0xFF0000);
                drawRect(0, 0, histWidth, histHeight);
                endFill();
            }
            sprites['click'].visible = false;
                        
            buttonMode = true;
            hitArea = sprites['click'];
            addEventListener(MouseEvent.CLICK, onHistogramClick);
        }

        /**
         * Getters/Setters
         *
         */ 
        
        public function set playPosition(pos:Number):void {
            sprites['position'].x = sprites['histogram'].width * pos;
        }

        public function get playPosition():Number {
            return sprites['position'].x / sprites['histogram'].width;
        }
        
        public function set loadProgress(pos:Number):void {
            sprites['loading'].x = sprites['histogram'].width * pos;
            sprites['loading'].width = sprites['histogram'].width - sprites['loading'].x;
        }        
                
        public function set histMask(image:Bitmap):void {
            image.smoothing = true;
            image.width = sprites['histogram'].width;
            image.height = sprites['histogram'].height;
            image.cacheAsBitmap = true;
            addChild(image);
            
            sprites['histogram'].mask = image;
        }
        
        public function set histBack(image:Bitmap):void {
            /*image.smoothing = true;*/
            image.width = sprites['histogram'].width;
            image.height = sprites['histogram'].height;
            image.cacheAsBitmap = true;
            
            sprites['histogram'].addChildAt(image, 1);
        }

        /**
         * Event listeners
         *
         */
        
        private function onHistogramClick(event:MouseEvent):void {
            var pos:Number;
            with (event.currentTarget) {
                pos = mouseX / width;
            }
            
            dispatchEvent(new PEvent(PEvent.ABS_PERCENT, pos));
        }        
    }
}