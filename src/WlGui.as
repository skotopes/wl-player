package {
    // Flash libs import
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    
    // Casa libs import
    import org.casalib.display.CasaSprite;
    import org.casalib.display.CasaMovieClip;
    import org.casalib.util.StageReference;

    // Our stuff import
    import Histogram;
    import SSWButton;
    
    public class WlGui extends CasaMovieClip {
        public var guiButtons:SSWButton;
        public var guiHistogram:Histogram;
        
        public function WlGui(guiWidth:Number, guiHeight:Number)
        {
            with (StageReference.getStage()) {
                align = StageAlign.TOP_LEFT;
                scaleMode = StageScaleMode.NO_SCALE;
            }
            
            with (graphics) {
                beginFill(0xFFFFFF);
                drawRect(0, 0, guiWidth, guiHeight);
                endFill();
            }
            
            guiButtons = new SSWButton();
            guiButtons.x = 8;
            guiButtons.y = 8;
            guiButtons.width = guiHeight - 16;
            guiButtons.height = guiHeight - 16;
            
            addChild(guiButtons);

            guiHistogram = new Histogram();
            guiHistogram.x = guiHeight;
            guiHistogram.y = 0;
            guiHistogram.width = guiWidth - guiHeight;
            guiHistogram.height = guiHeight;

            addChild(guiHistogram);
        }
    }
}
