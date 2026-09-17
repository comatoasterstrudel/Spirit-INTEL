function CTSCRIPT_SETNAME():String
{
	return "snow";
}

var map:BetterFlxOgmo3Loader;

var snowGroup:FlxSpriteGroup;

var snow_background:FlxSpriteGroup;
var snow_main:FlxSpriteGroup;
var snow_foreground:FlxSpriteGroup;

var minX:Float = 0;
var maxX:Float = 2000;

var minY:Float = 0;
var maxY:Float = 200;

var snowflakes:Array<CtSprite> = [];

var overMap:FlxSpriteGroup;

var doneBurst:Bool = false;

var frequency:Float = 1;

function create():Void{
    map = get_map();
    
    minX = -200;
    maxX = map.getLevelData().width * Constants.overworldPixelScale;
    
    minY = -100;
    maxY = map.getLevelData().height * Constants.overworldPixelScale;

    snowGroup = new FlxSpriteGroup();
    
    overMap = get_overMap();
    
    overMap.add(snowGroup);
    
    snow_background = new FlxSpriteGroup();
    snow_background.scrollFactor.set(0.5, 0.5);
    snowGroup.add(snow_background);
    
    snow_main = new FlxSpriteGroup();
    snowGroup.add(snow_main);
    
    snow_foreground = new FlxSpriteGroup();
    snow_foreground.scrollFactor.set(2, 2);
    snowGroup.add(snow_foreground);    
}

function update(elapsed:Float):Void{
    if(doneBurst){
		if (FlxG.random.bool((600 * frequency) * elapsed))
		{
            addSnowflake(false);
        }   
    } else {
		for (i in 0...((FlxG.random.int(40, 50)) * frequency))
		{
            addSnowflake(true);
        }
    
        doneBurst = true;
    }
    
    var destroyThese:Array<CtSprite> = [];
    
    for(snowflake in snowflakes){
		if (snowflake.x < minX || snowflake.y > maxY)
		{
            destroyThese.push(snowflake);
        }
    }
    
    for(snowflake in destroyThese){
        snowflakes.remove(snowflake);
        snowflake.destroy();
    }
}

function addSnowflake(randomY:Bool = false):Void{
	var snowflake = new CtSprite(Std.int(FlxG.random.float(minX, maxX)),
		randomY ? Std.int((FlxG.random.float(minY,
			maxY))) : minY).createFromImage(Constants.overworldMiscGraphicPath + "snowflake" + FlxG.random.int(1, 4) + ".png");
    snowflake.angle = FlxG.random.int(0, 360);
	snowflake.antialiasing = false;
    
    var speed:Float = 1;
    
    if(FlxG.random.bool(50)){ // main
        speed = 1;
        snow_main.add(snowflake);
    } else {
        if(FlxG.random.bool(50)){ // foreground
            speed = 1.3;
            snow_foreground.add(snowflake);
        } else { // background
            speed = .7;
            snow_background.add(snowflake);
        }
    }    
    
	snowflake.velocity.set(FlxG.random.float(-60, -40) * speed, FlxG.random.float(100, 140) * speed);
    snowflake.angularVelocity = FlxG.random.float(-20, -100) * speed;
    var theScale = speed + FlxG.random.float(-.5, .5);
    snowflake.scale.set(theScale, theScale);
    snowflakes.push(snowflake);
}
function snow_get_snowGroup():FlxSpriteGroup
{
	return snowGroup;
}

function snow_setBoundariesFromGrid(gridMinX:Fkoat, gridMaxX:Fkoat, gridMinY:Float, gridMaxY:Float):Void
{
	minX = (gridMinX * Constants.overworldPixelScale) * 16;
	maxX = (gridMaxX * Constants.overworldPixelScale) * 16;
	minY = (gridMinY * Constants.overworldPixelScale) * 16;
	maxY = (gridMaxY * Constants.overworldPixelScale) * 16;
}

function snow_set_frequency(trueFrequency:Float):Void
{
	frequency = trueFrequency;
}
function snow_get_minX():Float
{
	return minX;
}

function snow_get_maxX():Float
{
	return maxX;
}

function snow_get_minY():Float
{
	return minY;
}

function snow_get_maxY():Float
{
	return maxY;
}