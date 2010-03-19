package {
    // Flash libs import
    import flash.display.Sprite;

    // Our stuff import
    import widgets.Histogram;
    import widgets.SSWButton;
    import widgets.Volume;
    
    public class WlGui extends Sprite {
        public var guiButtons:SSWButton;
        public var guiHistogram:Histogram;
        public var guiVolume:Volume;
        
        public function WlGui(guiWidth:Number, guiHeight:Number)
        {            
            with (graphics) {
                drawRect(0, 0, guiWidth, guiHeight);
            }
            
            width = guiWidth;
            height = guiHeight;
            
            guiButtons = new SSWButton(guiHeight-16, guiHeight-16);
            guiButtons.x = 8;
            guiButtons.y = 8;
            guiButtons.state = 'play';
            addChild(guiButtons);

            guiHistogram = new Histogram(guiWidth - guiHeight - 25, guiHeight);
            guiHistogram.x = guiHeight;
            guiHistogram.y = 0;
            addChild(guiHistogram);

            guiVolume = new Volume(20, guiHeight);
            guiVolume.x = guiWidth - 20;
            guiVolume.y = 0;
            addChild(guiVolume);
        }
    }
}
