function CTSCRIPT_SETNAME():String
{
	return "factory_breakroom";
}

var inTheCutscene:Bool = false;
var inParty:Bool = false;

var door:Door;

var character_player:Player;
var character_manager:Character;
var character_laurin:Character;
var character_coworkerA:Character;
var character_coworkerB:Character;
var character_coworkerC:Character;
var character_coworkerD:Character;
 
var party_laurin:Interactable;
var party_coworkerA:Interactable;
var party_coworkerB:Interactable;
var party_coworkerC:Interactable;
var party_coworkerD:Interactable;
var partyInteractables:Array<Interactable> = [];
var dialogueBox:CtDialogueBox;

function create():Void{
	door = getDoorByTag("door");
	
	character_player = get_player();
	character_manager = getCharacterByTag("manager");
	character_laurin = getCharacterByTag("laurin");
	character_coworkerA = getCharacterByTag("coworkerA");
	character_coworkerB = getCharacterByTag("coworkerB");
	character_coworkerB.facing = RIGHT;
	character_coworkerC = getCharacterByTag("coworkerC");
	character_coworkerD = getCharacterByTag("coworkerD");
	character_coworkerD.facing = LEFT;

	party_laurin = getInteractableByTag("party_laurin");
	party_coworkerA = getInteractableByTag("party_coworkerA");
	party_coworkerB = getInteractableByTag("party_coworkerB");
	party_coworkerC = getInteractableByTag("party_coworkerC");
	party_coworkerD = getInteractableByTag("party_coworkerD");

	partyInteractables = [party_laurin, party_coworkerA, party_coworkerB, party_coworkerC, party_coworkerD];

	for (i in partyInteractables)
	{
		i.disabled = true;
	}

	dialogueBox = get_dialogueBox();
	
	if (!Save.storyFlags.get("factory_seenbreakroomcutscene").val_bool || InitState.init_forceCutscene == "breakroomparty")
	{
		doCutscene();
	}
	else
	{
		character_manager.kill();
		character_laurin.kill();
		character_coworkerA.kill();
		character_coworkerB.kill();
		character_coworkerC.kill();
		character_coworkerD.kill();
	}
}

function update(elapsed:Float):Void{
	if (inTheCutscene)
	{
		door.alpha = 1;
	}
}

function doCutscene():Void{	
	OverworldState.setUpMusic(Constants.roomMusicPath + "party.ogg", 3);

	set_inCutscene(true);
	
	set_lockCamera(true);
	
	inTheCutscene = true;
	
	character_player.lockMovement = true;
	character_player.positionCharacterByGrid(8.5, 14);
	character_player.movementSpeed = .2;
	
	camGame.scroll.y = 150;
	
	OverworldState.lastTransitionTime = 0;
	
	// CUTSCENE !!!

	//start fade in
	OverworldState.eventManager.addEvent(function()
	{
		var fade = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFF000000);
		fade.camera = camOverlay;
		add(fade);
		
		FlxTween.tween(fade, {alpha: 0}, 3, {onComplete: function(f):Void{
			fade.destroy();
		}});
	});
	
	// Camera moves upwards
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("cameraGoUp");

		character_player.moveToGridSpace(8.5, 11.5);
		
		FlxTween.tween(camGame.scroll, {y: 65}, 3, {
			ease: FlxEase.sineOut,
			onComplete: function(f):Void
			{
				OverworldState.eventManager.finishTransaction("cameraGoUp");
			}
		});
	});
	
	// initial dialogue
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		new FlxTimer().start(.75, function(f):Void{
			startDialogue(["factory/breakroom/dialogue_party_cutscene_1"], function():Void
			{	
				OverworldState.eventManager.finishTransaction("dialogue");
			});
		});
	});
	
	// clap clap
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("clap clap");

		character_laurin.facing = LEFT;
		character_coworkerA.facing = LEFT;
		character_coworkerB.facing = UP;
		character_coworkerC.facing = RIGHT;
		character_coworkerD.facing = UP;

		var maxFrames:Int = 4;
		var frames:Int = 0;

		character_manager.lockAnims = true;

		character_manager.animation.onFrameChange.add(function(name:String, frameNum:Int, frameIndex:Int):Void
		{
			if (name == "clap")
			{
				frames++;
				if (frameNum == 1)
				{
					CtSound.play(Constants.sfxPath + "clap_" + FlxG.random.int(1, 4) + ".ogg");
				} 
				if (frames >= maxFrames)
				{
					character_manager.lockAnims = false;
					character_manager.animation.play("idle_down");
					OverworldState.eventManager.finishTransaction("clap clap");
				}
			}
		});
		character_manager.animation.play("clap", false, false, 1);
	});
	
	// initial dialogue
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		new FlxTimer().start(1, function(f):Void
		{
			startDialogue(["factory/breakroom/dialogue_party_cutscene_2"], function():Void
			{
				OverworldState.eventManager.finishTransaction("dialogue");
			});
		});
	});
	// confetti
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("confetti");

		character_manager.lockAnims = true;

		character_manager.animation.play("prepop");

		new FlxTimer().start(.65, function(f):Void
		{
			CtSound.play(Constants.sfxPath + "pop.ogg");

			character_manager.animation.play("popped");

			doConfetti(character_manager.x + 30, character_manager.y + 37);

			new FlxTimer().start(2, function(f):Void
			{
				OverworldState.eventManager.finishTransaction("confetti");
			});
		});
	});
	// ermm awkward!
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("awkward");

		character_manager.animation.play("pop_look_right");

		new FlxTimer().start(2, function(F):Void
		{
			character_manager.animation.play("pop_closed");

			new FlxTimer().start(.3, function(F):Void
			{
				character_manager.animation.play("pop_look_left");

				new FlxTimer().start(2.5, function(F):Void
				{
					character_manager.animation.play("pop_awkward");

					new FlxTimer().start(1.5, function(F):Void
					{
						OverworldState.eventManager.finishTransaction("awkward");
					});
				});
			});
		});
	});
	// clap 2
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("clap");

		var maxClaps:Int = 8;
		var claps:Int = 0;

		character_manager.animation.onFrameChange.add(function(name:String, frameNum:Int, frameIndex:Int):Void
		{
			if (name == "fastClap" && frameNum == 1)
			{
				claps++;

				if (claps >= maxClaps)
				{
					character_manager.lockAnims = false;
					character_manager.animation.play("idle_down");
					OverworldState.eventManager.finishTransaction("clap");
				}
				else if (frameNum == 1)
				{
					CtSound.play(Constants.sfxPath + "clap_" + FlxG.random.int(1, 4) + ".ogg");
				}
			}
		});
		character_manager.animation.play("fastClap", false, false, 1);

	});

	// dialogue 2
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		startDialogue(["factory/breakroom/dialogue_party_cutscene_3"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dialogue");
		});
	});
	// dialogue 2
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		new FlxTimer().start(1, function(f):Void
		{
			dialogueBox.onEvent.add(function(event:String):Void
			{
				if (event == "coworkerjump")
				{
					FlxTween.tween(character_coworkerC.hitbox, {y: character_coworkerC.hitbox.y - 12}, .1, {
						onComplete: function(F):Void
						{
							FlxTween.tween(character_coworkerC.hitbox, {y: character_coworkerC.hitbox.y + 12}, .1);
						}
					});
				} else if (event == "tunedownmusic")
				{
					FlxG.sound.music.pitch = .9;
				}
			});

			startDialogue(["factory/breakroom/dialogue_party_cutscene_4"], function():Void
			{
				FlxG.sound.music.fadeOut(4);
				OverworldState.eventManager.finishTransaction("dialogue");
			});
		});
	});

	// walk away
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walkaway");

		character_laurin.movementSpeed = .5;
		character_laurin.moveToGridSpace(15, 6, function():Void
		{
			character_laurin.facing = LEFT;
		});
		character_manager.movementSpeed = .6;
		character_manager.moveToGridSpace(13, -1, function():Void
		{
			character_laurin.facing = DOWN;
			character_manager.moveToGridSpace(-1, 13, function():Void
			{
				character_manager.moveToGridSpace(8.5, 15, function():Void
				{
					character_manager.kill();

					new FlxTimer().start(1, function(f):Void
					{
						OverworldState.eventManager.finishTransaction("walkaway");
					});
				});
			});
		});
	});

	// dialogue 2
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialogue");

		startDialogue(["factory/breakroom/dialogue_party_cutscene_5"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dialogue");
		});
	});
	// end
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("end");

		FlxTween.tween(camGame.scroll, {y: 152}, 1, {
			onComplete: function(f):Void
			{
				inTheCutscene = false;
				startParty();
				character_player.lockMovement = false;
				set_inCutscene(false);
				set_lockCamera(false);
				character_player.facing = DOWN;
				character_player.movementSpeed = 1;

				OverworldState.eventManager.finishTransaction("end");
			}
		});
	});
}

function doConfetti(x:Int, y:Int):Void
{
	var baseSprite:CtSprite = new CtSprite(x, y).createColorBlock(10, 10, 0xFFFF0000);
	baseSprite.camera = camGame;
	// add(baseSprite);

	var amountOfConfetti:Int = 30;

	for (i in 0...amountOfConfetti)
	{
		var confettiColors = [0xFFDC81C5, 0xFFA51E83, 0xFF81A2DC, 0xFFB8F7F5];

		var confetti:CtSprite = new CtSprite().createColorBlock(FlxG.random.int(5, 8), FlxG.random.int(5, 8),
			confettiColors[FlxG.random.int(0, confettiColors.length - 1)]);
		CtUtil.centerSpriteOnSprite(confetti, baseSprite, true, true);
		confetti.camera = camGame;
		add(confetti);

		var velocX:Float = FlxG.random.float(-100, 100);

		confetti.velocity.set(velocX, FlxG.random.float(-30, -200));

		var time:Float = FlxG.random.float(1, 4);

		confetti.angularVelocity = (velocX);

		FlxTween.tween(confetti, {angularVelocity: 0}, time);

		FlxTween.tween(confetti.velocity, {x: 0, y: 0}, time, {
			onComplete: function(f):Void
			{
				confetti.acceleration.y = FlxG.random.float(50, 100);
				confetti.acceleration.x = velocX / 2;

				FlxTween.tween(confetti, {alpha: 0}, time / 1.2, {
					onComplete: function(F):Void
					{
						confetti.destroy();
					}
				});
			}
		});
	}
}

function startParty():Void
{
	OverworldState.setUpMusic(Constants.roomMusicPath + "partyfull.ogg", 0, true);

	inParty = true;

	door.room = "";
	door.dialogue = "factory/breakroom/dialogue_party_door";

	for (i in partyInteractables)
	{
		i.disabled = false;
	}
}

function endParty():Void
{
	Save.storyFlags.get("factory_seenbreakroomcutscene").val_bool = true;

	set_inCutscene(true);

	startDialogue(["factory/breakroom/dialogue_party_laurin"], function():Void
	{
		var fade = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFF000000);
		fade.camera = camOverlay;
		fade.alpha = 0;
		add(fade);

		FlxG.sound.music.fadeOut(3, 0, function(f):Void{
			FlxG.sound.music.destroy();
		});	
		FlxTween.tween(fade, {alpha: 1}, 3, {
			onComplete: function(f):Void
			{
				startDialogue(["factory/breakroom/dialogue_party_over_1"], function():Void
				{
					character_laurin.kill();
					character_coworkerA.kill();
					character_coworkerB.kill();
					character_coworkerC.kill();
					character_coworkerD.kill();

					party_laurin.disabled = true;
					party_coworkerA.disabled = true;
					party_coworkerB.disabled = true;
					party_coworkerC.disabled = true;
					party_coworkerD.disabled = true;

					door.room = "factory_hallway";
					door.dialogue = "";

					character_player.positionCharacterByGrid(8.5, 11);
					character_player.facing = UP;
					character_player.changeAnimationPrefix("party_");

					FlxTween.tween(fade, {alpha: 0}, 3, {
						onComplete: function(f):Void
						{
							startDialogue(["factory/breakroom/dialogue_party_over_2"], function():Void
							{
								character_player.facing = DOWN;
								set_inCutscene(false);
							});
						}
					});
				});
			}
		});
	});
}