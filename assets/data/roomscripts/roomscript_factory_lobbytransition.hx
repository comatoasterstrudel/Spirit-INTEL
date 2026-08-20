function CTSCRIPT_SETNAME():String
{
	return "factory_lobbytransition";
}

var character_laurin:Character;
var character_manager:Character;
var character_player:Player;

var cutsceneTrigger:Interactable;

var lightingCover:LightingSprite;

function create(){
    character_laurin = getCharacterByTag("laurin");
    character_laurin.facing = UP;
    
    character_manager = getCharacterByTag("manager");
    character_player = get_player();
    cutsceneTrigger = getInteractableByTag("cutscenetrigger");
    
    lightingCover = get_lightingCover();

    if(Save.storyFlags.get("factory_seenTransitionCutscene").val_bool){ // disable cutscene        
        character_laurin.kill();
        character_manager.kill();
        removeCutsceneTrigger();
    }        

	if(Save.storyFlags.get("factory_scarymode").val_bool){ //SCARY
		setUpScary();
	}
}

function update(elapsed:Float){
    //
}

function startcutscene():Void{
    var initY:Float = 0;
    
    Save.storyFlags.get("factory_seenTransitionCutscene").val_bool = true;
	removeCutsceneTrigger();
    
	set_lockCamera(true);
    set_inCutscene(true);
    
    // move up camera
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("moveup");

        initY = camGame.scroll.y;
        
		FlxTween.tween(camGame.scroll, {y: 500}, 2, { ease: FlxEase.quartOut,
			onComplete: function(f):Void
			{
				OverworldState.eventManager.finishTransaction("moveup");
			}
		});		
	});
    
    // dimmaialogue
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialog");

		startDialogue(["factory/lobbytransition/dialogue_hallwaycutscene"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dialog");
		});
	});
    
    // go back down and have laurin and manager walk up
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("godown");
	
        character_laurin.moveToGridSpace(-1, 0);
        character_laurin.movementSpeed = .3;
        
        character_manager.moveToGridSpace(-1, 0);
        character_manager.movementSpeed = .3;

        FlxTween.tween(camGame.scroll, {y: 710}, 3, { ease: FlxEase.quartInOut,
			onComplete: function(f):Void
			{
                character_laurin.kill();
                character_manager.kill();
                
				OverworldState.eventManager.finishTransaction("godown");
			}
		});	
	});
    
    // end cutscene
	OverworldState.eventManager.addEvent(function()
	{
		set_lockCamera(false);
        set_inCutscene(false);
        character_player.facing = DOWN;
	});
}

function removeCutsceneTrigger():Void{
    cutsceneTrigger.disabled = true;
}

function setUpScary():Void{
	lightingCover.alpha = .5;
}