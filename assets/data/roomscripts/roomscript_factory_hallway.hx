function CTSCRIPT_SETNAME():String
{
	return "factory_hallway";
}

var breakRoomDoor:Door;
var officeDoor:Door;
var finaldoor:Door;
var bathroom1:Interactable;
var bathroom2:Interactable;
var bathroom3:Interactable;

var bottomDoorIsOpen:Bool = false;

var character_player:Player;
var character_managerscary:Character;
var character_laurin:Character;

var lightingCover:LightingSprite;
var inMonsterCutscene:Bool = false;

var laurinphonedialogue:Interactable;

var spr_behindProps:FlxSpriteGroup;
var props:FlxTypedSpriteGroup<FlxSprite>;
var spr_top:FlxSpriteGroup;
var fadeBg:CtSprite;

var dialogueBox:CtDialogueBox;

var fullart_fade:CtSprite;
var fullart_bg:CtSprite;
var fullart_robin1:CtSprite;
var fullart_robin2:CtSprite;
var fullart_volor:CtSprite;

var doorCutsceneActive:Bool = false;

function create(){
    breakRoomDoor = getDoorByTag("breakRoomDoor");
    officeDoor = getDoorByTag("officeDoor");
    finaldoor = getDoorByTag("finaldoor");
    bathroom1 = getInteractableByTag("bathroom1");
    bathroom2 = getInteractableByTag("bathroom2");
    bathroom3 = getInteractableByTag("bathroom3");

	character_player = get_player();
	character_managerscary = getCharacterByTag("managerscary");
	character_managerscary.kill();
	character_laurin = getCharacterByTag("laurin");
	character_laurin.kill();

	lightingCover = get_lightingCover();

	spr_behindProps = get_spr_behindProps();
	props = get_props();
	spr_top = get_spr_top();
	
	dialogueBox = get_dialogueBox();
	
	laurinphonedialogue = getInteractableByTag("laurinphonedialogue");
	laurinphonedialogue.disabled = true;

    updateDialogues();
	if (InitState.init_forceCutscene == "hallwaymonster" || Save.storyFlags.get("factory_monsterscene1").val_bool && !Save.storyFlags.get("factory_seentutorial").val_bool)
	{
		startMonsterCutscene();
	} else if(InitState.init_forceCutscene == "hallwaymonster2" || Save.storyFlags.get("factory_seentutorial").val_bool && !Save.storyFlags.get("factory_scarymode").val_bool){
		// tutorial over
		startEndOfTutorialCutscene();
	} else if(InitState.init_forceCutscene == "hallwaydoor" || Save.storyFlags.get("factory_officedoorkeyobtained").val_bool && !Save.storyFlags.get("factory_officedooropened").val_bool){
		startDoorCutscene();
	} else if(Save.storyFlags.get("factory_scarymode").val_bool){
		setupScary();
	}
}

function update(elapsed:Float){
	if (inMonsterCutscene || doorCutsceneActive)
	{
		finaldoor.alpha = 1;

		if (running)
		{
			//
		}
	}
}

function opensDoor():Void{
	if(Save.storyFlags.get("factory_officedoorkeyobtained").val_bool){
		startDialogue(["factory/hallway/dialogue_opensdoor"], function():Void
		{
			officeDoor.room = "poop";
			officeDoor.openDoor();
			moveRoom("factory_officehallway", 2);
		});
	} else {
		if(Save.storyFlags.get("factory_seenbreakroomcutscene").val_bool){
			Save.storyFlags.get("factory_officedoorinteractions").val_int += 1;
		}
		updateDialogues();
	}
}

function updateDialogues():Void{
	if (Save.storyFlags.get("factory_scarymode").val_bool || Save.storyFlags.get("factory_seentutorial").val_bool)
	{
		return;
	}
	
    if(!Save.storyFlags.get("factory_officedoorkeyobtained").val_bool){
        officeDoor.room = "";
        
        if(Save.storyFlags.get("factory_seenbreakroomcutscene").val_bool){
            switch(Save.storyFlags.get("factory_officedoorinteractions").val_int){
                case 0:
                    officeDoor.dialogue = "factory/hallway/dialogue_officedoor_0";
                case 1:
                    officeDoor.dialogue = "factory/hallway/dialogue_officedoor_1";
                default:
                    officeDoor.dialogue = "factory/hallway/dialogue_officedoor_2";
            }
        } else {
            officeDoor.dialogue = "factory/hallway/dialogue_officedoor_locked";
        }
    }
    
    if(Save.storyFlags.get("factory_seenbreakroomcutscene").val_bool){ // seen the party
		character_player.changeAnimationPrefix("party_");

        breakRoomDoor.room = "";
        
        if(Save.storyFlags.get("factory_officedoorinteractions").val_int > 0){
            breakRoomDoor.dialogue = "factory/hallway/dialogue_door_manager";
            for(br in [bathroom1, bathroom2, bathroom3]){
                br.dialogue = "factory/hallway/dialogue_br_manager";
            }
            
            finaldoor.dialogue = "";
            finaldoor.room = "factory_production";
            finaldoor.roomTransitionTime = 1.5;
            bottomDoorIsOpen = true;
        } else {
            breakRoomDoor.dialogue = "factory/hallway/dialogue_door_nogood";     
            
            finaldoor.room = "";
            finaldoor.dialogue = "factory/hallway/dialogue_finaldoor_dontgothere";     
        }
    }
}

function leavingRoom():Void{
    if(bottomDoorIsOpen){
        Save.storyFlags.get("factory_startedmonstercutscene").val_bool = true;
    }
}
// monster scenee
function startMonsterCutscene():Void
{
	inMonsterCutscene = true;

	character_managerscary.changeAnimationPrefix("stand-");
	character_managerscary.animation.play("stand-idle_up");
	
	set_inCutscene(true);
	set_lockCamera(true);
	set_unbindCamera(true);
	camGame.scroll.x = 450;
	lightingCover.alpha = .5;

	character_player.positionCharacterByGrid(24, 15);
	character_player.movementSpeed = 1.5;
	character_player.lockAnims = true;
	character_player.lockMovement = true;

	setUpFullArt();

	// run up
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("run away!!!!");

		new FlxTimer().start(.5, function(F):Void
		{
			character_player.animation.play("walk_up_fast");

			character_player.moveToGridSpace(-1, 11.3, function():Void
			{
				OverworldState.eventManager.finishTransaction("run away!!!!");
			});
		});
	});

	// run left
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("run2");

		character_player.animation.play("shocked_run");

		character_player.moveToGridSpace(11, -1, function():Void
		{
			character_player.animation.play("shocked_idle");

			new FlxTimer().start(.2, function(F):Void
			{
				OverworldState.eventManager.finishTransaction("run2");
			});
		});

		new FlxTimer().start(.8, function(F):Void
		{
			character_managerscary.revive();
			character_managerscary.movementSpeed = 1.3;

			character_managerscary.positionCharacterByGrid(23.5, 14);

			character_managerscary.moveToGridSpace(-1, 10.3, function():Void
			{
				running = true;
				character_managerscary.moveToGridSpace(13, -1, function():Void
				{
					running = false;
				});
			});
		});
	});

	// look right
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("turning");

		facing = RIGHT;
		character_player.flipX = true;
		character_player.animation.play("shocked_idle");

		new FlxTimer().start(.8, function(f):Void
		{
			OverworldState.eventManager.finishTransaction("turning");
		});
	});

	// step back and look up
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("shocked_stepback");

		character_player.movementSpeed = .3;
		character_player.animation.play("shocked_stepback");
		character_player.move(character_player.x - 20, -1, function():Void
		{
			character_player.flipX = false;
			character_player.animation.play("lookup_scared");
			FlxTween.shake(character_player, 0.05, .2, 0x01);
			new FlxTimer().start(1.2, function(f):Void
			{
				OverworldState.eventManager.finishTransaction("shocked_stepback");
			});
		});
	});
	// dimmalog
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/hallway/monster/dialogue_evilscarybit_1"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});
	// robin step back further, manager walks close
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("robin goes backward");

		character_player.movementSpeed = .1;
		character_player.animation.play("stepback_lookup");
		character_player.move(character_player.x - 40, -1, function():Void
		{
			FlxTween.shake(character_player, 0.05, .2, 0x01);
			character_player.animation.play("lookup_scared");

			OverworldState.eventManager.finishTransaction("robin goes backward");
		});
		OverworldState.eventManager.startTransaction("monster walks");

		for (i in 0...6)
		{
			new FlxTimer().start(1.5 * i, function(f):Void
			{
				moveManagerForward(true, i >= 3);
				if (i == 5)
				{
					OverworldState.eventManager.finishTransaction("monster walks");
				}
			});
		}
	});
	// fade to sillouhette
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("fade");

		var fadetime:Float = 3;

		FlxTween.tween(lightingCover, {alpha: 0}, fadetime);

		fadeBg = new CtSprite().createColorBlock(FlxG.width * 2, FlxG.height * 2, 0xFFFFFFFF);
		fadeBg.alpha = 0;
		fadeBg.x -= 400;
		spr_top.add(fadeBg);

		for (char in [character_player, character_managerscary])
		{
			props.remove(char);
			spr_top.add(char);
			FlxTween.color(char, fadetime, char.color, 0xFF000000);
		}

		FlxTween.tween(fadeBg, {alpha: 1}, fadetime);

		new FlxTimer().start(fadetime, function(f):Void
		{
			OverworldState.eventManager.finishTransaction("fade");
		});
	});
	// fade to sillouhette
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("moveCamera");

		FlxTween.tween(camGame.scroll, {x: -50}, 2.5, {
			onComplete: function(F):Void
			{
				character_managerscary.animation.play("attack");
				new FlxTimer().start(.8, function(f):Void
				{
					OverworldState.eventManager.finishTransaction("moveCamera");
				});
			}
		});
	});
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("fade more");

		for (char in [character_player, character_managerscary])
		{
			FlxTween.tween(char, {alpha: 0}, 2);
		}

		new FlxTimer().start(2.5, function(f):Void
		{
			CtSound.play(Constants.sfxPath + "jacketshatter.ogg");

			fadeBg.color = 0xFF000000;

			character_player.alpha = 1;
			character_player.animation.play("jacket_glow");
			character_player.color = 0xFFFFFF;

			FlxTween.tween(character_player, {alpha: 0}, 1);
			
			new FlxTimer().start(1, function(f):Void
			{
				OverworldState.eventManager.finishTransaction("fade more");
			});
		});
	});
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("fade more");

		CtSound.play(Constants.sfxPath + "managerslide.ogg");

		for (char in [character_player, character_managerscary])
		{
			char.alpha = 1;
			char.color = 0xFFFFFFFF;
			spr_top.remove(char);
			props.add(char);
		}

		fadeBg.destroy();

		camGame.scroll.x = 450;

		character_player.animation.play("shocked_idle");
		character_player.flipX = true;
		character_player.hitbox.x += 40;
		character_managerscary.lockAnims = true;
		character_managerscary.animation.play("real_idle_left");
		FlxTween.tween(character_managerscary.hitbox, {x: character_managerscary.hitbox.x + 170}, 1.5, {ease: FlxEase.quartOut});
		new FlxTimer().start(2.3, function(F):Void
		{
			OverworldState.eventManager.finishTransaction("fade more");
		});
	});
	// dimmalog
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/hallway/monster/dialogue_evilscarybit_2"], function():Void
		{
			FlxTween.shake(character_player, 0.05, .2, 0x01);

			new FlxTimer().start(1, function(f):Void
			{
				OverworldState.eventManager.finishTransaction("dia");
			});
		});
	});

	// dimmalog
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		dialogueBox.onEvent.add(function(event:String):Void
		{
			if (event == "volorappears")
			{
				CtSound.play(Constants.sfxPath + "volorappear.ogg");
				camUI.shake(0.05, .2, null, true, 0x01);
			}
		});

		startDialogue(["factory/hallway/monster/dialogue_evilscarybit_3"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});

	// start full art
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("fullart");

		fullart_fade.visible = true;
		fullart_fade.alpha = 0;

		FlxTween.tween(fullart_fade, {alpha: 1}, 2, {onComplete: function(f):Void{
			fullart_bg.visible = true;
			fullart_robin1.visible = true;

			FlxTween.tween(fullart_fade, {alpha: 0}, 2, {onComplete: function(f):Void{
				OverworldState.eventManager.finishTransaction("fullart");	
			}});
		}});
	});

	// start dialogue
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/hallway/monster/dialogue_evilscarybit_4"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});

	// volor slides in
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("slide");

		fullart_robin1.visible = false;
		fullart_robin2.visible = true;
		fullart_volor.visible = true;

		FlxTween.tween(fullart_robin2, {x: 400}, 1, {ease: FlxEase.quartOut});
		FlxTween.tween(fullart_volor, {x: 0}, 1, {ease: FlxEase.quartOut});

		FlxTween.shake(fullart_robin2, 0.1, .2, 0x01);

		new FlxTimer().start(2, function(f):Void{
			OverworldState.eventManager.finishTransaction("slide");
		});
	});

	// start dialogue 2
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/hallway/monster/dialogue_evilscarybit_5"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});

	// remove full art
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("undofade");

		fullart_fade.visible = true;
		fullart_fade.alpha = 0;

		FlxTween.tween(fullart_fade, {alpha: 1}, 2, {onComplete: function(f):Void{
			fullart_bg.visible = false;
			fullart_robin2.visible = false;
			fullart_volor.visible = false;

			FlxTween.tween(fullart_fade, {alpha: 0}, 2, {onComplete: function(f):Void{
				OverworldState.eventManager.finishTransaction("undofade");	
			}});
		}});
	});

	// manager gets up
	OverworldState.eventManager.addEvent(function()
	{
		set_unbindCamera(true);
		FlxTween.tween(camGame.scroll, {x: 0, y: 320}, 2.5, {ease: FlxEase.quartInOut});

		OverworldState.eventManager.startTransaction("get up");

		character_managerscary.animation.onFrameChange.add(function(name:String, frameNum:Int, frameIndex:Int):Void
		{
			if (name == "standup" || name == "Kneel-Left")
			{
				FlxTween.shake(character_managerscary, 0.05, .2, 0x01);

				if (frameNum == 1)
				{
					new FlxTimer().start(1, function(f):Void
					{
						character_managerscary.flipX = false;

						OverworldState.eventManager.finishTransaction("get up");
					});
				}
			}
		});

		character_managerscary.lockAnims = true;
		character_managerscary.animation.play("Kneel-Left");
	});

	// manager walks toward robin
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("monster walks");

		for (i in 0...11)
		{
			new FlxTimer().start(.4 * i, function(f):Void
			{
				moveManagerForward((i < 6), (i >= 5));
				if (i == 10)
				{
					OverworldState.eventManager.finishTransaction("monster walks");
				}
			});
		}

		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/hallway/monster/dialogue_evilscarybit_6"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});

	// dimmalog
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/hallway/monster/dialogue_evilscarybit_7"], function():Void
		{
			FlxTween.tween(lightingCover, {alpha: 0}, .8, {
				onComplete: function(F):Void
				{
					character_player.flipX = false;
					character_player.lockAnims = false;
					Save.storyFlags.get("factory_seentutorial").val_bool = true;
					startBattle("factory_tutorial");
				}
			});
		});
	});
}

var lightingIncrease:Float = 0.07; 
var lightingIncreaseOvershoot:Float = 0.03;

function moveManagerForward(doLighting:Bool, useLookUpwardAnim:Bool)
{
	if (doLighting)
	{
		lightingCover.alpha += lightingIncrease + lightingIncreaseOvershoot;
		FlxTween.num(lightingCover.alpha, lightingCover.alpha - lightingIncreaseOvershoot, .5, {}, function(num:Float):Void
		{
			lightingCover.alpha = num;
		});
	}

	character_managerscary.lockAnims = true;
	character_managerscary.animation.play(useLookUpwardAnim ? "stand-lookdown-shuffle" : "stand-walksingle_left", false, false, 1);
	character_managerscary.hitbox.x -= 13;
	FlxTween.shake(character_managerscary, 0.05, .2, 0x01, {
		onComplete: function(f):Void
		{
			if (useLookUpwardAnim)
			{
				character_managerscary.animation.play("stand-lookdown-shuffle", true, false, 0);
			}
			else
			{
				character_managerscary.lockAnims = false;
			}
		}
	});
}

function battleTransitionDone(battleName:String):Void
{
	if (battleName == "factory_tutorial")
	{
		character_player.facing = DOWN;
		set_inCutscene(true);

		new FlxTimer().start(1, function(f):Void
		{
			set_inCutscene(false);
		});
	}
}

function startEndOfTutorialCutscene():Void{
	OverworldState.lastTransitionTime = 0;
	OverworldState.leftForBattle = false;

	set_unbindCamera(true);
	camGame.scroll.x = 400;

	set_inCutscene(true);

	character_player.positionCharacterByGrid(11, 11.3);
	character_player.facing = RIGHT;

	character_managerscary.revive();
	character_managerscary.positionCharacterByGrid(14, 10.3);
	character_managerscary.changeAnimationPrefix("stand-");
	character_managerscary.facing = RIGHT;
	FlxTween.shake(character_managerscary, 0.2, .3, 0x01);

	character_laurin.revive();
	character_laurin.positionCharacterByGrid(19, 11.3);
	character_laurin.facing = LEFT;
	character_laurin.lockAnims = true;
	character_laurin.animation.play("shoot");

	// monster runs away wounded
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("monstar run awat");

		CtSound.play(Constants.sfxPath + "lauringun.ogg");

		new FlxTimer().start(1, function(f):Void{
			CtSound.play(Constants.sfxPath + "managerfall.ogg");
			
			FlxTween.shake(character_managerscary, 0.03, .2, 0x01);
			character_managerscary.changeAnimationPrefix("");
			character_managerscary.hitbox.y += 30;

			new FlxTimer().start(1, function(f):Void{
				character_managerscary.movementSpeed = 2;

				character_managerscary.moveToGridSpace(-1, 9.5, function():Void
				{
					new FlxTimer().start(.2, function(f):Void{
						character_laurin.animation.play("idle_up");

						new FlxTimer().start(.3, function(f):Void{
							character_laurin.animation.play("shoot");
							character_laurin.flipX = true;
						});
					});

					character_managerscary.moveToGridSpace(35, -1, function():Void
					{
						character_managerscary.kill();

						camGame.shake(0.02, 0.2, null, true, 0x10);

						CtSound.play(Constants.sfxPath + "officedoorslam.ogg");

						OverworldState.eventManager.finishTransaction("monstar run awat");
					});
				});
			});
		});
	});

	// dialogue "..."
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		new FlxTimer().start(1.5, function(f):Void{
			startDialogue(["factory/hallway/monster/dialogue_lauringunpause"], function():Void
			{
				OverworldState.eventManager.finishTransaction("dia");
			});
		});
	});

	// laurin puts gun down
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("gun put down");

		character_laurin.animation.play("gun_readyup");

		new FlxTimer().start(.25, function(f):Void{
			character_laurin.lockAnims = false;
			character_laurin.facing = RIGHT;
			character_laurin.flipX = false;
			character_laurin.changeAnimationPrefix("upset_");

			new FlxTimer().start(.25, function(f):Void{
				OverworldState.eventManager.finishTransaction("gun put down");
			});
		});
	});

	// dimmalog
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		new FlxTimer().start(.5, function(f):Void{
			character_laurin.facing = LEFT;
		});

		new FlxTimer().start(1.3, function(f):Void{
			startDialogue(["factory/hallway/monster/dialogue_lauringun"], function():Void
			{
				OverworldState.eventManager.finishTransaction("dia");
			});
		});
	});

	// laurir walks backward.
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walkback");

		character_laurin.lockAnims = true;
		character_laurin.animation.play("upset_walk_down");
		character_laurin.movementSpeed = .3;
		character_laurin.moveToGridSpace(-1, 9, function():Void{
			character_laurin.facing = DOWN;
			character_laurin.lockAnims = false;

			new FlxTimer().start(.5, function(f):Void{
				character_laurin.lockAnims = true;
				character_laurin.animation.play("phone");

				CtSound.play(Constants.sfxPath + "laurinopenphone.ogg");

				new FlxTimer().start(2, function(f):Void{
					OverworldState.eventManager.finishTransaction("walkback");
				});
			});
		});
	});

	// robin walks to laurin
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walkback");
		
		character_player.lockMovement = true;
		character_player.movementSpeed = .8;
		character_player.moveToGridSpace(19, -1, function():Void{
			character_player.facing = UP;

			OverworldState.eventManager.finishTransaction("walkback");
		});
	});

	// dialogue 1
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		new FlxTimer().start(1, function(f):Void{
			startDialogue(["factory/hallway/monster/dialogue_laurinphone"], function():Void
			{
				OverworldState.eventManager.finishTransaction("dia");
			});
		});
	});

	// dialogue 2
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		FlxTween.shake(character_player, 0.05, .2, 0x01);

		new FlxTimer().start(1, function(f):Void{
			startDialogue(["factory/hallway/monster/dialogue_laurinphone2"], function():Void
			{
				OverworldState.eventManager.finishTransaction("dia");
			});
		});
	});

	// cutscene over
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("cutsceneover");

		moveCameraBackToPlayer(1, null, function():Void{
			set_inCutscene(false);
			set_lockCamera(false);
			set_unbindCamera(false);

			character_player.lockMovement = false;
			character_player.movementSpeed = 1;

			character_player.facing = DOWN;

			Save.storyFlags.get("factory_scarymode").val_bool = true;

			OverworldState.lastTransitionTime = 0.5;

			setupScary();
		});
	});
}

function setupScary():Void{
	if(!Save.storyFlags.get("factory_officedoorkeyobtained").val_bool){
		officeDoor.room = "";
		officeDoor.dialogue = "factory/hallway/dialogue_officedoor_locked";
		
		character_laurin.revive();
		character_laurin.positionCharacterByGrid(19, 9);
		character_laurin.changeAnimationPrefix("upset_");
		character_laurin.lockAnims = true;
		character_laurin.animation.play("phone");

		laurinphonedialogue.disabled = false;
	} else {
		officeDoor.room = "";
	}
}

function setUpFullArt():Void{
	fullart_bg = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "volorintro_bgColor.png");
	fullart_bg.screenCenter();
	fullart_bg.camera = camOverlay;
	fullart_bg.visible = false;
	add(fullart_bg);

	fullart_robin1 = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "volorintro_robin1.png");
	fullart_robin1.screenCenter();
	fullart_robin1.camera = camOverlay;
	fullart_robin1.visible = false;
	fullart_robin1.antialiasing = false;
	add(fullart_robin1);

	fullart_robin2 = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "volorintro_robin2.png");
	fullart_robin2.screenCenter();
	fullart_robin2.camera = camOverlay;
	fullart_robin2.visible = false;
	fullart_robin2.antialiasing = false;
	add(fullart_robin2);

	fullart_volor = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "volorintro_volor.png");
	fullart_volor.screenCenter();
	fullart_volor.x -= fullart_volor.width;
	fullart_volor.camera = camOverlay;
	fullart_volor.visible = false;
	fullart_volor.antialiasing = false;
	add(fullart_volor);

	fullart_fade = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFF000000);
	fullart_fade.camera = camOverlay;
	fullart_fade.visible = false;
	add(fullart_fade);
}

function startDoorCutscene():Void{
	setupScary();

	Save.storyFlags.get("factory_officedooropened").val_bool = true;

	doorCutsceneActive = true;

	set_inCutscene(true);

	character_player.visible = false;
	character_player.positionCharacterByGrid(24, 15);
	character_player.lockMovement = true;

	// robin walks upwards
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walkupwards");

		new FlxTimer().start(.5, function(f):Void{
			character_player.visible = true;

			character_player.moveToGridSpace(-1, 11, function():Void{
				OverworldState.eventManager.finishTransaction("walkupwards");
			});
		});
	});

	// robin looks around
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("lookaround");

		new FlxTimer().start(.5, function(f):Void{
			character_player.facing = LEFT;
			new FlxTimer().start(.5, function(f):Void{
				character_player.facing = UP;
				new FlxTimer().start(.5, function(f):Void{
					character_player.facing = RIGHT;
					new FlxTimer().start(1, function(f):Void{
						character_player.facing = LEFT;

						new FlxTimer().start(1, function(f):Void{
							OverworldState.eventManager.finishTransaction("lookaround");
						});
					});
				});
			});
		});
	});

	// "laurin mustve gone upstairs"
	OverworldState.eventManager.addEvent(function()
	{	
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/hallway/dialogue_lauringone"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});

	// "i need to go to the basement"
	OverworldState.eventManager.addEvent(function()
	{	
		OverworldState.eventManager.startTransaction("dia");

		character_player.facing = RIGHT;

		new FlxTimer().start(1, function(f):Void{
			startDialogue(["factory/hallway/dialogue_basement"], function():Void
			{
				OverworldState.eventManager.finishTransaction("dia");
			});
		});
	});

	// end
	OverworldState.eventManager.addEvent(function()
	{	
		set_inCutscene(false);
		character_player.lockMovement = false;
		character_player.facing = DOWN;

		doorCutsceneActive = false;
	});
}