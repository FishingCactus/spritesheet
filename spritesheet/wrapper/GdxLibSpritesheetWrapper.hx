package spritesheet.wrapper;

import openfl.display.BitmapData;
import openfl.Assets;
import openfl.display.api.ISpritesheet;
import flash.display.DisplayObject;
import spritesheet.AnimatedSprite;
import spritesheet.importers.LibGDXImporter;
import spritesheet.Spritesheet;

class GdxLibSpritesheetWrapper implements ISpritesheet
{

    private var importer:LibGDXImporter;
    private var spritesheetConfig:SpritesheetConfig;
    private var spritesheet:Spritesheet;
    private var excludeList:Array<String>;


    public function new(spritesheetConfig:SpritesheetConfig, excludeList:Array<String>)
    {
        this.spritesheetConfig = spritesheetConfig;
        this.excludeList = excludeList;
        generateSpriteSheet();
    }

    private function generateSpriteSheet():Void
    {
            importer = new LibGDXImporter();
            importer.usePerFrameBitmapData = spritesheetConfig.usePerFrameBitmapData;
            var metaData:String = Assets.getText(spritesheetConfig.metaFilePath);
            var textureData : BitmapData= Assets.getBitmapData(spritesheetConfig.textureFilePath);
            var exp:EReg = spritesheetConfig.exp == null ? new EReg(".*", "") : spritesheetConfig.exp;
            spritesheet = importer.parse(metaData, textureData, exp);
            spritesheet.generateBitmaps();
    }

    public function getDisplayObjectByFrameName(frameName:String):DisplayObject {
        var displayObject:AnimatedSprite = new AnimatedSprite(spritesheet, spritesheetConfig.smoothing);
        displayObject.showBehavior(getFrameNameWithoutExtension(frameName));
        return displayObject;
    }

    public function getBitmapDataByFrameName(frameName:String): BitmapData {
        return spritesheet.getFrameByName(getFrameNameWithoutExtension(frameName), true).bitmapData;
    }

    private function getFrameNameWithoutExtension(frameName:String):String {
        return frameName.split(".")[0];
    }

    public function isBitmapExcluded(frameName:String):Bool {
        return excludeList.indexOf(frameName) != -1;
    }

}
