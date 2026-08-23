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

var fullart_fade:CtSprite;
var fullart_frame:CtSprite;
var fullart_frameLBg:CtSprite;
var fullart_frameRBg:CtSprite;
var fullart_robin:CtSprite;
var fullart_keycard:CtSprite;
var fullart_bg:CtSprite;

var keycard:Prop;

function create():Void{
	character_player = get_player();
    character_lobbysecretary = getCharacterByTag("lobbysecretary");
	character_laurin = getCharacterByTag("laurin");

	frontdoor = getDoorByTag("frontdoor");

	realdoor = getDoorByTag("realdoor");

	lightingCover = get_lightingCover();

	factoryjesscorpse = getPropByTag("factoryjesscorpse");

	jessdialogue = getInteractableByTag("jessdialogue");

	keycard = getPropByTag("keycard");
	keycard.kill();

	if (Save.storyFlags.get("factory_scarymode").val_bool){
		setUpScary();

		if(!Save.storyFlags.get("factory_seenJessCorpse").val_bool){
			doCorpseCutscene();
		}
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
	setUpFullArt();

	Save.storyFlags.get("factory_seenJessCorpse").val_bool = true;
	Save.storyFlags.get("factory_officedoorkeyobtained").val_bool = true;

	set_inCutscene(true);
	set_lockCamera(true);
	set_unbindCamera(true);

	character_player.positionCharacterByGrid(25.5, 5);
	character_player.lockMovement = true;

	keycard.revive();
	
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

	// shake out of it robin!!
	OverworldState.eventManager.addEvent(function()
	{	
		OverworldState.eventManager.startTransaction("dialogue");

		FlxTween.shake(character_player, 0.05, .2, 0x01);
		character_player.lockAnims = false;

		new FlxTimer().start(1, function(f):Void{
			OverworldState.eventManager.finishTransaction("dialogue");
		});
	});

	// robin walks down to jess
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walkdown");

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

		new FlxTimer().start(.5, function(f):Void{
			FlxTween.shake(factoryjesscorpse, 0.05, .2, 0x01);
			CtSound.play(Constants.sfxPath + "checkjess.ogg");
		});

		OverworldState.eventManager.finishTransaction("checkpulse");
	});

	// shes gone
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		new FlxTimer().start(2.5, function(f):Void{
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

		character_player.movementSpeed = .7;

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

	// show full art
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("full art");

		fullart_fade.visible = true;
		fullart_fade.alpha = 0;

		FlxTween.tween(fullart_fade, {alpha: 1}, 2, {onComplete: function(f):Void{
			fullart_frame.visible = true;
			fullart_bg.visible = true;
			
			FlxTween.tween(fullart_fade, {alpha: 0}, 2, {onComplete: function(f):Void{
				OverworldState.eventManager.finishTransaction("full art");
			}});
		}});
	});

	// robin fade in
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("robingoin");

		new FlxTimer().start(.5, function(f):Void{		
			
			for(spr in [fullart_frameLBg, fullart_robin]){
				spr.visible = true;
				spr.alpha = 0;
				FlxTween.tween(spr, {alpha: 1}, 1, {ease: FlxEase.quartOut});
			}

			fullart_robin.x += 30;
			FlxTween.tween(fullart_robin, {x: 0}, 1.5, {ease: FlxEase.quartOut, onComplete: function(f):Void{
				OverworldState.eventManager.finishTransaction("robingoin");
			}});
		});
	});

	// keycard fade in
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("karcardgoin");

		new FlxTimer().start(2, function(f):Void{		
			
			for(spr in [fullart_frameRBg, fullart_keycard]){
				spr.visible = true;
				spr.alpha = 0;
				FlxTween.tween(spr, {alpha: 1}, 1, {ease: FlxEase.quartOut});
			}

			fullart_keycard.x -= 30;
			FlxTween.tween(fullart_keycard, {x: 0}, 1.5, {ease: FlxEase.quartOut, onComplete: function(f):Void{
				OverworldState.eventManager.finishTransaction("karcardgoin");
			}});
		});
	});

	// fade full art and walk to keycard
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("full art");
		OverworldState.eventManager.startTransaction("walk");

		fullart_fade.visible = true;
		fullart_fade.alpha = 0;

		FlxTween.tween(fullart_fade, {alpha: 1}, 2, {startDelay: 1, onComplete: function(f):Void{
			fullart_frame.destroy();
			fullart_frameLBg.destroy();
			fullart_frameRBg.destroy();
			fullart_robin.destroy();
			fullart_keycard.destroy();
			fullart_bg.destroy();
			
			camGame.scroll.y -= 100;
			character_player.positionCharacterByGrid(23, 15);

			character_player.movementSpeed = .4;
			character_player.moveToGridSpace(19, 15, function():Void
			{	
				OverworldState.eventManager.finishTransaction("walk");
			});

			FlxTween.tween(fullart_fade, {alpha: 0}, 2, {onComplete: function(f):Void{
				fullart_fade.destroy();
				OverworldState.eventManager.finishTransaction("full art");
			}});
		}});
	});

	// pick up keycard
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("pickup key cardd");

		character_player.lockAnims = true;
		character_player.animation.play("crouch_left");

		CtSound.play(Constants.sfxPath + "crouch.ogg");

		new FlxTimer().start(1, function(f):Void{
			character_player.animation.play("left_lanyard");
			keycard.kill();

			CtSound.play(Constants.sfxPath + "keycard.ogg");

			new FlxTimer().start(2, function(f):Void{
				character_player.lockAnims = false;

				new FlxTimer().start(1, function(f):Void{
					OverworldState.eventManager.finishTransaction("pickup key cardd");
				});
			});
		});
	});

	// "we can go thru fire  exit ahahha"
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		startDialogue(["factory/lobby/jesscorpse/dialogue_corpsescene5"], function():Void
		{
			character_player.lockAnims = false;

			OverworldState.eventManager.finishTransaction("dialogue");
		});
	});

	// scroll camera
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("scrll");

		FlxTween.tween(camGame.scroll, {y: 243.07}, 2, {onComplete: function(f):Void{
			OverworldState.eventManager.finishTransaction("scrll");
		}});
	});

	// end cutscene
	OverworldState.eventManager.addEvent(function()
	{
		set_inCutscene(false);
		set_unbindCamera(false);
		
		character_player.ignoreCollision = false;

		character_player.lockMovement = false;
		character_player.movementSpeed = 1;

		set_lockCamera(false);

		factoryjesscorpse.data.yStackingOffset = 0;

		character_player.facing = DOWN;
	});
}

function setUpFullArt():Void
{
	fullart_bg = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "keycard_bgColor.png");
	fullart_bg.screenCenter();
	fullart_bg.camera = camOverlay;
	fullart_bg.visible = false;
	add(fullart_bg);

	fullart_frameRBg = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "keycard_frameRBg.png");
	fullart_frameRBg.screenCenter();
	fullart_frameRBg.camera = camOverlay;
	fullart_frameRBg.visible = false;
	fullart_frameRBg.antialiasing = false;
	add(fullart_frameRBg);
	
	fullart_keycard = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "keycard_keycard.png");
	fullart_keycard.screenCenter();
	fullart_keycard.camera = camOverlay;
	fullart_keycard.visible = false;
	fullart_keycard.antialiasing = false;
	add(fullart_keycard);

	fullart_frameLBg = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "keycard_frameLBg.png");
	fullart_frameLBg.screenCenter();
	fullart_frameLBg.camera = camOverlay;
	fullart_frameLBg.visible = false;
	fullart_frameLBg.antialiasing = false;
	add(fullart_frameLBg);
	
	fullart_robin = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "keycard_robin.png");
	fullart_robin.screenCenter();
	fullart_robin.camera = camOverlay;
	fullart_robin.visible = false;
	fullart_robin.antialiasing = false;
	add(fullart_robin);

	fullart_frame = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "keycard_frame.png");
	fullart_frame.screenCenter();
	fullart_frame.camera = camOverlay;
	fullart_frame.visible = false;
	fullart_frame.antialiasing = false;
	add(fullart_frame);

	fullart_fade = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFF000000);
	fullart_fade.camera = camOverlay;
	fullart_fade.visible = false;
	add(fullart_fade);
}