package spritesheet.wrapper;

typedef SpritesheetConfig =
{
    var metaFilePath : String;
    var textureFilePath : String;
    var usePerFrameBitmapData : Bool;
    var smoothing : Bool;
    @:optional private var exp:EReg;
}