package overworld.savespot;

class SaveSpot extends Interactable
{
	var data:SaveSpotData;
	    
	public function new(name:String, saveName:String, tag:String, x:Int, y:Int):Void
	{
        super();
		data = new SaveSpotData(name);
		
		addManually(x, y, 16, 16, INTERACT, tag, "", "", 0, "", "", true, saveName, data.bgName);
		createFromImage(Constants.saveSpotGraphicPath + data.graphic + ".png");
        resize(Constants.overworldPixelScale);
        antialiasing = false;
        visible = true;

		triggerSignal.add(function():Void{
			if(data.sound != ""){
				CtSound.play(Constants.sfx_saveSoundPath + data.sound + ".ogg");
			}
		});
	}
}