function CTSCRIPT_SETNAME():String
{
	return "factory_officebreakroom";
}

var snowGroup:FlxSpriteGroup;
var spr_behindTiles:FlxSpriteGroup;
var overMap:FlxSpriteGroup;

var character_robin:Player;
var sparkle:Prop;

var openFridge:Prop;
var openFridgeLight:LightSourceSprite;

var noodles:Prop;

var fridgedone:Interactable;
var noodleCutscene:Interactable;

var fade:CtSprite;

function create():Void{
    snowGroup = executeSingleScriptFunction("snow", "snow_get_snowGroup", []);    
    spr_behindTiles = get_spr_behindTiles();
    overMap = get_overMap();
    
    snow();

    character_robin = get_player();

    sparkle = getPropByTag("sparkle");

    openFridge = getPropByTag("openfridge");
    openFridgeLight = getLightSourceByTag("openfridge");

    noodles = getPropByTag("noodles");
    noodles.kill();
    
    fridgedone = getInteractableByTag("fridgedone");
    noodleCutscene = getInteractableByTag("noodleCutscene");

    if(Save.storyFlags.get("factory_gotNoodles").val_bool){
        sparkle.kill();
        openFridge.kill();
        openFridgeLight.kill();
        noodleCutscene.disabled = true;
    } else {
        fridgedone.disabled = true;
    }
    
    if(InitState.init_forceCutscene == "noodleaftermath"){
        prepNoodleAftermathCutscene();
        doNoodleAftermathCutscene();
        return;
    } else if(!Save.storyFlags.get("factory_seenOfficeBreakroomIntro").val_bool){
        doIntro();
    }

    setCameraScroll();
} 

function doIntro():Void{
    set_inCutscene(true);
    Save.storyFlags.get("factory_seenOfficeBreakroomIntro").val_bool = true;

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

		startDialogue(["factory/officebreakroom/dialogue_obr_intro"], function():Void
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

function table():Void{
    if(Save.storyFlags.get("factory_seenObrTable").val_bool){
        startDialogue(["factory/officebreakroom/dialogue_obr_table2"]);
    } else {
        Save.storyFlags.get("factory_seenObrTable").val_bool = true;

        startDialogue(["factory/officebreakroom/dialogue_obr_table1"]);
    }
}

function couch():Void{
    if(Save.storyFlags.get("factory_seenObrCouch").val_bool){
        startDialogue(["factory/officebreakroom/dialogue_obr_couch2"]);
    } else {
        Save.storyFlags.get("factory_seenObrCouch").val_bool = true;

        startDialogue(["factory/officebreakroom/dialogue_obr_couch1"]);
    }
}

function kitchenette():Void{
    if(Save.storyFlags.get("factory_seenObrKitchenette").val_bool){
        startDialogue(["factory/officebreakroom/dialogue_obr_kitchenette2"]);
    } else {
        Save.storyFlags.get("factory_seenObrKitchenette").val_bool = true;

        startDialogue(["factory/officebreakroom/dialogue_obr_kitchenette1"], function():Void{
            set_inCutscene(true);

            FlxTween.shake(character_robin, 0.05, .2, 0x01);
            CtSound.play(Constants.sfxPath + "crunch.ogg");

            new FlxTimer().start(1.5, function(f):Void{
                startDialogue(["factory/officebreakroom/dialogue_obr_kitchenette1cont"], function():Void{
                    set_inCutscene(false);
                });
            });
        });
    }
}

function doNoodleCutscene():Void{
    sparkle.kill();

    Save.storyFlags.get("factory_gotNoodles").val_bool = true;

    set_inCutscene(true);

    // "it's open ajar"
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("talk");

        startDialogue(["factory/officebreakroom/dialogue_obr_noodle1"], function():Void{
            OverworldState.eventManager.finishTransaction("talk");
        });
    });

    // walk backwards as noodles emerge
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("walk backwards");

        FlxTween.shake(character_robin, 0.05, .2, 0x01);

        new FlxTimer().start(.5, function(f):Void{
            character_robin.lockMovement = true;
            character_robin.lockAnims = true;

            character_robin.movementSpeed = .15;

            character_robin.animation.play("walk_left");

            character_robin.moveToGridSpace(10, -1, function():Void
            {                
                character_robin.facing = LEFT;
                character_robin.lockAnims = false;

                new FlxTimer().start(2, function(f):Void{
                    OverworldState.eventManager.finishTransaction("walk backwards");
                });
            });
        });

        CtSound.play(Constants.sfxPath + "noodle.ogg").pitch = .6;

        noodles.revive();
        noodles.animation.play("Noodles_Emerge", true);
    });

    // "..."
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("talk");

        startDialogue(["factory/officebreakroom/dialogue_obr_noodle2"], function():Void{
            OverworldState.eventManager.finishTransaction("talk");
        });
    });

    // start battle
	OverworldState.eventManager.addEvent(function()
	{
        startBattle("factory_mb_leftovers");
    });
}

function battleTransitionDone(name:String):Void{
    if(name == "factory_mb_leftovers"){
        doNoodleAftermathCutscene();
    }
}

function backFromBattle(name:String):Void{
    if(name == "factory_mb_leftovers"){
        prepNoodleAftermathCutscene();
    }
}

function doNoodleAftermathCutscene():Void{
    set_inCutscene(true);

    setCameraScroll();

    // slam door and turn robin to the left
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("slam");

        openFridge.kill();
        openFridgeLight.kill();
        CtSound.play(Constants.sfxPath + "fridgeclose.ogg");
        character_robin.facing = LEFT;

        new FlxTimer().start(2, function(f):Void{
            OverworldState.eventManager.finishTransaction("slam");
        });
    });

    // "god."
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("talk");

        startDialogue(["factory/officebreakroom/dialogue_obr_noodle3"], function():Void{
            OverworldState.eventManager.finishTransaction("talk");
        });
    });

    // "theres a lot of stuff youd expect"
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("talk");

        FlxTween.shake(character_robin, 0.05, .2, 0x01);
        CtSound.play(Constants.sfxPath + "managerslide.ogg").pitch = 1.5;

        fade.revive();
        FlxTween.tween(fade, {alpha: 1}, 2, {onComplete: function(f):Void{
            startDialogue(["factory/officebreakroom/dialogue_obr_noodle4"], function():Void{
                OverworldState.eventManager.finishTransaction("talk");
            });
        }});
    });

    // "what a boring meal"
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("talk");

        FlxTween.tween(fade, {alpha: 0}, 2, {onComplete: function(f):Void{
            fade.kill();
            startDialogue(["factory/officebreakroom/dialogue_obr_noodle5"], function():Void{
                OverworldState.eventManager.finishTransaction("talk");
            });
        }});
    });

    // done
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("talk");

        set_inCutscene(false);
        character_robin.facing = DOWN;
    });
}

function prepNoodleAftermathCutscene():Void{
    openFridge.revive();
    openFridgeLight.revive();
    character_robin.positionCharacterByGrid(10, 13);

    fade = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFF000000);
    fade.alpha = 0;
    fade.camera = camOverlay;
    add(fade);
    fade.kill();
}

function snow():Void{
    overMap.remove(snowGroup);
    spr_behindTiles.add(snowGroup); 
    
    snowGroup.alpha = .4;
    
    executeSingleScriptFunction("snow", "snow_set_frequency", [1.1]);    
    executeSingleScriptFunction("snow", "snow_setBoundariesFromGrid", [8, 20, 9, 11]);    
}

function setCameraScroll():Void{
    set_lockCamera(true);
    camGame.scroll.y = 355;
}