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

var passkey:Prop;

var dialogueBox:CtDialogueBox;

var pcBg:CtSprite;
var fadeSpr:CtSprite;

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

    passkey = getPropByTag("passkey");
    passkey.kill();
    
    dialogueBox = get_dialogueBox();

    handleBookCutscene();
    setupPc();

    if(InitState.init_forceCutscene == "bookaftermath"){
        setupBookAftermathCutscene();
        doBookAftermathCutscene();
        return;
    }
    if(!Save.storyFlags.get("factory_seenManagerOfficeIntro").val_bool){
        doIntro();
    }
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

function setupBookAftermathCutscene():Void{
    character_robin.positionCharacterByGrid(11, 9);
    passkey.revive();
}

function doBookAftermathCutscene():Void{
    set_inCutscene(true);

    character_robin.facing = DOWN;
    character_robin.lockMovement = true;

    // pause
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("pause");

        new FlxTimer().start(.5, function(f):Void{
            OverworldState.eventManager.finishTransaction("pause");
        });
    });

    // "this sucks"
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/manageroffice/dialogue_postbookscene1"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});

     // robin looks left, then wait
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("look left");

		character_robin.facing = LEFT;

        new FlxTimer().start(1, function(f):Void{
		    OverworldState.eventManager.finishTransaction("look left");
        });
	});

    // "something frll out of the book"
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/manageroffice/dialogue_postbookscene2"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	}); 

    // robin walks to the passkey and picks it up
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walk");

        character_robin.movementSpeed = .3;

        character_robin.moveToGridSpace(9.5, -1, function():Void
        {
            character_robin.lockAnims = true;
            character_robin.animation.play("crouch_left");

            new FlxTimer().start(1, function(f):Void{
                passkey.kill();
                character_robin.lockAnims = false;

                new FlxTimer().start(1, function(f):Void{
                    OverworldState.eventManager.finishTransaction("walk");
                });
            });
        });
    });

    // "it's a pass code.."
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("dia");

        var dialogueName = "factory/manageroffice/dialogue_postbookscene3";

        if(!Save.storyFlags.get("factory_interactedWithManagerComputer").val_bool){ //FIRST TIME
            dialogueName += "_alt";
        }

        startDialogue([dialogueName], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
    });
    
    // end cutscene
	OverworldState.eventManager.addEvent(function()
	{
        character_robin.lockMovement = false;
        character_robin.movementSpeed = 1;
        character_robin.facing = DOWN;

        set_inCutscene(false);
    });
}

function interactWithComputer():Void{
    if(!Save.storyFlags.get("factory_interactedWithManagerComputer").val_bool){ //FIRST TIME
        if(Save.storyFlags.get("factory_doneBookCutscene").val_bool){ // gotten passkey already
            Save.storyFlags.get("factory_interactedWithManagerComputer").val_bool = true;
            interactWithComputer();
            return;
        } else {
            Save.storyFlags.get("factory_interactedWithManagerComputer").val_bool = true;
            startDialogue(["factory/manageroffice/pc/dialogue_pc_intro"], function():Void
            {
                character_robin.facing = DOWN;
            });
        }
    } else {
        if(Save.storyFlags.get("factory_doneBookCutscene").val_bool){ // unlocked
            useComputer();
        } else { // locked still
            startDialogue(["factory/manageroffice/pc/dialogue_pc_introrepeat"]);
        }
    }
}

function useComputer():Void{
    if(!Save.storyFlags.get("factory_unlockedManagerComputer").val_bool){ // unlock it
        Save.storyFlags.get("factory_unlockedManagerComputer").val_bool = true;
        startDialogue(["factory/manageroffice/pc/dialogue_pc_unlock"], function():Void
        {
            useComputer();
        });
    } else { // actually use computer
        set_inCutscene(true);
        addPcBg(function():Void{
            var computerDialogues:Array<String> = [];

            if(!Save.storyFlags.get("factory_pcseenintro").val_bool){
                Save.storyFlags.get("factory_pcseenintro").val_bool = true;    

                computerDialogues.push("factory/manageroffice/pc/dialogue_pc_baseintro");
            }
            
            computerDialogues.push("factory/manageroffice/pc/dialogue_pc_base");

            if(Save.storyFlags.get("factory_pc_done").val_bool){
                startDialogue(["factory/manageroffice/pc/dialogue_pc_content_donerepeat"], function():Void{
                    pc_finish();
                });
            } else {
                startDialogue(computerDialogues);
            }
        });
    }
}

function setupPc():Void{
    dialogueBox.onChoicerSelected.add(function(tag:String):Void
    {
        switch(tag){
            case "Calendar":
                pc_calendar();
            case "E-Mail":
                pc_email();
            case "Messages":
                pc_messages();
            case "Nevermind":
                pc_nevermind();
        }
    });
    setupPcBg();
}

function pc_calendar():Void{
    set_inCutscene(true);
    new FlxTimer().start(0.11, function(f):Void{
        startDialogue(["factory/manageroffice/pc/dialogue_pc_content_calendar" + (Save.storyFlags.get("factory_pc_calendar").val_bool ? "_seen" : "")], function():Void
        {
            Save.storyFlags.get("factory_pc_calendar").val_bool = true;
            pc_finish();
        });
    });
}

function pc_email():Void{
    set_inCutscene(true);
    new FlxTimer().start(0.11, function(f):Void{
        startDialogue(["factory/manageroffice/pc/dialogue_pc_content_email" + (Save.storyFlags.get("factory_pc_email").val_bool ? "_seen" : "")], function():Void
        {
            Save.storyFlags.get("factory_pc_email").val_bool = true;
            pc_finish();
        });
    });
}

function pc_messages():Void{
    set_inCutscene(true);
    new FlxTimer().start(0.11, function(f):Void{
        startDialogue(["factory/manageroffice/pc/dialogue_pc_content_messages" + (Save.storyFlags.get("factory_pc_messages").val_bool ? "_seen" : "")], function():Void
        {
            Save.storyFlags.get("factory_pc_messages").val_bool = true;
            pc_finish();
        });
    });
}

function pc_nevermind():Void{
    pc_finish();
}

function pc_finish():Void{
    var seenEverything:Bool = (Save.storyFlags.get("factory_pc_calendar").val_bool && Save.storyFlags.get("factory_pc_email").val_bool && Save.storyFlags.get("factory_pc_messages").val_bool && !Save.storyFlags.get("factory_pc_done").val_bool);

    if(seenEverything){
        Save.storyFlags.get("factory_pc_done").val_bool = true;
        new FlxTimer().start(0.1, function(f):Void{
            startDialogue(["factory/manageroffice/pc/dialogue_pc_content_done"], function():Void
            {
                pc_finish();
            });
        });
    } else {
        removePcBg(function():Void{
            set_inCutscene(false);
            character_robin.facing = DOWN; 
        });
    }
}

function setupPcBg():Void{
    pcBg = new CtSprite().createFromImage(Constants.overworldMiscGraphicPath + "managerpc.png");
    pcBg.camera = camOverlay;
    pcBg.kill();
    pcBg.antialiasing = false;
    add(pcBg);

    fadeSpr = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFF000000);
    fadeSpr.camera = camOverlay;
    fadeSpr.kill();
    add(fadeSpr);
}

function addPcBg(onComplete:Void->Void):Void{
    pcBg.revive();
    pcBg.alpha = 0;
    
    fadeSpr.revive();
    fadeSpr.alpha = 0;

    FlxTween.tween(fadeSpr, {alpha: 1}, .5, {onComplete: function(f):Void{
        pcBg.alpha = 1;
        FlxTween.tween(fadeSpr, {alpha: 0}, .5, {onComplete: function(f):Void{
            fadeSpr.kill();
            onComplete();
        }});
    }});

}

function removePcBg(onComplete:Void->Void):Void{
    fadeSpr.revive();
    FlxTween.tween(fadeSpr, {alpha: 1}, .5, {onComplete: function(f):Void{
        pcBg.alpha = 0;
        FlxTween.tween(fadeSpr, {alpha: 0}, .5, {onComplete: function(f):Void{
            fadeSpr.kill();
            onComplete();
        }});
    }});
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

function doIntro():Void{
    set_inCutscene(true);
    Save.storyFlags.get("factory_seenManagerOfficeIntro").val_bool = true;

    // pause
	OverworldState.eventManager.addEvent(function()
	{
        OverworldState.eventManager.startTransaction("pause");

        new FlxTimer().start(1, function(f):Void{
            OverworldState.eventManager.finishTransaction("pause");
        });
    });

    // "its the managers office !"
    OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/manageroffice/dialogue_theintro"], function():Void
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

function backFromBattle(name:String):Void{
    if(name == "factory_mb_book"){
        setupBookAftermathCutscene();
    }
}

function battleTransitionDone(name:String):Void{
    if(name == "factory_mb_book"){
        doBookAftermathCutscene();
    }
}