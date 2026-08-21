function CTSCRIPT_SETNAME():String
{
	return "factory_lobby";
}

var character_player:Player;
var character_lobbysecretary:Character;
var character_laurin:Character;

var jessdialogue:Interactable;

var factoryjesscorpse:Prop;

var anims:Array<String> = ["idle_down", "blink", "idle_right", "blink"];
var progress:Int = 0;

var frontdoor:Door;
var inFirstCutscene:Bool = false;

var realdoor:Door;

var lightingCover:LightingSprite;

var addThisX:Int = 14;

function create():Void{
	character_player = get_player();
    character_lobbysecretary = getCharacterByTag("lobbysecretary");
	character_laurin = getCharacterByTag("laurin");

	frontdoor = getDoorByTag("frontdoor");

	realdoor = getDoorByTag("realdoor");

	lightingCover = get_lightingCover();

	factoryjesscorpse = getPropByTag("factoryjesscorpse");

	jessdialogue = getInteractableByTag("jessdialogue");

	if (Save.storyFlags.get("factory_scarymode").val_bool){
		setUpScary();
	} else {
		factoryjesscorpse.kill();
	}

	if (!Save.storyFlags.get("factory_seenLobbyConversation").val_bool)
	{
		doConversationCutscene();
	}
	else
	{
		character_laurin.kill();
		setupBlink();
		lockDoor();
	}

	if(!Save.storyFlags.get("factory_seenJessCorpse").val_bool){
		doCorpseCutscene();
	}
}

function update(elapsed:Float):Void
{
	if (inFirstCutscene)
	{
		frontdoor.alpha = 1;
	}
}

function doConversationCutscene():Void
{
	Save.storyFlags.get("factory_seenLobbyConversation").val_bool = true;

	set_inCutscene(true);
	set_lockCamera(true);

	character_player.lockMovement = true;
	character_player.positionCharacterByGrid(7 + addThisX, 17);
	character_player.visible = false;

	camGame.scroll.y = 1000;

	character_lobbysecretary.lockAnims = true;
	character_lobbysecretary.animation.play("idle_down");

	character_laurin.facing = RIGHT;

	inFirstCutscene = true;

	// CUTSCENE !!!

	// Camera moves upwards
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("cameraGoUp");

		FlxTween.tween(camGame.scroll, {y: 80}, 3, {
			onComplete: function(f):Void
			{
				OverworldState.eventManager.finishTransaction("cameraGoUp");
			}
		});
	});

	// Robin walks upwards
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("robinMove");

		character_player.visible = true;

		character_player.movementSpeed = .7;
		
		character_player.moveToGridSpace(7 + addThisX, 13.5, function():Void
		{
			character_player.moveToGridSpace(9 + addThisX, -1, function():Void
			{
				character_player.moveToGridSpace(9 + addThisX, 8.5, function():Void
				{
					character_player.moveToGridSpace(7 + addThisX, -1, function():Void
					{
						character_player.movementSpeed = 1;

						character_player.facing = UP;
						OverworldState.eventManager.finishTransaction("robinMove");
					});
				});
			});
		});
	});

	// Jess and Laurin look at robin
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("look");

		new FlxTimer().start(.5, function(f):Void
		{
			character_laurin.facing = DOWN;

			new FlxTimer().start(1, function(f):Void
			{
				OverworldState.eventManager.finishTransaction("look");
			});
		});
	});

	// Dialogue
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		startDialogue(["factory/lobby/dialogue_introcutscene"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dialogue");
		});
	});

	// Laurin walks away
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walkin away");

		character_laurin.movementSpeed = .7;

		character_laurin.moveToGridSpace(-1, 7, function():Void
		{
			character_laurin.moveToGridSpace(11.5 + addThisX, 5, function():Void
			{
				character_laurin.facing = UP;

				new FlxTimer().start(.5, function(f):Void
				{
					realdoor.playOpenSound();
					character_laurin.kill();
					new FlxTimer().start(1, function(f):Void
					{
						OverworldState.eventManager.finishTransaction("walkin away");
					});
				});
			});
		});
	});

	// last dialogue with jess
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		startDialogue(["factory/lobby/dialogue_introcutsceneend"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dialogue");
		});
	});

	// Camera goes back to robin
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("camra");

		FlxTween.tween(camGame.scroll, {y: 120}, .5, {
			onComplete: function(f):Void
			{
				OverworldState.eventManager.finishTransaction("camra");
			}
		});
	});

	// End cutscene
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("camra");

		inFirstCutscene = false;

		set_lockCamera(false);
		set_inCutscene(false);
		character_player.facing = DOWN;
		character_player.lockMovement = false;

		setupBlink();

		lockDoor();
		
		OverworldState.eventManager.finishTransaction("camra");
	});
}

function setupBlink():Void
{		
    character_lobbysecretary.lockAnims = true;
    
    doBlink();
}

function doBlink():Void{
    character_lobbysecretary.animation.play(anims[progress]);

    new FlxTimer().start(anims[progress] == "blink" ? .5 : 3, function(f):Void{
        doBlink();
    });
    
    progress ++;
    if(progress >= anims.length) progress = 0;
}
function lockDoor():Void
{
	frontdoor.room = "";
	frontdoor.dialogue = "factory/lobby/dialogue_exitdoor";
}

function setUpScary():Void{
	lightingCover.alpha = .5;
	frontdoor.disabled = true;
	frontdoor.kill();
	jessdialogue.disabled = true;
	new FlxTimer().start(0.01, function(f):Void{
		FlxG.sound.music.stop();
	});
	character_lobbysecretary.kill();
}

function doCorpseCutscene():Void{
	Save.storyFlags.get("factory_seenJessCorpse").val_bool = true;

	set_inCutscene(true);
	set_lockCamera(true);
	set_unbindCamera(true);

	character_player.positionCharacterByGrid(25.5, 5);
	character_player.lockMovement = true;

	// robin enters room
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("enters");

		character_player.kill();

		new FlxTimer().start(1, function(f):Void{
			realdoor.playOpenSound();
			character_player.revive();

			OverworldState.eventManager.finishTransaction("enters");
		});
	});

	// walks downwards
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walk downwards");

		character_player.moveToGridSpace(-1, 8.5, function():Void
		{
			character_player.moveToGridSpace(23, 15, function():Void
			{
				character_player.lockAnims = true;
				character_player.positionCharacterByGrid(21, 14.9);
				character_player.animation.play("surprise");

				new FlxTimer().start(1, function(f):Void{
					OverworldState.eventManager.finishTransaction("walk downwards");
				});
			});
		});
	});

	// camera move down
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("camera move down");

		FlxTween.tween(camGame.scroll, {y: camGame.scroll.y + 550}, 3.3, {ease: FlxEase.quartInOut, onComplete: function(f):Void{
			OverworldState.eventManager.finishTransaction("camera move down");
		}});
	});

	// oh my god
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		new FlxTimer().start(.5, function(f):Void{
			startDialogue(["factory/lobby/jesscorpse/dialogue_corpsescene1"], function():Void
			{
				OverworldState.eventManager.finishTransaction("dialogue");
			});
		});
	});

	// robin walks down to jess
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walkdown");

		character_player.lockAnims = false;
		character_player.ignoreCollision = true;
		character_player.movementSpeed = .3;
		character_player.moveToGridSpace(-1, 16, function():Void
		{
			OverworldState.eventManager.finishTransaction("walkdown");
		});
	});

	// robin checks jess' pulse
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("checkpulse");

		character_player.lockAnims = true;
		character_player.animation.play("crouch_front");

		OverworldState.eventManager.finishTransaction("checkpulse");
	});

	// shes gone
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		new FlxTimer().start(2, function(f):Void{
			startDialogue(["factory/lobby/jesscorpse/dialogue_corpsescene2"], function():Void
			{
				new FlxTimer().start(2, function(f):Void{
					OverworldState.eventManager.finishTransaction("dialogue");
				});
			});
		});
	});

	// monster screams off screen
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("monster scream");

		CtSound.play(Constants.sfxPath + "lobbymonsterecho.ogg");

		new FlxTimer().start(.35, function(f):Void{
			FlxTween.shake(character_player, 0.05, .2, 0x01);
			character_player.animation.play("crouch_lookover");

			new FlxTimer().start(5.5, function(f):Void{
				OverworldState.eventManager.finishTransaction("monster scream");
			});
		});
	});

	// "we gotta get outta here1!!""
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		startDialogue(["factory/lobby/jesscorpse/dialogue_corpsescene3"], function():Void
		{
			new FlxTimer().start(1, function(f):Void{
				OverworldState.eventManager.finishTransaction("dialogue");
			});
		});
	});

	// slowly walk backwards
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walkbackwards");

		character_player.lockAnims = true;

		character_player.animation.play("walk_down");

		character_player.movementSpeed = .15;

		character_player.moveToGridSpace(-1, 15, function():Void
		{
			character_player.lockAnims = false;
			character_player.facing = DOWN;

			new FlxTimer().start(.5, function(f):Void{
				OverworldState.eventManager.finishTransaction("walkbackwards");
			});
		});
	});

	// walk to door
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walktodoor");

		character_player.movementSpeed = .5;

		character_player.moveToGridSpace(23, -1, function():Void
		{
			factoryjesscorpse.data.yStackingOffset = -999;

			character_player.moveToGridSpace(-1, 17, function():Void
			{
				character_player.moveToGridSpace(21, -1, function():Void
				{
					character_player.facing = DOWN;
					OverworldState.eventManager.finishTransaction("walktodoor");
				});
			});
		});
	});

	// try to use door
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walktodoor");

		new FlxTimer().start(.4, function(f):Void{
			CtSound.play(Constants.sfxPath + "lobbydoorstuck.ogg");
			
			character_player.lockAnims = true;

			character_player.animation.play("door_one");

			new FlxTimer().start(.25, function(f):Void{
				character_player.animation.play("door_two");

				new FlxTimer().start(.25, function(f):Void{
					character_player.animation.play("jossledoor");
				});
			});

			new FlxTimer().start(2.5, function(f):Void{
				OverworldState.eventManager.finishTransaction("walktodoor");
			});
		});
	});

	// "door stuck ! door stuck !"
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		character_player.animation.play("door_two");

		startDialogue(["factory/lobby/jesscorpse/dialogue_corpsescene4"], function():Void
		{
			character_player.lockAnims = false;

			OverworldState.eventManager.finishTransaction("dialogue");
		});
	});
}