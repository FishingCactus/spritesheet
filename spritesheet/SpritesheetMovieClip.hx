package spritesheet;

class SpritesheetMovieClip extends openfl.display.MovieClip {

    public var autoUpdate(get, set):Bool;

    private var clip : AnimatedSprite;
    private var lastFrameIndex:Int = -1;

    // movieclip functions

    public function new(sheet:Spritesheet, smoothing:Bool = false) {
        super();
        clip = new AnimatedSprite(sheet, smoothing);
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

    override public function __enterFrame(deltaTime:Int) {
        var currentFrameIndex = @:privateAccess clip.__currentFrameIndex;

        if(currentFrameIndex != lastFrameIndex) {
            if (__frameScripts != null) {
                for(index in lastFrameIndex+1...currentFrameIndex+1) {
                    if (__frameScripts.exists (index)) {
                        __frameScripts.get (index) ();
                    }
                }
            }

            lastFrameIndex = currentFrameIndex;
        }
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
        lastFrameIndex = -1;
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
}
