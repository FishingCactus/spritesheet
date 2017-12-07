package spritesheet;

import openfl.display.DisplayObject;
import openfl.display.BitmapData;
import openfl.display.MovieClip;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

import spritesheet.Spritesheet;
import spritesheet.data.BehaviorData;
import spritesheet.data.SpritesheetFrame;

class SpritesheetBuilder {
    public var spritesheet (default, null):Spritesheet;

    private var bitmapData:BitmapData;
    private var nextX:Int = 0;
    private var nextY:Int = 0;
    private var currentLineHeight:Int = 0;

    private static inline var padding:Int = 1;

    public function new () {
    }

    public function begin(width:Int, height:Int) {
        inline function getNextPowerOf2(value:Int):Int {
            value --;
            value |= ( value >> 16 );
            value |= ( value >> 8 );
            value |= ( value >> 4 );
            value |= ( value >> 2 );
            value |= ( value >> 1 );
            value ++;

            return value;
        }

        bitmapData = new openfl.display.BitmapData( getNextPowerOf2 (width), getNextPowerOf2 (height), true, 0 );
        spritesheet = new Spritesheet (bitmapData);
    }

    public function add(displayObject:DisplayObject, behaviorName:String) {
        var frameTable = [];

        if (displayObject == null) {
            var frame = new SpritesheetFrame ();
            frameTable.push (spritesheet.totalFrames);
            spritesheet.addFrame (frame);
        } else {
            function addSingle(displayObject:DisplayObject) {
                displayObject.__update (true, true);

                var renderBounds = Rectangle.pool.get ();
                @:privateAccess displayObject.__getRenderBounds (renderBounds);

                var width = Math.ceil (renderBounds.width) + 2 * padding;
                var height = Math.ceil (renderBounds.height) + 2 * padding;

                if (nextX + width >= bitmapData.physicalWidth) {
                    nextX = 0;
                    nextY += currentLineHeight;
                    currentLineHeight = height;
                } else {
                    currentLineHeight = currentLineHeight > height ? currentLineHeight : height;
                }

                var transform = Matrix.pool.get ();
                transform.copyFrom (displayObject.__renderTransform);
                transform.translate (nextX + padding - Math.ffloor(renderBounds.x), nextY + padding - Math.ffloor(renderBounds.y));

                // :TODO: use DisplayObject.__cacheBitmapFn() with offset
                (@:privateAccess spritesheet.sourceImage).draw( displayObject, transform );

                Matrix.pool.put (transform);

                var frame = new SpritesheetFrame (nextX, nextY, width, height);
                frame.displayHeight = height;
                frame.displayWidth = width;
                frame.offsetX = Math.floor (renderBounds.x) - padding;
                frame.offsetY = Math.floor (renderBounds.y) - padding;

                Rectangle.pool.put (renderBounds);

                frameTable.push (spritesheet.totalFrames);
                spritesheet.addFrame (frame);

                nextX += width;
            }

            if (Std.is(displayObject, MovieClip)) {
                var mc = cast(displayObject, MovieClip);
                for (frameIndex in 1...mc.totalFrames+1) {
                    mc.gotoAndStop (frameIndex);
                    addSingle(mc);
                }
            }
            else {
                addSingle(displayObject);
            }
        }

        var behavior = new BehaviorData(behaviorName, frameTable, false);
        spritesheet.addBehavior(behavior);
    }

    public function end() {
        spritesheet.usePerFrameBitmapData = false;
        spritesheet.generateBitmaps();

        bitmapData = null;
    }
}
