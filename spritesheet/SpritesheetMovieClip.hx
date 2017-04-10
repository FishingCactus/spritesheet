package spritesheet;

class SpritesheetMovieClip extends openfl.display.MovieClip {

    public var autoUpdate(get, set):Bool;

    private var clip : AnimatedSprite;

    // movieclip functions

    public function new(sheet:Spritesheet, smoothing:Bool = false) {
        super();
        clip = new AnimatedSprite(sheet, smoothing);
        clip.addEventListener(AnimatedSprite.UPDATE_CURRENT_FRAME, checkFrameScript);
        addChild(clip);
    }

    public override function get_totalFrames() {
        if(clip.currentBehavior != null) {
            return clip.currentBehavior.frames.length;
        }
        return clip.spritesheet.totalFrames;
    }

    public override function gotoAndPlay (frame:Dynamic, scene:String = null):Void {
        __goto(frame, scene);
        play();
    }

    public override function gotoAndStop (frame:Dynamic, scene:String = null):Void {
        __goto(frame, scene);
        stop();
        clip.update(0);
    }

    public override function play() {
        clip.autoUpdate = true;
    }

    public override function stop() {
        clip.autoUpdate = false;
    }

    // Animated Sprite forwarding

    public function getFrameData(index:Int):Dynamic {
        return clip.getFrameData(index);
    }

    public function queueBehavior (behavior:Dynamic):Void {
        clip.queueBehavior(behavior);
    }

    public function showBehavior (behavior:Dynamic, restart:Bool = true):Void {
        clip.showBehavior(behavior, restart);
    }

    public function set_autoUpdate(value) {
        return clip.autoUpdate = value;
    }

    public function get_autoUpdate() {
        return clip.autoUpdate;
    }

    // private

    private function __goto (frame:Dynamic, scene:String = null) {
        var ratio:Float = 0;
        // Don't change the behavior. just advance frames.
        if (Std.is (frame, Int)) {
			ratio = cast(frame, Float) / (clip.currentBehavior.frames.length-1);
            @:privateAccess clip.timeElapsed = Std.int(ratio * @:privateAccess clip.totalDuration);
            @:privateAccess clip.behaviorComplete = false;
		} else if (Std.is (frame, String)) {
            clip.showBehavior(frame);
        }
    }

    private function checkFrameScript(event) {
        if (__frameScripts != null) {
            var index = @:privateAccess clip.__currentFrameIndex;
            if (__frameScripts.exists (index)) {
                __frameScripts.get (index) ();
            }
        }
    }
}
