package {
    // Flash libs import
    import flash.display.Sprite;

    // Our stuff import
    import Histogram;
    import SSWButton;
    
    public class WlGui extends Sprite {
        public var guiButtons:SSWButton;
        public var guiHistogram:Histogram;
        
        public function WlGui(guiWidth:Number, guiHeight:Number)
        {            
            with (graphics) {
                beginFill(0xFFFFFF);
                drawRect(0, 0, guiWidth, guiHeight);
                endFill();
            }
            
            width = guiWidth;
            height = guiHeight;
            
            guiButtons = new SSWButton(guiHeight-16, guiHeight-16);
            guiButtons.x = 8;
            guiButtons.y = 8;
            guiButtons.state = 'play';
            addChild(guiButtons);

            guiHistogram = new Histogram(guiWidth - guiHeight, guiHeight);
            guiHistogram.x = guiHeight;
            guiHistogram.y = 0;
            addChild(guiHistogram);
        }
    }
}
