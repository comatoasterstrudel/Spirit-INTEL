function CTSCRIPT_SETNAME():String
{
	return "factory_outsidefireexit";
}

var fireexitdoor:Door;

function create():Void{
    fireexitdoor = getDoorByTag("fireexitdoor");
    
    if(!Save.storyFlags.get("factory_scarymode").val_bool){ // start of game
       
        fireexitdoor.room = "";
        fireexitdoor.dialogue = "factory/outsidefireexit/dialogue_fireexitlocked";
        
        var lightingCover = get_lightingCover();
        lightingCover.alpha = .25;
        
        executeSingleScriptFunction("snow", "snow_set_frequency", [.45]);  
        
        var light1 = getLightSourceByTag("light1");
        light1.visible = false;
        
        var doorway = getInteractableByTag("door");
        doorway.roomTransitionTime = .5;
    } else {
        fireexitdoor.room = "";
        fireexitdoor.dialogue = "factory/outsidefireexit/dialogue_hellno";
    }
}