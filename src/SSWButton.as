package {
    
    import flash.utils.Dictionary;
    import flash.display.Sprite;

    public class SSWButton extends Sprite {
        
        protected var states:Array = ['click', 'pause', 'play', 'wip'];
        protected var movies:Dictionary = new Dictionary();
        
        [Embed(source='../assets/click.svg')]
        protected var clickSvg:Class;
        
        [Embed(source='../assets/pause.svg')]
        protected var pauseSvg:Class;
        
        [Embed(source='../assets/play.svg')]
        protected var playSvg:Class;
        
        [Embed(source='../assets/wip.svg')]
        protected var wipSvg:Class;
        
        public function SSWButton(_width:Number, _height:Number) {
            
            var sp:Sprite;
            var name:String;
            var spClass:Class;
            for(var i:Number=0; i<states.length; i++) {
                name = states[i];
                spClass = this[name + 'Svg'];
                sp = new spClass();
                movies[name] = sp;
                sp.visible = false;
                addChild(sp);
            }
            
            width = _width;
            height = _height;
            
            buttonMode = true;
            hitArea = this;
        }
        
        public function set state(value:String):void {
            if (states.indexOf(value) == -1) {
                throw new Error('unknown state "' + value + '"');
            }
            for(var i:Number=0; i<states.length; i++) {
                movies[states[i]].visible = (states[i] == value);
            }
        }

    }
}