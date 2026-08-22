package overworld.props;

class Prop extends CtSprite
{
    public var data:PropData;
    
    public var hitbox:CtSprite;
    
	public var tag:String;

	public function new(id:String, tag:String, x:Float, y:Float):Void
	{
        super(x * Constants.overworldPixelScale, y * Constants.overworldPixelScale);
        
		this.tag = tag;
        
        data = new PropData(id);
        
        loadSprite();
        
        hitbox = new CtSprite(this.x + (data.hitboxX * Constants.overworldPixelScale), this.y + (data.hitboxY * Constants.overworldPixelScale)).createColorBlock(Std.int(data.hitboxWidth * Constants.overworldPixelScale), Std.int(data.hitboxHeight * Constants.overworldPixelScale), FlxColor.RED);
		hitbox.visible = false;
		hitbox.immovable = true;
    }
    
    function loadSprite():Void{
        var path = Constants.propImagePath + data.graphic + ".png";
        
        createFromImage(path, Constants.overworldPixelScale);
        antialiasing = false;        
    }

    public override function kill():Void{
        hitbox.kill();
        super.kill();
    }

    public override function revive():Void{
        hitbox.revive();
        super.revive();
    }
}