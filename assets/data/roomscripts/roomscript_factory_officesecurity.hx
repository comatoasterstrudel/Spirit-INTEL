function CTSCRIPT_SETNAME():String
{
	return "factory_officesecurity";
}

var snowGroup:FlxSpriteGroup;
var spr_behindTiles:FlxSpriteGroup;
var overMap:FlxSpriteGroup;

var character_robin:Player;

var dialogueBox:CtDialogueBox;

function create():Void{
    snowGroup = executeSingleScriptFunction("snow", "snow_get_snowGroup", []);    
    spr_behindTiles = get_spr_behindTiles();
    overMap = get_overMap();
    
    snow();  

    character_robin = get_player();
    dialogueBox = get_dialogueBox();

    if(!Save.storyFlags.get("factory_seenSecurityIntro").val_bool){
        doIntro();
    }

    setupPc();
} 

function doIntro():Void{
    set_inCutscene(true);
    Save.storyFlags.get("factory_seenSecurityIntro").val_bool = true;

    // pause
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("pause");

        new FlxTimer().start(1, function(f):Void{
            OverworldState.eventManager.finishTransaction("pause");
        });
    });

    // "a break room ?"
    OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/officesecurity/dialogue_intro"], function():Void
		{
            OverworldState.eventManager.finishTransaction("dia");
		});
	});

    // end intro
    OverworldState.eventManager.addEvent(function()
	{
        set_inCutscene(false);
        character_robin.facing = DOWN;
    });
}

function chest():Void{
    startDialogue(["factory/officesecurity/dialogue_chest" + (Save.storyFlags.get("factory_seenSecurityChest").val_bool ? "seen" : "")]);
    Save.storyFlags.get("factory_seenSecurityChest").val_bool = true;
}

function pc():Void{
    startDialogue(["factory/officesecurity/dialogue_pc" + (Save.storyFlags.get("factory_seenSecurityPc").val_bool ? "seen" : "")]);
    Save.storyFlags.get("factory_seenSecurityPc").val_bool = true;
}

function snow():Void{
    overMap.remove(snowGroup);
    spr_behindTiles.add(snowGroup);
    
    snowGroup.alpha = .4;

    executeSingleScriptFunction("snow", "snow_set_frequency", [1.3]);    
    executeSingleScriptFunction("snow", "snow_setBoundariesFromGrid", [8, 21, 4, 6]);  
}

function setupPc():Void{
    dialogueBox.onChoicerSelected.add(function(tag:String):Void
    {
        switch(tag){
            case "cam":
                set_inCutsceneBeforeDialogue(true);
                doCameraCutscene(true, function():Void{
                    set_inCutscene(false);
                    character_robin.facing = DOWN;
                });
            case "Nevermind":
                character_robin.facing = DOWN;
        }
    });
}

function pcreal():Void{
    if(Save.storyFlags.get("factory_seenSecurityPc").val_bool){
        startDialogue(["factory/officesecurity/cameras/dialogue_cam_repeat"]);
    } else {
        Save.storyFlags.get("factory_seenSecurityPc").val_bool = true;

        startDialogue(["factory/officesecurity/cameras/dialogue_cam_1"], function():Void{
            doCameraCutscene(false, function():Void{
                set_inCutscene(false);
                character_robin.facing = DOWN;
            });
        });
    }
}

function doCameraCutscene(seen:Bool, onComplete:Void->Void):Void{
    set_inCutscene(true);

    startDialogue(["factory/officesecurity/cameras/dialogue_cam_2" + (seen ? "seen" : "")], function():Void{
        startDialogue(["factory/officesecurity/cameras/dialogue_cam_3" + (seen ? "seen" : "")], function():Void{
            onComplete();
        });
    });
}