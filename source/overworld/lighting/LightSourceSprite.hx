package overworld.lighting;

class LightSourceSprite extends CtSprite
{
	public var tag:String = "";
    var data:LightSourceData;

    var flickerDelay:Float = 0;
    var flickering:Bool = false;
    var targetFlicker:Float = 1;

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

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        handleFlicker(elapsed);
    }

    function handleFlicker(elapsed:Float):Void{
        if(data.flickerChance <= 0) return;

        if(!flickering){
            if(flickerDelay >= data.flickerGap){
                if(FlxG.random.bool(data.flickerChance * elapsed)){
                    flickerDelay = 0;

                    targetFlicker = (1 - data.flickerIntensity);

                    flickering = true;

                    new FlxTimer().start(data.flickerTime, function(f):Void{
                        flickering = false;
                        targetFlicker = 1;
                    });
                }
            } else {
                flickerDelay += elapsed;
            }
        }

        if(data.flickerSmoothing <= 0) { // no smoothing
            alpha = targetFlicker;
        } else {
            alpha = CtUtil.lerpThing(alpha, targetFlicker, elapsed, data.flickerSmoothing);
        }
    }
}