package overworld.lighting;

class LightingSprite extends FlxSpriteGroup
{
    var backSprite:CtSprite;
	public var lightSources:Array<LightSourceSprite> = [];
    
    public function new(map:BetterFlxOgmo3Loader, roomData:RoomData):Void{
        super();
        
        backSprite = new CtSprite().createColorBlock(Std.int(map.getLevelData().width * Constants.overworldPixelScale), Std.int(map.getLevelData().height * Constants.overworldPixelScale), FlxColor.BLACK);
        add(backSprite);
        
        alpha = roomData.lighting; 
        
		antialiasing = false;  

    }
    
	public function addLightSource(graphic:String, x:Int, y:Int, tag:String):LightSourceSprite
	{
		var lightSource = new LightSourceSprite(graphic, x, y, tag);
        add(lightSource);
        
        lightSources.push(lightSource);
        
        return lightSource;
    } 

    public function getPropByTag(tag:String):Prop{
        for(spr in members){
            if(spr is Prop){
                var prop:Prop = cast spr;

                if(prop.tag == tag) return prop;
            }
        }
        
        return null;
    }
}