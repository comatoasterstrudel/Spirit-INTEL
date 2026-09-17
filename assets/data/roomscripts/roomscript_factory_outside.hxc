function CTSCRIPT_SETNAME():String
{
	return "factory_outside";
}

var frontDoor:Door;

function create():Void{
    frontDoor = getDoorByTag("frontdoor");

    if(!Save.storyFlags.get("factory_scarymode").val_bool){ // start of game
        var lightingCover = get_lightingCover();
        lightingCover.alpha = .25;
        
        executeSingleScriptFunction("snow", "snow_set_frequency", [.45]);  
        
        var light1 = getLightSourceByTag("light1");
        light1.visible = false;
        
        var light2 = getLightSourceByTag("light2");
        light2.visible = false;
        
        var doorway = getInteractableByTag("door");
        doorway.roomTransitionTime = .5;
    } else {
        frontDoor.room = "";
        frontDoor.dialogue = "factory/outside/dialogue_door";
    }
}