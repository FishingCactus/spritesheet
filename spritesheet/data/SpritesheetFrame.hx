package spritesheet.data;


import openfl.display.IBitmapData;


class SpritesheetFrame {
	
	
	public var name:String;
	public var label:String;
	public var bitmapData:IBitmapData;
	public var displayHeight:Int;
	public var displayWidth:Int;
	public var height:Int;
	public var offsetX:Int;
	public var offsetY:Int;
	public var width:Int;
	public var x:Int;
	public var y:Int;
	public var textureUvs:TextureUvs;

	public function new (x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0, offsetX:Int = 0, offsetY:Int = 0) {
		
		this.x = x;
		this.y = y;
		this.width = this.displayWidth = width;
		this.height = this.displayHeight = height;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		
	}
	
}
