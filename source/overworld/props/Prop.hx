package overworld.props;

class Prop extends CtSprite
{
    public var data:PropData;
    
    public var hitbox:CtSprite;
    
	public var tag:String;

    public var killedSignal = new FlxSignal();
    public var revivedSignal = new FlxSignal();

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
        var base = Constants.propImagePath + data.graphic;

        if(data.anims.length > 0){
            frames = FlxAtlasFrames.fromTexturePackerJson(base + ".png", base + ".json", false);

            for (anim in data.anims)
            {
                animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.looped, anim.flipX, anim.flipY);
            }

            if(data.baseAnim != ""){
                animation.play(data.baseAnim);
            }

            resize(Constants.overworldPixelScale);
        } else {
            var path = Constants.propImagePath + data.graphic + ".png";
        
            createFromImage(path, Constants.overworldPixelScale);
        }

        antialiasing = false;        
    }

    public override function kill():Void{
        killedSignal.dispatch();
        hitbox.kill();
        super.kill();
    }

    public override function revive():Void{
        revivedSignal.dispatch();
        hitbox.revive();
        super.revive();
    }
}