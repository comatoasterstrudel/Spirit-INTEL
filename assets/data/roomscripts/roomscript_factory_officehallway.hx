function CTSCRIPT_SETNAME():String
{
	return "factory_officehallway";
}

var player:Character;

var gridStart:Int = 14;
var gridEnd:Int = 26;

var dark:Float = .7;

function create(){
    player = getCharacterByTag("player");    
}

function update(elapsed:Float){
    var lightingCover = get_lightingCover();
    lightingCover.alpha = dark * FlxMath.bound((player.x - getXCordByGrid(gridStart)) / (getXCordByGrid(gridEnd) - getXCordByGrid(gridStart)), 0, 1);
}

function getXCordByGrid(pos:Float):Float{
    return ((pos * 16) * Constants.overworldPixelScale);
}