function CTSCRIPT_SETNAME():String
{
	return "factory_fireexitroom";
}

var player:Character;

var gridStart:Int = 20;
var gridEnd:Int = 40;

var colorA:Array<Int> = [0, 0, 0, 255];
var colorB:Array<Int> = [0, 19, 44, 255];

var colorGlow:Array<Int> = [0, 0, 0, 0];

var lastPlayerY:Float = 0;

var lightingShader:LightingEffectShader;

function create(){
    player = getCharacterByTag("player");
    lightingShader = get_lightingShader();
    
    setColor();
    updatePlayerPos();
}

function update(elapsed:Float){
    if(player.y != lastPlayerY){
        setColor();
    }
    updatePlayerPos();
}

function getYCordByGrid(pos:Float):Float{
    return ((pos * 16) * Constants.overworldPixelScale);
}

function updatePlayerPos():Void{
    lastPlayerY = player.y;
}

function setColor():Void{
    var factor = FlxMath.bound((player.y - getYCordByGrid(gridStart)) / (getYCordByGrid(gridEnd) - getYCordByGrid(gridStart)), 0, 1);
                
    var newcolor:Array<Int> = [];
            
    newcolor[0] = Std.int((colorB[0] - colorA[0]) * factor + colorA[0]);
    newcolor[1] = Std.int((colorB[1] - colorA[1]) * factor + colorA[1]);
    newcolor[2] = Std.int((colorB[2] - colorA[2]) * factor + colorA[2]);
    newcolor[3] = Std.int((colorB[3] - colorA[3]) * factor + colorA[3]);
            
    lightingShader.updateColorsFromArray(newcolor, colorGlow);
}