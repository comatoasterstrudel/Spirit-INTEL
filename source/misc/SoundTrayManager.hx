package misc;

class SoundTrayManager extends FlxBasic
{
    public function new():Void{
        super();

        FlxG.sound.soundTray.volumeUpSound = Constants.sfx_ui_volUp;
        FlxG.sound.soundTray.volumeDownSound = Constants.sfx_ui_volDown;
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);
        
		FlxG.sound.soundTray.visible = false;
    }
}