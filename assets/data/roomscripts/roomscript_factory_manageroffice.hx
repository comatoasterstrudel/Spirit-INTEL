function CTSCRIPT_SETNAME():String
{
	return "factory_manageroffice";
}

var snowGroup:FlxSpriteGroup;
var spr_behindTiles:FlxSpriteGroup;
var overMap:FlxSpriteGroup;

var sparkle:Prop;
var bookcutscenetrigger:Interactable;
var managerofficebookmissing:Prop;

var monsterbook:Prop;

var character_robin:Player;

function create():Void{
    doSnow(); 
    
    sparkle = getPropByTag("sparkle");
    bookcutscenetrigger = getInteractableByTag("bookcutscenetrigger");
    managerofficebookmissing = getPropByTag("managerofficebookmissing");
    managerofficebookmissing.setPosition(sparkle.x, sparkle.y);
    managerofficebookmissing.kill();

    monsterbook = getPropByTag("monsterbook");
    monsterbook.kill();

    character_robin = get_player();

    handleBookCutscene();
} 

function handleBookCutscene():Void{
    if(Save.storyFlags.get("factory_doneBookCutscene").val_bool){
        sparkle.kill();
        bookcutscenetrigger.scriptFunction = "";
        bookcutscenetrigger.dialogue = "factory/manageroffice/dialogue_shelfleftpostcutscene";
        managerofficebookmissing.revive();
    } else {
        managerofficebookmissing.kill();
    }
}

function doBookCutscene():Void{
    set_inCutscene(true);
    character_robin.lockMovement = true;

    Save.storyFlags.get("factory_doneBookCutscene").val_bool = true;
    handleBookCutscene();
    managerofficebookmissing.kill();

    // "there are many books here"
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/manageroffice/dialogue_grabbook1"], function():Void
		{
            character_robin.movementSpeed = .3;

            character_robin.moveToGridSpace(-1, 9, function():Void
		    {
                character_robin.moveToGridSpace(9.5, -1, function():Void
		        {
                    character_robin.facing = UP;
                    character_robin.animation.play("idle_up");
                    character_robin.lockAnims = true;
                    OverworldState.eventManager.finishTransaction("dia");
                });
            });
		});
	});

    // robin gets book
    OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("getBook");

        CtSound.play(Constants.sfxPath + "grabbook.ogg");

        FlxTween.tween(character_robin.hitbox, {y: character_robin.hitbox.y - 12}, .3, {
            onComplete: function(F):Void
            {
                managerofficebookmissing.revive();
                character_robin.animation.play("putaway_book");

                new FlxTimer().start(1, function(f):Void{
                    character_robin.animation.play("idle_up");

                    new FlxTimer().start(1, function(f):Void{
                        OverworldState.eventManager.finishTransaction("getBook");
                    });
                });

                FlxTween.tween(character_robin.hitbox, {y: character_robin.hitbox.y + 12}, .3);
            }
        });
    });

    // "the book says"
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/manageroffice/dialogue_grabbook2"], function():Void
		{
            new FlxTimer().start(.5, function(f):Void{
                OverworldState.eventManager.finishTransaction("dia");
            });
		});
	});

    // "yeah... ill just put that back"
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/manageroffice/dialogue_grabbook3"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});

    // robin puts book back
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("put back book");

        character_robin.animation.play("putaway_book");
                
        CtSound.play(Constants.sfxPath + "putbookback.ogg");

        FlxTween.tween(character_robin.hitbox, {y: character_robin.hitbox.y - 12}, .6, {
            onComplete: function(F):Void
            {
               new FlxTimer().start(.5, function(f):Void{
                    FlxTween.shake(character_robin, 0.05, .2, 0x01);
                    character_robin.animation.play("glow_book");

                    CtSound.play(Constants.sfxPath + "bookalive.ogg");

                    new FlxTimer().start(1, function(f):Void{
                        FlxTween.tween(character_robin.hitbox, {y: character_robin.hitbox.y + 12}, .2, {
                            OverworldState.eventManager.finishTransaction("put back book");
                        });
                    });
               });
            }
        });
    });

    // robin walks back, book comes alive
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walk");
		OverworldState.eventManager.startTransaction("book");

        CtSound.play(Constants.sfxPath + "bookalive.ogg").pitch = .5;

        character_robin.animation.play("walk_left");

        character_robin.movementSpeed = .6;

        character_robin.ignoreCollision = true;

        character_robin.moveToGridSpace(11, -1, function():Void
		{
            character_robin.animation.play("neutral_suprised");

			OverworldState.eventManager.finishTransaction("walk");
		});

        monsterbook.revive();
        monsterbook.alpha = 0;

        for(i in 0...5){
            new FlxTimer().start(.2 * i, function(f):Void{
                monsterbook.alpha += .2;
            });
        }

        new FlxTimer().start(1, function(f):Void{
            FlxTween.shake(monsterbook, 0.05, .2, 0x01);
            monsterbook.animation.play("evil");

            new FlxTimer().start(1, function(f):Void{
                FlxTween.shake(monsterbook, 0.05, .2, 0x01);
                monsterbook.animation.play("tongue");

                new FlxTimer().start(1.5, function(f):Void{
                    OverworldState.eventManager.finishTransaction("book");
                });
            });
        });
    });

    // "oh shit"
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/manageroffice/dialogue_grabbook4"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});

    // start battle
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

        character_robin.lockAnims = false;
        
		startBattle("factory_mb_book");
	});
}

function interactWithComputer():Void{
    trace("fart");
}

function doSnow():Void{
    snowGroup = executeSingleScriptFunction("snow", "snow_get_snowGroup", []);    
    spr_behindTiles = get_spr_behindTiles();
    overMap = get_overMap();
    
    overMap.remove(snowGroup);
    spr_behindTiles.add(snowGroup);
    
    snowGroup.alpha = .4;
    
    executeSingleScriptFunction("snow", "snow_set_frequency", [.5]);    
    executeSingleScriptFunction("snow", "snow_setBoundariesFromGrid", [12, 19, 4, 8]);  
}