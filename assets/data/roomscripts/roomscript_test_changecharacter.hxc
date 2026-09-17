function CTSCRIPT_SETNAME():String
{
	return "test_flags";
}

var changed:Bool = false;

function dochange():Void{
    if(changed) return;
    
    changed = true;
    
    var robin = getCharacterByTag("player");
    var laurin = getCharacterByTag("laurin");
    
    
    robin.initCharacterAnimations("laurin");
    laurin.initCharacterAnimations("robin");
}