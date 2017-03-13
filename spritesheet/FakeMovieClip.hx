package spritesheet;

class FakeMovieClip extends AnimatedSprite {

    public var totalFrames (get, null):Int;
    private var __frameScripts:Map<Int, Void->Void>;

    public function new(sheet:Spritesheet, smoothing:Bool = false) {
        super(sheet, smoothing);
    }

    public function get_totalFrames() {
        return spritesheet.totalFrames;
    }

    public function gotoAndPlay (frame:Dynamic, scene:String = null):Void {
        __goto(frame, scene);
        play();
    }

    public function gotoAndStop (frame:Dynamic, scene:String = null):Void {
        __goto(frame, scene);
        stop();
    }

    public function play() {
        autoUpdate = true;
    }

    public function stop() {
        autoUpdate = false;
    }

    public function addFrameScript(index:Int, method: Void->Void):Void {
        if (method != null) {
			if (__frameScripts == null) {
				__frameScripts = new Map ();
			}

			__frameScripts.set (index, method);

		} else if (__frameScripts != null) {
			__frameScripts.remove (index);
		}
    }

    private function __goto (frame:Dynamic, scene:String = null) {
        var ratio:Float = 0;
        // Don't change the behavior. just advance frames.
        if (Std.is (frame, Int)) {
			ratio = cast(frame, Float) / currentBehavior.frames.length;
            timeElapsed = Std.int(ratio * totalDuration);
		} else if (Std.is (frame, String)) {
            showBehavior(frame);
        }
    }

    private override function set_currentFrameIndex(index) {
        if (__frameScripts != null) {
            if (__frameScripts.exists (index)) {
                __frameScripts.get (index) ();
            }
        }
        return super.set_currentFrameIndex(index);
    }
}
