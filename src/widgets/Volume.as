package widgets {

    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.events.MouseEvent;

    import widgets.PEvent;
    
    public class Volume extends Sprite {

        private var volumeIcon:Sprite;
        private var volumeContainer:Sprite;
        private var volumeSlider:Sprite;
        private var volumePointer:Sprite;
        private var volumeClick:Sprite;

        private var volumeLevel:Number = 1;
        private var volumeLevelShadow:Number = 0;
        
        [Embed(source='Volume_assets/volume_icon.svg')]
        private var iconSvg:Class;
        [Embed(source='Volume_assets/volume_slider.svg')]
        private var sliderSvg:Class;
        [Embed(source='Volume_assets/volume_pointer.svg')]
        private var pointerSvg:Class;
        
        public function Volume(guiWidth:Number, guiHeight:Number) {

            volumeIcon = new iconSvg();
            volumeIcon.width = guiWidth - 4;
            volumeIcon.height = guiWidth - 4;
            volumeIcon.x = 2;
            volumeIcon.y = 2;
            volumeIcon.buttonMode = true;
            volumeIcon.addEventListener(MouseEvent.CLICK, onIconClick);
            addChild(volumeIcon);

            volumeContainer = new Sprite();
            
            with (volumeContainer) {
                x = 2;
                y = guiWidth;
                
                volumeSlider = new sliderSvg();
                volumeSlider.scale9Grid = new Rectangle(1, 5, 8, 40);
                volumeSlider.height = guiHeight - guiWidth - 2;
                volumeSlider.mouseEnabled = false;
                addChild(volumeSlider);
                
                volumePointer = new pointerSvg();
                volumePointer.width = volumeSlider.width - 4;
                volumePointer.x = volumeSlider.width/2 - volumePointer.width/2;
                volumePointer.y = 2;
                volumePointer.mouseEnabled = false;                
                addChild(volumePointer);
                
                volumeClick = new Sprite();
                volumeClick.x = 2;
                volumeClick.y = 2;
                with (volumeClick.graphics) {
                    beginFill(0xFF0000);
                    drawRect(0, 0, volumeSlider.width, volumeSlider.height);
                    endFill();
                }
                volumeClick.mouseEnabled = false;
                volumeClick.visible = false;
                addChild(volumeClick);
                
                buttonMode = true;
                hitArea = volumeClick;

                addEventListener(MouseEvent.CLICK, onSliderClick);
                addEventListener(MouseEvent.MOUSE_DOWN, onSliderDown);
                addEventListener(MouseEvent.MOUSE_UP, onSliderUp);
                addEventListener(MouseEvent.MOUSE_OUT, onSliderUp);
            }
            
            addChild(volumeContainer);
        }
        
        /**
         * Getters/Setters
         *
         */ 
        
        public function set level(value:Number):void {
            volumeLevel = value;
            volumePointer.y = (volumeSlider.height - volumePointer.height - 4) * (1 - value) + 2;
        }

        public function get level():Number {
            return volumeLevel;
        }
        
        /**
         * Event listeners
         *
         */
        
        private function onSliderClick(event:MouseEvent):void {
            with (event.currentTarget) {
                if (mouseY < volumePointer.height/2 + 2) {
                    level = 1;
                } else if (mouseY > height - volumePointer.height/2 - 2) {
                    level = 0;
                } else {
                    level = 1 - (mouseY - volumePointer.height/2) / (height - 4 - volumePointer.height);
                }
            }

            dispatchEvent(new PEvent(PEvent.ABS_PERCENT, level));
        }

        private function onSliderDown(event:MouseEvent):void {
            volumeContainer.addEventListener(MouseEvent.MOUSE_MOVE, onSliderClick);
        }
        
        private function onSliderUp(event:MouseEvent):void {
            volumeContainer.removeEventListener(MouseEvent.MOUSE_MOVE, onSliderClick);
        }
                
        private function onIconClick(event:MouseEvent):void {
            var temp:Number;
            temp = level;
            level = volumeLevelShadow;
            volumeLevelShadow = temp;
            
            dispatchEvent(new PEvent(PEvent.ABS_PERCENT, level));
        }
    }
}
