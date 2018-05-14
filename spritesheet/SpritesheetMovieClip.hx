package spritesheet;

import format.swf.lite.SWFLite;
import format.swf.lite.symbols.SWFSymbol;


class SpritesheetMovieClip extends openfl.display.MovieClip {

    private var clip : AnimatedSprite;
    private var lastFrameIndex:Int = -1;
    private var __changingFlow:Bool = false;
    private var __swf: SWFLite;
    private var __playing : Bool;
    private var __timeElapsed:Int;
    private var __originalSymbol:SWFSymbol;

    // movieclip functions

    public function new(swf:SWFLite, sheet:Spritesheet, smoothing:Bool = false, originalSymbol:SWFSymbol = null) {
        super();
        clip = new AnimatedSprite(sheet, smoothing);
        __currentFrame = 1;
        addChild(clip);
        __swf = swf;
        __originalSymbol = originalSymbol;

        play ();
    }

    public override function get_totalFrames() {
        if(clip.currentBehavior != null) {
            return clip.currentBehavior.frames.length;
        }
        return clip.spritesheet.totalFrames;
    }

    public override function gotoAndPlay (frame:Dynamic, scene:String = null):Void {
        if ( __goto(frame, scene) )
        {
            play();
        }
    }

    public override function gotoAndStop (frame:Dynamic, scene:String = null):Void {
        if ( __goto(frame, scene) )
        {
            stop();
            clip.update(0);
        }
    }

    public override function play() {
        if (!__playing) {
            __playing = true;
            __timeElapsed = 0;
        }
    }

    public override function stop() {
        __playing = false;
    }

    private inline function __getFrameTime():Int {
		var frameTime = stage.frameTime;

		if (frameTime != null) {
			return frameTime;
		} else {
			return __swf.frameTime;
		}
	}

    override public function __enterFrame(deltaTime:Int) {

        #if dev
        if ( clip.autoUpdate ) {
            throw "Autoupdate should not be set on spritesheet movieclips. Handled internally!";
        }
        #end
        if (__playing) {

			__timeElapsed += deltaTime;

			var frameTime = __getFrameTime();
			var advanceFrames = Math.floor (__timeElapsed / frameTime);
			__timeElapsed = (__timeElapsed % frameTime);

			__currentFrame += advanceFrames;

			while (__currentFrame > totalFrames) {

				__currentFrame -= totalFrames;

			}

			__updateFrame ();

            clip.currentFrameIndex = __currentFrame - 1;
            __currentFrameLabel = @:privateAccess clip.__currentFrame.label;

		}

    }

    private function __renderFrame(index:Int):Bool {

        __currentFrame = index + 1;
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

    public override function getSymbol():SWFSymbol{
        return __originalSymbol;
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

    // private

    private function __goto (frame:Dynamic, scene:String = null) {
        if ( !__changingFlow )
        {
            var targetFrame = -1;
            // Don't change the behavior. just advance frames.
            if (Std.is (frame, Int)) {
            targetFrame = frame;
            } else if (Std.is (frame, String)) {
                if(clip.currentBehavior != null) {
                    targetFrame = clip.spritesheet.getBehaviorFrameIndexFromLabel(clip.currentBehavior, frame);
                    targetFrame += 1;
                }
            }

            if(targetFrame != -1) {
                var ratio:Float = cast(targetFrame - 1, Float) / (clip.currentBehavior.frames.length);
                @:privateAccess clip.timeElapsed = Std.int(ratio * @:privateAccess clip.totalDuration);
                @:privateAccess clip.behaviorComplete = false;
            }

            __changingFlow = true;

            do {
                __playing = true;
                __currentFrame = targetFrame;
                __updateFrame ();

            } while (targetFrame != __currentFrame);

            __changingFlow = false;

            return __playing;
        }

        return false;
    }

    private function __updateFrame ():Void {

        if (__currentFrame != lastFrameIndex) {
            var scriptHasChangedFlow : Bool = false;

            if(__currentFrame < lastFrameIndex) {
                var cacheCurrentFrame = __currentFrame;
                for(frameIndex in (lastFrameIndex ... totalFrames)) {
                    scriptHasChangedFlow = __renderFrame(frameIndex);
                    if (!__playing || scriptHasChangedFlow) {
                        break;
                    }
                }
                if (__playing && !scriptHasChangedFlow){
                    for(frameIndex in (0 ... cacheCurrentFrame)) {
                        scriptHasChangedFlow = __renderFrame(frameIndex);
                        if (!__playing || scriptHasChangedFlow) {
                            break;
                        }
                    }
                }
            } else {
                for(frameIndex in (lastFrameIndex ... __currentFrame)) {
                    scriptHasChangedFlow = __renderFrame(frameIndex);
                    if (!__playing || scriptHasChangedFlow) {
                        break;
                    }
                }
            }
        }
    }
}
