package {
    import flash.display.Sprite;

    public class SSWButton extends Sprite {
        private var _clickMovie:Sprite;
        private var _pauseMovie:Sprite;
        private var _playMovie:Sprite;
        private var _wipMovie:Sprite;

        [Embed(source='../assets/click.svg')]
        private var clickSvg:Class;
        [Embed(source='../assets/pause.svg')]
        private var pauseSvg:Class;
        [Embed(source='../assets/play.svg')]
        private var playSvg:Class;
        [Embed(source='../assets/wip.svg')]
        private var wipSvg:Class;
        
        public function SSWButton() {
            _clickMovie = new clickSvg();
            _pauseMovie = new pauseSvg();
            _playMovie = new playSvg();
            _wipMovie = new wipSvg();

            _clickMovie.visible = false
            _pauseMovie.visible = false;
            _playMovie.visible = false;
            _wipMovie.visible = true;

            addChild(_clickMovie);
            addChild(_pauseMovie);
            addChild(_playMovie);
            addChild(_wipMovie);
            
            buttonMode = true;
            hitArea = this;
        }
        
        public function setStatePause():void {
            _pauseMovie.visible = true;
            _playMovie.visible = false;
            _wipMovie.visible = false;
        }
        
        public function setStatePlay():void {
            _pauseMovie.visible = false;
            _playMovie.visible = true;
            _wipMovie.visible = false;
        }
        
        public function setStateWIP():void {
            _pauseMovie.visible = false;
            _playMovie.visible = false;
            _wipMovie.visible = true;
        }
    }
}