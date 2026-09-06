function CTSCRIPT_SETNAME():String
{
	return "factory_officehallway2";
}

var doorTopLeft:Door;
var bottomDoor:Door;

var character_player:Player;

var managerofficedoor:Door;
var breakroomdoor:Door;
var securitydoor:Door;

function create():Void{
    doorTopLeft = getDoorByTag("doorTopLeft");
    bottomDoor = getDoorByTag("bottomDoor");

    character_player = get_player();

    managerofficedoor = getDoorByTag("managerofficedoor");
    breakroomdoor = getDoorByTag("breakroomdoor");
    securitydoor = getDoorByTag("securitydoor");

    if(!Save.storyFlags.get("factory_sawFireDoorLocked").val_bool){
        doFireDoorLockedCutscene();
    }

    updateDoors();
}

function update(elapsed:Float):Void{
    //
}

function doFireDoorLockedCutscene():Void{
    set_inCutscene(true);
    set_lockCamera(true);
    set_unbindCamera(true);

    character_player.positionCharacterByGrid(7.5, 9);
    character_player.kill();
    character_player.lockMovement = true;

    bottomDoor.visible = false;

    Save.storyFlags.get("factory_sawFireDoorLocked").val_bool = true;

    // robin enters room
    OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("enter room");

        new FlxTimer().start(1, function(f):Void{
            character_player.revive();
            doorTopLeft.playOpenSound();

            OverworldState.eventManager.finishTransaction("enter room");
        });
    });

    
    // robin walks to door and move camera down
    OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("walkdown");

        character_player.moveToGridSpace(-1, 12.5, function():Void{
            character_player.moveToGridSpace(18, -1, function():Void{
                character_player.moveToGridSpace(-1, 18, function():Void{
                    new FlxTimer().start(.5, function(f):Void{
                        OverworldState.eventManager.finishTransaction("walkdown");
                    });
                });
            });
        });

        FlxTween.tween(camGame.scroll, {y: 450}, 4);
    });

    // jangle door
    OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("jossle");

        CtSound.play(Constants.sfxPath + "lobbydoorstuck.ogg");
                
        character_player.lockAnims = true;

        character_player.animation.play("door_one");

        new FlxTimer().start(.25, function(f):Void{
            character_player.animation.play("door_two");

            new FlxTimer().start(.25, function(f):Void{
                character_player.animation.play("jossledoor");

                new FlxTimer().start(1, function(f):Void{
                    OverworldState.eventManager.finishTransaction("jossle");
                });
            });
        });
    });

    // "the door is locked"
    OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("dialogue");

        character_player.lockAnims = false;

		startDialogue(["factory/officehallway2/dialogue_locked1"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dialogue");
		});
    });

    // walk upwards
    OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("walk upwards");

        character_player.lockAnims = true;

        character_player.animation.play("walk_down");
        character_player.movementSpeed = .3;

        character_player.moveToGridSpace(-1, 16, function():Void{
            character_player.animation.play("idle_down");
            OverworldState.eventManager.finishTransaction("walk upwards");
        });
    });

     // "so we need some kind of code ?"
    OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("dialogue");

		startDialogue(["factory/officehallway2/dialogue_locked2"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dialogue");
		});
    });

    // "so we need some kind of code ?"
    OverworldState.eventManager.addEvent(function()
	{
        bottomDoor.visible = true;
        bottomDoor.alpha = 0;

        moveCameraBackToPlayer(1.5, null, function():Void{
            set_lockCamera(false);
            set_unbindCamera(false);
            set_inCutscene(false);

            character_player.lockMovement = false;
            character_player.movementSpeed = 1;
            character_player.lockAnims = false;
            character_player.facing = DOWN;
        });
    });
}

function openBottomDoor():Void{
    executeSingleScriptFunction("codeentry", "setCode", [[1, 2, 7, 4, 0, 0]]);
    executeSingleScriptFunction("codeentry", "openMenu", [
        function(correct:Bool):Void{ // corrent answer
            var seenCodes:Bool = (Save.storyFlags.get("factory_pc_done").val_bool && Save.storyFlags.get("factory_gotNoodles").val_bool && true);

            if(correct){
                startDialogue(["factory/officehallway2/dialogue_doorcode_right" + (seenCodes ? "_seen" : "")], function():Void
                {
                    moveRoom("factory_officetransition", 2);
                });
            } else {
                startDialogue(["factory/officehallway2/dialogue_doorcode_wrong" + (seenCodes ? "_seen" : "")], function():Void
                {
                    set_inCutscene(false);
                });
            }
        }
    ]);
}

function updateDoors():Void{
    var doorOneComplete:Bool = Save.storyFlags.get("factory_pc_done").val_bool;
    var doorTwoComplete:Bool = Save.storyFlags.get("factory_gotNoodles").val_bool;

    if(!doorOneComplete){ // lock door 2 and 3
        breakroomdoor.room = "";
        breakroomdoor.dialogue = "factory/officehallway2/dialogue_doorslocked1";

        securitydoor.room = "";
        securitydoor.dialogue = "factory/officehallway2/dialogue_doorslocked1";
    } else if(!doorTwoComplete){ //lock door 3
        securitydoor.room = "";
        securitydoor.dialogue = "factory/officehallway2/dialogue_doorslocked2";
    }
}