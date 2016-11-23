package spritesheet;

import flash.display.Bitmap as FlashBitmap;
import flash.display.BitmapData;

import openfl._internal.renderer.RenderSession;

@:access(openfl.display.BitmapData)

class Bitmap extends FlashBitmap {
	
	public var textureUvs:TextureUvs;

	public function new () {
		
		super ();
		
		this.__useSeparateRenderScaleTransform = false;
		
	}
	

	public override function __renderGL (renderSession:RenderSession):Void {

		if (textureUvs == null) {

			super.__renderGL(renderSession);

		} else {

			var savedUvs = bitmapData.__uvData;
			
			bitmapData.__uvData = textureUvs;
			super.__renderGL(renderSession);

			bitmapData.__uvData = savedUvs;

		}

	}
	

}
