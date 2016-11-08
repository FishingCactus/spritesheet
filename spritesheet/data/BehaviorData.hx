package spritesheet.data;


import flash.geom.Point;


class BehaviorData {
	
	
	public var frameData:Array <Dynamic>;
	public var frameRate:Int;
	public var frames:Array <Int>;
	public var loopIndex:Int;
	public var name:String;
	public var originX:Float;
	public var originY:Float;
	
	public var loop (get,set):Bool;
	
	private static var uniqueID:Int = 0;
	
	
	public function new (name:String = "", frames:Array <Int> = null, loop:Bool = false, frameRate:Int = 30, originX:Float = 0, originY:Float = 0) {
		
		if (name == "") {
			
			name = "behavior" + (uniqueID++);
			
		}
		
		if (frames == null) {
			
			frames = [];
			
		}
		
		this.name = name;
		this.frames = frames;
		this.loop = loop;
		this.frameRate = frameRate;
		this.originX = originX;
		this.originY = originY;
		
		frameData = new Array <Dynamic> ();
		
		for (i in 0...this.frames.length) {
			
			frameData.push (null);
			
		}
		
	}
	
	
	public function clone ():BehaviorData {
		
		return new BehaviorData ("behavior" + (uniqueID++), frames.copy (), loop, frameRate, originX, originY);
		
	}
	
	public function get_loop ():Bool {
		
		return loopIndex != -1;
		
	}

	public function set_loop (value:Bool):Bool {
		
		loopIndex = value ? 0 : -1;
		return value;
		
	}
	
}
