package widgets {
    
    import flash.events.Event;
    
    public class PEvent extends Event{
        public static const ABS_PERCENT:String = "abs_percent";
        public static const INC_PERCENT:String = "inc_percent";
        
        private var _percent:Number;
        
        public function PEvent (type:String, val:Number) {
            super(type, true, false);
            _percent = val;
        }
        
        public function get percent():Number {
            return _percent;
        }

    }    
}