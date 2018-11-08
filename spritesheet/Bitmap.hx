package spritesheet;

import flash.display.Bitmap as FlashBitmap;
import openfl.display.IBitmapData.TextureUvs;

import openfl._internal.renderer.RenderSession;

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

			var savedUvs = bitmapData.uvData;
			
			bitmapData.uvData = textureUvs;
			super.__renderGL(renderSession);

			bitmapData.uvData = savedUvs;

		}

	}
	

}
