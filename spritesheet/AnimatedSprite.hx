package spritesheet;


import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

import spritesheet.data.BehaviorData;
import spritesheet.data.SpritesheetFrame;
import spritesheet.Bitmap;


class AnimatedSprite extends Sprite {

	public var bitmap:Bitmap;
	public var currentBehavior:BehaviorData;
	public var currentFrameIndex(get, set):Int;
	public var smoothing:Bool;
	public var spritesheet:Spritesheet;
	public var autoUpdate:Bool = false;

	private var behaviorComplete:Bool;
	private var behaviorQueue:Array <BehaviorData>;
	private var behavior:BehaviorData;
	private var startPhaseDuration:Int;
	private var loopPhaseDuration:Int;
	private var totalDuration:Int;
	private var timeElapsed:Int;
	private var __currentFrameIndex:Int = 0;
	private var __currentFrame:SpritesheetFrame;


	public function new (sheet:Spritesheet, smoothing:Bool = false) {

		super ();

		this.smoothing = smoothing;
		this.spritesheet = sheet;

		behaviorQueue = new Array <BehaviorData> ();
		bitmap = new Bitmap ();
		addChild (bitmap);

	}


	public function getFrameData (index:Int):Dynamic {

		if (currentBehavior != null && currentBehavior.frameData.length > index) {

			return currentBehavior.frameData[index];

		} else {

			return null;

		}

	}


	public function queueBehavior (behavior:Dynamic):Void {

		var behaviorData = resolveBehavior (behavior);

		if (currentBehavior == null) {

			updateBehavior (behaviorData);

		} else {

			behaviorQueue.push (behaviorData);

		}

	}


	private function resolveBehavior (behavior:Dynamic):BehaviorData {

		if (Std.is (behavior, BehaviorData)) {

			return cast behavior;

		} else if (Std.is (behavior, String)) {

			if (spritesheet != null) {

				var result = spritesheet.behaviors.get (cast behavior);

				if(result == null)
				{
					throw "[spritesheet.AnimatedSprite] Missing behavior : " + behavior;
				}

				return result;

			} else {
				throw "[spritesheet.AnimatedSprite] No spritesheet set when trying to resolve behavior!";
			}

		}

		return null;

	}


	public function showBehavior (behavior:Dynamic, restart:Bool = true):Void {

		behaviorQueue = new Array <BehaviorData> ();

		updateBehavior (resolveBehavior (behavior), restart);

	}


	public function showBehaviors (behaviors:Array <Dynamic>):Void {

		behaviorQueue = new Array <BehaviorData> ();

		for (behavior in behaviors) {

			behaviorQueue.push (resolveBehavior (behavior));

		}

		if (behaviorQueue.length > 0) {

			updateBehavior (behaviorQueue.shift ());

		}

	}


	public function update (deltaTime:Int):Void {

		if (!behaviorComplete) {

			timeElapsed += deltaTime;

			// Number of frames in the animation
			var frameCount = currentBehavior.frames.length;

			var ratio = timeElapsed / totalDuration;

			if (ratio >= 1) {

				if (currentBehavior.loop) {

					var loopRatio = (timeElapsed - startPhaseDuration)/ loopPhaseDuration;
					loopRatio -= Math.floor (loopRatio);
					ratio = (startPhaseDuration + loopRatio * loopPhaseDuration) / totalDuration;

				} else {

					behaviorComplete = true;
					ratio = 1.0 - 1e-6;

				}

			}

			var previous_frame = currentFrameIndex;

			currentFrameIndex = Math.floor(ratio * frameCount);

			if (behaviorComplete) {

				if (behaviorQueue.length > 0) {

					updateBehavior (behaviorQueue.shift ());

				} else if (hasEventListener (Event.COMPLETE)) {

					dispatchEvent (new Event (Event.COMPLETE));

				}

			}

		}

	}


	private function updateBehavior (behavior:BehaviorData, restart:Bool = true):Void {

		if (behavior != null) {

			if (restart || behavior != currentBehavior) {

				currentBehavior = behavior;
				timeElapsed = 0;
				behaviorComplete = false;

				if (behavior.loop) {

					startPhaseDuration = Std.int ((behavior.loopIndex / behavior.frameRate) * 1000);
					loopPhaseDuration = Std.int (((behavior.frames.length - behavior.loopIndex) / currentBehavior.frameRate) * 1000);

				} else {

					startPhaseDuration = 0;
					loopPhaseDuration = Std.int ((behavior.frames.length / behavior.frameRate) * 1000);

				}

				totalDuration = startPhaseDuration + loopPhaseDuration;

				update (0);

			}

		} else {

			bitmap.bitmapData = null;
			currentBehavior = null;
			currentFrameIndex = -1;
			behaviorComplete = true;

		}

	}

	override public function __enterFrame(deltaTime:Int)
	{
		if(autoUpdate)
		{
			update(deltaTime);
		}

		super.__enterFrame(deltaTime);
	}

	private function get_currentFrameIndex() {
		return __currentFrameIndex;
	}

	private function set_currentFrameIndex(index) {
		if (index < 0) index = 0;
        else if (index >= currentBehavior.frames.length) index = currentBehavior.frames.length - 1;

        __currentFrameIndex = index;

		var frame = spritesheet.getFrame (currentBehavior.frames [currentFrameIndex]);

		__currentFrame = frame;
		bitmap.bitmapData = frame.bitmapData;
		bitmap.smoothing = smoothing;
		bitmap.x = frame.offsetX - currentBehavior.originX;
		bitmap.y = frame.offsetY - currentBehavior.originY;
		bitmap.width = frame.displayWidth;
		bitmap.height = frame.displayHeight;
		bitmap.textureUvs = frame.textureUvs;

		__setRenderDirty();

		return index;
	}
}
