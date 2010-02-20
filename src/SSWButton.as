package {
    
    import flash.utils.Dictionary;
    import flash.display.Sprite;

    public class SSWButton extends Sprite {
        
        protected var states:Array = ['pause', 'play', 'wip', 'click'];
        protected var sprites:Dictionary = new Dictionary();
        
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
                sp.visible = false;
                sp.cacheAsBitmap = true;
                sp.mouseEnabled = false;
                sprites[name] = sp;                
                addChild(sp);
            }
            
            width = _width;
            height = _height;
                        
            buttonMode = true;
            hitArea = sprites['click'];
        }
        
        public function set state(value:String):void {
            if (states.indexOf(value) == -1) {
                throw new Error('unknown state "' + value + '"');
            }
            for(var i:Number=0; i<states.length; i++) {
                sprites[states[i]].visible = (states[i] == value);
            }
        }

    }
}