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

		}
		else {

			__preRenderGL (renderSession);
			
			if (__renderable && __worldAlpha > 0 && bitmapData != null && bitmapData.__isValid) {
				// :TODO: should use Bitmap.width and height but mimicking original behavior here
				renderSession.spriteBatch.renderBitmapDataEx(bitmapData, bitmapData.width, bitmapData.height, textureUvs, smoothing, __renderTransform, __worldColorTransform, __worldAlpha, __blendMode, __shader, pixelSnapping);
			}
			
			__postRenderGL (renderSession);

		}

	}
	

}
