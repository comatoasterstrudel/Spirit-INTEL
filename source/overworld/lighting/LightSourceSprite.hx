package overworld.lighting;

class LightSourceSprite extends CtSprite
{
	public var tag:String = "";
    var data:LightSourceData;

	public function new(id:String, x:Int, y:Int, tag:String):Void
	{
        super();
        
        data = Registry.get(LightSourceData, id);

        createFromImage(Constants.lightSourceGraphicPath + data.graphic + ".png");
        setGraphicSize(width * Constants.overworldPixelScale, height * Constants.overworldPixelScale);
		updateHitbox();
        
        antialiasing = false; 
        
        setPosition(x, y);
        
		this.tag = tag;
        
        #if showLightSources
        FlxG.state.add(this);
        #end
    }
}