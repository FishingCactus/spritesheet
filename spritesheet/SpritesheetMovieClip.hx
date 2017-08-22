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
        __currentFrame = @:privateAccess clip.__currentFrameIndex + 1;

        var clipCurrentFrame = @:privateAccess clip.__currentFrame;

        if(clipCurrentFrame != null){
            __currentFrameLabel = clipCurrentFrame.label;

            if(__currentFrameLabel != null) {
                __currentLabel = __currentFrameLabel;
            }
        }

        __updateFrame();
    }

    private function __renderFrame(index:Int):Bool {

        lastFrameIndex = index + 1;

        if (__frameScripts != null) {
            if (__frameScripts.exists (index)) {
                __frameScripts.get (index) ();

                if(index  + 1 != __currentFrame){
                    return true;
                }
            }
        }
        if (__staticFrameScripts != null) {
            if (__staticFrameScripts.exists (index)) {
                __staticFrameScripts.get (index) (this);

                if(index  + 1 != __currentFrame){
                    return true;
                }
            }
        }

        return false;
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
        var targetFrame = -1;
        // Don't change the behavior. just advance frames.
        if (Std.is (frame, Int)) {
           targetFrame = frame;
        } else if (Std.is (frame, String)) {
            if(clip.currentBehavior != null) {
                targetFrame= clip.spritesheet.getBehaviorFrameIndexFromLabel(clip.currentBehavior, frame);
            }
        }

        if(targetFrame != -1) {
            var ratio:Float = cast(targetFrame, Float) / (clip.currentBehavior.frames.length-1);
            @:privateAccess clip.timeElapsed = Std.int(ratio * @:privateAccess clip.totalDuration);
            @:privateAccess clip.behaviorComplete = false;
        }
    }

    private function __updateFrame ():Void {

        if (__currentFrame != lastFrameIndex) {
            var scriptHasChangedFlow : Bool;

            if(__currentFrame < lastFrameIndex) {
                var cacheCurrentFrame = __currentFrame;
                for(frameIndex in (lastFrameIndex ... totalFrames)) {
                    scriptHasChangedFlow = __renderFrame(frameIndex);
                    if (scriptHasChangedFlow) {
                        break;
                    }
                }

                for(frameIndex in (0 ... cacheCurrentFrame)) {
                    scriptHasChangedFlow = __renderFrame(frameIndex);
                    if (scriptHasChangedFlow) {
                        break;
                    }
                }
            } else {
                for(frameIndex in (lastFrameIndex ... __currentFrame)) {
                    scriptHasChangedFlow = __renderFrame(frameIndex);
                    if (scriptHasChangedFlow) {
                        break;
                    }
                }
            }
        }
    }
}
