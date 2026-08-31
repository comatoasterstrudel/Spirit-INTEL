function CTSCRIPT_SETNAME():String
{
	return "factory_production";
}

var lightingCover:LightingSprite;

var dialogueBox:CtDialogueBox;

var character_player:Player;
var character_laurin:Character;
var character_managerscary:Character;

var coworkerA:Character;
var coworkerB:Character;
var coworkerC:Character;
var coworkerD:Character;

var conveyorsHorizontal:Array<ScrollingProp> = [];
var conveyorsVertical:Array<ScrollingProp> = [];

var conveyorLights:Array<Prop> = [];

var tile_main_front:FlxTypedGroup<FlxTilemap>;

var spr_inFrontTiles:FlxSpriteGroup;
var queuedTimeChange:Float = 0;
var snowGroup:FlxSpriteGroup;
var spr_behindTiles:FlxSpriteGroup;
var overMap:FlxSpriteGroup;
var cutsceneSnowOverlay:CtSprite;

var sleepyLevel:String = "awake";
var productionObjects:FlxSpriteGroup;

//
// MONSTER
//
var monsterCutsceneEnabled:Bool = false;
var topDoor:Door;
var snowDialogue:Interactable;
var evilMonsterYPos:Int = 1500;
var seenEvilMonster:Bool = false;

var spr_behindProps:FlxSpriteGroup;
var bloodStains:FlxSpriteGroup;
var bloodStainChance:Float = 110;
var bloodStainPositions:Array<Array<Int>> = [];

function create():Void
{
	lightingCover = get_lightingCover();

	configSnow();

	removeProductionCutsceneTrigger();

	dialogueBox = get_dialogueBox();
	character_player = get_player();
	character_laurin = getCharacterByTag("laurin");
	character_managerscary = getCharacterByTag("managerscary");

	coworkerA = getCharacterByTag("coworkerA");
	coworkerB = getCharacterByTag("coworkerB");
	coworkerC = getCharacterByTag("coworkerC");
	coworkerD = getCharacterByTag("coworkerD");

	killCoworkers();

	conveyorsHorizontal = [
		getScrollingPropByTag("conveyorHorizontal1"),
		getScrollingPropByTag("conveyorHorizontal2"),
		getScrollingPropByTag("conveyorHorizontal3")
	];
	conveyorsVertical = [
		getScrollingPropByTag("conveyorVertical1"),
		getScrollingPropByTag("conveyorVertical2")
	];

	conveyorLights = [getPropByTag("conveyorlight1"), getPropByTag("conveyorlight2")];
	
	tile_main_front = get_tile_main_front();
	tile_main_front.visible = false;

	spr_behindProps = get_spr_behindProps();
	
	topDoor = getDoorByTag("topDoor");
	snowDialogue = getInteractableByTag("snowdialogue");
	removeSnowDialogue();
	
	initProduction();
	
	if (Save.storyFlags.get("factory_sawproductioncutscene").val_bool == false)
	{
		stopConveyors();
	}
	else
	{
		startConveyors();
		character_laurin.kill();
	}

	disableProduction();

	dialogueBox.onChoicerSelected.add(function(tag:String):Void
	{
		if (tag == "Yes")
		{
			set_inCutscene(true);
			set_inCutsceneBeforeDialogue(true);
			doProductionCutscene();
		}
		else if (tag == "No")
		{
			set_inCutscene(true);
			set_inCutsceneBeforeDialogue(true);

			doWalkDown();
		}
	});
	set_encountersDisabled(true);
	if (Save.storyFlags.get("factory_sawproductioncutscene").val_bool
		&& Save.storyFlags.get("factory_startedmonstercutscene").val_bool
		&& !Save.storyFlags.get("factory_monsterscene1").val_bool)
	{
		startMonsterCutscene();
	}
	else if (Save.storyFlags.get("factory_sawproductioncutscene").val_bool && Save.storyFlags.get("factory_scarymode").val_bool)
	{
		setScaryMode();
	}
	if (!monsterCutsceneEnabled)
	{
		character_managerscary.kill();
	}

	if(InitState.init_forceCutscene == "production"){
		doProductionCutscene();
	}
}

function update(elapsed:Float):Void
{
	handleProduction();
	if (monsterCutsceneEnabled)
	{
		if (character_player.hitbox.y >= evilMonsterYPos && !seenEvilMonster)
		{
			startEvilMonsterBit();
		}
	}
}

function doProductionCutscene():Void
{
	lightingCover.alpha = 0;

	set_inCutscene(true);

	Save.storyFlags.get("factory_sawproductioncutscene").val_bool = true;
	removeProductionCutsceneTrigger();

	character_player.lockMovement = true;

	set_lockCamera(true);

	var fadeout:CtSprite;

	// fade out
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("fadeOut");

		fadeout = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFF000000);
		fadeout.alpha = 0;
		fadeout.camera = camOverlay;
		add(fadeout);

		FlxTween.tween(fadeout, {alpha: 1}, 2, {
			onComplete: function(f):Void
			{
				OverworldState.eventManager.finishTransaction("fadeOut");
			}
		});
	});

	// dimmaialogue
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialog");

		startDialogue(["factory/production/dialogue_clotheson"], function():Void
		{
			character_player.initCharacterAnimations("robinwork");

			OverworldState.eventManager.finishTransaction("dialog");
		});
	});
	
	// change scene and fade in
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("fadeIn");
		OverworldState.eventManager.startTransaction("robinMovement");

		camGame.scroll.set(20, 1000);

		character_player.positionCharacterByGrid(17.5, 35);

		character_player.movementSpeed = .5;
		character_player.moveToGridSpace(-1, 27, function():Void
		{
			character_player.movementSpeed = 1;
			OverworldState.eventManager.finishTransaction("robinMovement");
		});

		FlxTween.tween(fadeout, {alpha: 0}, 2, {
			onComplete: function(f):Void
			{
				OverworldState.eventManager.finishTransaction("fadeIn");
			}
		});
	});

	// turn on conveyors
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("turnOnConveyors");

		new FlxTimer().start(.5, function(f):Void
		{
			startConveyors();
			new FlxTimer().start(1.5, function(f):Void
			{
				OverworldState.eventManager.finishTransaction("turnOnConveyors");
			});
		});
	});
	
	// change scene to robin walking to conveyor
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("walkToConveyor");

		doSceneFade(2);

		camGame.scroll.set(1000, 1300);

		character_player.positionCharacterByGrid(22, 34);

		character_player.movementSpeed = .6;

		character_player.moveToGridSpace(38.5, -1, function():Void
		{
			FlxTween.tween(camGame.scroll, {y: 1200}, 3);

			character_player.moveToGridSpace(-1, 28.5, function():Void
			{
				character_player.moveToGridSpace(33.5, 31, function():Void
				{
					character_player.movementSpeed = 1;
					OverworldState.eventManager.finishTransaction("walkToConveyor");
				});
			});
		});
	});

	// enable production
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("startProduction");

		tile_main_front.visible = true;
		spr_inFrontTiles.add(getPropByTag("conveyorlight2"));

		character_player.lockAnims = true;
		enableProduction(3);
		new FlxTimer().start(10, function(f):Void
		{
			OverworldState.eventManager.finishTransaction("startProduction");
		});
	});

	// wait, then change scene and move camera
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("cinematic");

		doSceneFade(2);

		coworkerA.revive();
		coworkerA.positionCharacterByGrid(13, 27);
		coworkerA.facing = UP;

		coworkerB.revive();
		coworkerB.positionCharacterByGrid(9, 23);
		coworkerB.facing = RIGHT;

		camGame.scroll.set(0, 1500);

		FlxTween.tween(camGame.scroll, {y: 800}, 9, {
			ease: FlxEase.quadInOut,
			onComplete: function(f):Void
			{
				new FlxTimer().start(1.5, function(f):Void
				{
					queuedTimeChange = 4;
					doSceneFade(2);
					updateSleepyLevel("lil_sleepy");

					camGame.scroll.set(1000, 1200);

					new FlxTimer().start(6.5, function(F):Void
					{
						OverworldState.eventManager.finishTransaction("cinematic");
					});
				});
			}
		});
	});

	// wait, then change scene and move camera
	OverworldState.eventManager.addEvent(function()
	{				
		OverworldState.eventManager.startTransaction("cinematic");

		updateSleepyLevel("mid_sleepy");

		doSceneFade(2);

		camGame.scroll.set(0, 800);

		coworkerA.positionCharacterByGrid(18, 22);
		coworkerA.facing = LEFT;

		coworkerB.positionCharacterByGrid(12, 18);
		coworkerB.facing = RIGHT;

		coworkerC.revive();
		coworkerC.positionCharacterByGrid(22, 24);
		coworkerC.facing = DOWN;

		FlxTween.tween(camGame.scroll, {x: 900}, 9, {
			ease: FlxEase.quadInOut,
			onComplete: function(f):Void
			{
				new FlxTimer().start(1.5, function(f):Void
				{
					queuedTimeChange = 5;
					doSceneFade(2);
					camGame.scroll.set(1000, 1200);

					coworkerA.positionCharacterByGrid(22, 20);
					coworkerA.facing = UP;

					coworkerB.positionCharacterByGrid(28, 29);
					coworkerB.facing = RIGHT;

					coworkerC.positionCharacterByGrid(12, 18);
					coworkerC.facing = RIGHT;

					coworkerD.revive();
					coworkerD.positionCharacterByGrid(33, 20);
					coworkerD.facing = LEFT;

					new FlxTimer().start(8, function(F):Void
					{
						OverworldState.eventManager.finishTransaction("cinematic");
					});
				});
			}
		});
	});

	// wait, then change scene and move camera
	OverworldState.eventManager.addEvent(function()
	{
		executeSingleScriptFunction("snow", "snow_set_frequency", [.5]);

		cutsceneSnowOverlay = new CtSprite(100, 100).createColorBlock(FlxG.width * 2.5, 1000, 0x67FFFFFF);
		spr_behindTiles.add(cutsceneSnowOverlay);

		OverworldState.eventManager.startTransaction("cinematic");

		FlxTween.tween(camGame.scroll, {x: 400, y: 240}, 9, {
			ease: FlxEase.quadInOut,
			onComplete: function(f):Void
			{
				FlxTween.tween(camGame.scroll, {x: 800}, 9, {
					ease: FlxEase.quadInOut,
					onComplete: function(f):Void
					{
						queuedTimeChange = 7;

						new FlxTimer().start(3, function(f):Void
						{
							killCoworkers();
							doSceneFade(2);
							lightingCover.alpha = .5;
							cutsceneSnowOverlay.visible = false;
							executeSingleScriptFunction("snow", "snow_set_frequency", [1.5]);

							new FlxTimer().start(4, function(F):Void
							{
								OverworldState.eventManager.finishTransaction("cinematic");
							});
						});
					}
				});
			}
		});
	});

	// go back to robin who is now eepy
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("cinematic");

		updateSleepyLevel("big_sleepy");

		FlxTween.tween(camGame.scroll, {x: 976, y: 1200}, 5, {
			ease: FlxEase.quadInOut,
			onComplete: function(f):Void
			{
				new FlxTimer().start(2.5, function(F):Void
				{
					OverworldState.eventManager.finishTransaction("cinematic");
				});
			}
		});
	});

	// laurin walks down
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("larin");

		character_laurin.positionCharacterByGrid(38.5, 21);
		character_laurin.movementSpeed = .5;

		disableProduction();

		character_laurin.moveToGridSpace(-1, 28, function():Void
		{
			character_laurin.moveToGridSpace(33.5, 28, function():Void
			{
				character_laurin.moveToGridSpace(-1, 29.5, function():Void
				{
					new FlxTimer().start(1.5, function(f):Void
					{
						OverworldState.eventManager.finishTransaction("larin");
					});
				});
			});
		});
	});

	// laurin dialogue 1
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dailogu");

		startDialogue(["factory/production/dialogue_laurin1"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dailogu");
		});
	});
	
	// nudge!!
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("nudge");

		character_player.lockAnims = false;
		character_player.facing = UP;
		FlxTween.shake(character_player, 0.05, .2, 0x01);

		FlxTween.tween(lightingCover, {alpha: 0}, .5, {
			ease: FlxEase.quartOut,
			onComplete: function(F):Void
			{
				OverworldState.eventManager.finishTransaction("nudge");
			}
		});
	});

	// laurin dialogue 2
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dailogu");

		new FlxTimer().start(1.5, function(F):Void
		{
			startDialogue(["factory/production/dialogue_laurin2"], function():Void
			{
				OverworldState.eventManager.finishTransaction("dailogu");
			});
		});
	});

	// laurin walks away
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("laurinbyebye");

		character_laurin.moveToGridSpace(-1, 28.5, function():Void
		{
			character_laurin.moveToGridSpace(38.5, -1, function():Void
			{
				character_laurin.moveToGridSpace(-1, 22, function():Void
				{
					character_laurin.kill();
					OverworldState.eventManager.finishTransaction("laurinbyebye");
				});
			});
		});
	});

	var fadeout2:CtSprite;

	// fade out
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("fadeOut2");

		fadeout2 = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFF000000);
		fadeout2.alpha = 0;
		fadeout2.camera = camOverlay;
		add(fadeout2);

		FlxTween.tween(fadeout2, {alpha: 1}, 2, {
			onComplete: function(f):Void
			{
				OverworldState.eventManager.finishTransaction("fadeOut2");
			}
		});
	});

	// dimmaialogue
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dialog");

		startDialogue(["factory/production/dialogue_clothesoff"], function():Void
		{
			productionObjects.visible = false;
			character_player.initCharacterAnimations("robin");
			OverworldState.eventManager.finishTransaction("dialog");
		});
	});

	// fade in
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("fadeIn2");

		FlxTween.tween(fadeout2, {alpha: 0}, 2, {
			onComplete: function(f):Void
			{
				fadeout2.destroy();
				OverworldState.eventManager.finishTransaction("fadeIn2");
			}
		});
	});

	// end cutscene
	OverworldState.eventManager.addEvent(function() {
		moveCameraBackToPlayer(1, null, function():Void{
			character_player.facing = DOWN;
			tile_main_front.visible = false;
			character_player.movementSpeed = 1;
			character_player.lockMovement = false;
			set_inCutscene(false);
			set_lockCamera(false);
		});
	});
}

function doWalkDown():Void
{
	character_player.lockMovement = true;

	// Robin walks downwards
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("robinMove");

		character_player.movementSpeed = .35;
		
		character_player.moveToGridSpace(-1, 37, function():Void
		{
			OverworldState.eventManager.finishTransaction("robinMove");
		});
	});

	// end cutscene
	OverworldState.eventManager.addEvent(function()
	{
		character_player.movementSpeed = 1;
		character_player.lockMovement = false;
		set_inCutscene(false);
	});
}

function removeProductionCutsceneTrigger():Void
{
	if (Save.storyFlags.get("factory_sawproductioncutscene").val_bool)
	{
		getInteractableByTag("factorycutscenetrigger").disabled = true;
	}
}

function configSnow():Void
{
	snowGroup = executeSingleScriptFunction("snow", "snow_get_snowGroup", []);    
    spr_behindTiles = get_spr_behindTiles();
    overMap = get_overMap();
    
    overMap.remove(snowGroup);
    spr_behindTiles.add(snowGroup);
    
    snowGroup.alpha = .4;
    
    executeSingleScriptFunction("snow", "snow_set_frequency", [1.5]);    
	executeSingleScriptFunction("snow", "snow_setBoundariesFromGrid", [12, 42, 8, 15]);   
}
var conveyorSpeed:Float = -30;

function startConveyors():Void
{
	for (conveyor in conveyorsHorizontal)
	{
		conveyor.backdrop.velocity.set(conveyorSpeed, 0);
	}
	for (conveyor in conveyorsVertical)
	{
		conveyor.backdrop.velocity.set(0, conveyorSpeed);
	}
	for (light in conveyorLights)
	{
		light.visible = true;
	}
}

function stopConveyors():Void
{
	for (conveyor in conveyorsHorizontal)
	{
		conveyor.backdrop.velocity.set(0, 0);
	}
	for (conveyor in conveyorsVertical)
	{
		conveyor.backdrop.velocity.set(0, 0);
	}
	for (light in conveyorLights)
	{
		light.visible = false;
	}
}
var sceneFadeActive:Bool = false;

function doSceneFade(time:Float, ?onComplete:Void->Void):Void
{
	if (sceneFadeActive)
		return;

	sceneFadeActive = true;

	OverworldState.eventManager.startTransaction("sceneFading!!");

	var spr:CtSprite = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFF7D2D2D);
	spr.pixels.draw(FlxG.game);
	spr.setGraphicSize(FlxG.width, FlxG.height);
	spr.updateHitbox();
	spr.camera = camUI;
	add(spr);

	FlxTween.tween(spr, {alpha: 0}, time, {
		onComplete: function(f):Void
		{
			spr.destroy();
			if (onComplete != null)
				onComplete();

			OverworldState.eventManager.finishTransaction("sceneFading!!");

			sceneFadeActive = false;
		}
	});
}
var doProductionAnims:Bool = false;
var desiredAnim:String = "conveyor_awake_1";
var doBlink:Bool = false;

var prod_start:Int = 0;
var prod_entrancesX:Array<Int> = [34, 30, 28, 16, 11];
var prod_entrancesY:Array<Int> = [33, 33, 26, 26, 26];
var prod_endX:Array<Int> = [30, 30, 20, 11, 11];
var prod_endY:Array<Int> = [33, 27, 26, 26, 17];
var prod_horiz:Array<Bool> = [true, false, true, true, false];
var prod_redirect:Array<Int> = [1, 2, 3, 4, -1];
var productionTimer:FlxTimer;

function initProduction():Void
{
	spr_inFrontTiles = get_spr_infrontTiles();

	productionObjects = new FlxSpriteGroup();
	spr_inFrontTiles.add(productionObjects);
}

function handleProduction():Void
{
	var redirThese:Array<FlxSprite> = [];

	for (obj in productionObjects.members)
	{
		if (obj.x <= ((prod_endX[obj.ID] * Constants.overworldPixelScale) * 16)
			&& obj.y <= ((prod_endY[obj.ID] * Constants.overworldPixelScale) * 16))
		{
			redirThese.push(obj);
		}
	}

	for (spr in redirThese)
	{
		if (prod_redirect[spr.ID] != -1)
		{
			addProductionObject(prod_redirect[spr.ID], spr);
		}
		productionObjects.remove(spr, true);
		spr.destroy();
	}

	redirThese = [];
	if (doProductionAnims)
	{
		var acceptableBlinkAnims:Array<String> = ["conveyor_mid_sleepy_1", "conveyor_mid_sleepy_2", "conveyor_mid_sleepy_3"];

		if (doBlink && sleepyLevel == "mid_sleepy" && acceptableBlinkAnims.contains(desiredAnim))
		{
			character_player.animation.play(desiredAnim + "_blink");
		}
		else
		{
			character_player.animation.play(desiredAnim);
		}
	}
}

var timeBetween:Float = 1;
var playerY:Int = 0;
var playerTween:FlxTween;

function enableProduction(time:Float):Void
{
	doProductionAnims = true;
	
	timeBetween = time;

	playerY = character_player.hitbox.y;

	productionTimer = new FlxTimer().start(timeBetween, function(f):Void
	{
		addProductionObject(prod_start, null);

		if (queuedTimeChange != 0)
		{
			timeBetween = queuedTimeChange;
			queuedTimeChange = 0;
		}

		productionTimer.reset(timeBetween * FlxG.random.float(0.7, 1.3));
	});

	var ogTimer = new FlxTimer();

	ogTimer.start(FlxG.random.float(1, 2), function(f):Void
	{
		doBlink = true;
		
		new FlxTimer().start(FlxG.random.float(.4, 1), function(f):Void
		{
			doBlink = false;
			ogTimer.reset(FlxG.random.float(1, 2));
		});
	});
}

function disableProduction():Void
{
	doProductionAnims = false;
	
	if (productionTimer != null)
	{
		productionTimer.cancel();
	}
}

var robinanimstatus:Bool = false;

function addProductionObject(id:Int, ?sprite:FlxSprite):Void
{
	var obj = new CtSprite().createFromImage(Constants.overworldMiscGraphicPath + "factorydetergent" + FlxG.random.int(1, 3) + ".png");
	if (sprite != null)
		obj.loadGraphicFromSprite(sprite);
	obj.scale.set(Constants.overworldPixelScale, Constants.overworldPixelScale);
	obj.updateHitbox();
	obj.ID = id;
	obj.antialiasing = false;
	productionObjects.add(obj);

	var disableAnimsAfter:Bool = false;
	
	obj.setPosition((prod_entrancesX[obj.ID] * Constants.overworldPixelScale) * 16, (prod_entrancesY[obj.ID] * Constants.overworldPixelScale) * 16);
	if (id == prod_start)
	{
		var ogY = obj.y;

		obj.y = character_player.y + obj.height;

		if (!doProductionAnims)
		{
			doProductionAnims = true;
			disableAnimsAfter = true;
		}
			
		desiredAnim = "conveyor_" + sleepyLevel + "_2";

		robinanimstatus = true;

		new FlxTimer().start(1, function(F):Void
		{
			if (prod_horiz[obj.ID])
			{
				obj.velocity.set(conveyorSpeed, 0);
			}
			else
			{
				obj.velocity.set(0, conveyorSpeed);
			}

			obj.y = ogY;

			if (!doProductionAnims)
			{
				doProductionAnims = true;
				disableAnimsAfter = true;
			}
				
			desiredAnim = "conveyor_" + sleepyLevel + "_3";

			if (playerTween != null)
			{
				playerTween.cancel();
				playerTween.destroy();
			}

			character_player.hitbox.y = playerY + 8;
			playerTween = FlxTween.tween(character_player.hitbox, {y: playerY}, .5);

			new FlxTimer().start(.5, function(F):Void
			{
				if (!doProductionAnims)
				{
					doProductionAnims = true;
					disableAnimsAfter = true;
				}
				
				robinanimstatus = false;
				desiredAnim = "conveyor_" + sleepyLevel + "_1";
				if (disableAnimsAfter)
				{
					new FlxTimer().start(0.1, function(f):Void
					{
						doProductionAnims = false;
					});
				}
			});
		});
	}
	else
	{
		if (prod_horiz[obj.ID])
		{
			obj.velocity.set(conveyorSpeed, 0);
		}
		else
		{
			obj.velocity.set(0, conveyorSpeed);
		}
	}
}

function updateSleepyLevel(name:String):Void
{
	sleepyLevel = name;
	if (!robinanimstatus)
	{
		desiredAnim = ("conveyor_" + sleepyLevel + "_1");
	}
}
//
// MONSTER CUTSCENE
//

function startMonsterCutscene():Void
{
	monsterCutsceneEnabled = true;
	
	snowDialogue.disabled = false;

	topDoor.room = "";
	topDoor.dialogue = "factory/production/monster/dialogue_doornogo";

	lightingCover.alpha = .5;
	character_player.movementSpeed = .6;

	character_player.changeAnimationPrefix("party_");
	
	set_inCutscene(true);

	new FlxTimer().start(OverworldState.lastTransitionTime + 1, function(f):Void
	{
		startDialogue(["factory/production/monster/dialogue_lightsoff"], function():Void
		{
			set_inCutscene(false);
		});
	});
}

function startEvilMonsterBit():Void
{
	seenEvilMonster = true;

	set_inCutscene(true);

	character_player.lockMovement = true;

	// move down more rq
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("move");

		character_player.move(-1, 1650, function():Void
		{
			OverworldState.eventManager.finishTransaction("move");
		});
	});

	// play sound, turn and wait
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("snd");

		// play sound here

		new FlxTimer().start(2, function(f):Void
		{
			character_player.facing = LEFT;

			new FlxTimer().start(1, function(f):Void
			{
				OverworldState.eventManager.finishTransaction("snd");
			});
		});
	});

	// dimmalogue
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/production/monster/dialogue_evilscarybit_1"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});

	// sound 2
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("sbd2");

		// play sound 2 here

		new FlxTimer().start(3, function(f):Void
		{
			OverworldState.eventManager.finishTransaction("sbd2");
		});
	});

	// dimmalog
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/production/monster/dialogue_evilscarybit_2"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});
	// manager scooch
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("mamamove");

		moveManagerChain(3, 1, 2, "right", function():Void
		{
			new FlxTimer().start(1, function(f):Void
			{
				moveManagerChain(2, 1, 2, "down", function():Void
				{
					new FlxTimer().start(1, function(f):Void
					{
						character_player.lockAnims = true;
						character_player.animation.play("shocked_idle");

						FlxTween.shake(character_player, 0.05, .2, 0x01);

						new FlxTimer().start(0.5, function(F):Void
						{
							character_player.movementSpeed = .3;
							character_player.animation.play("shocked_stepback");
							character_player.move(character_player.x + 20, -1, function():Void
							{
								OverworldState.eventManager.finishTransaction("stepright");
								character_player.animation.play("shocked_idle");
								character_player.facing = LEFT;
							});
						});

						moveManagerChain(3, 0, 2, "right", function():Void
						{
							new FlxTimer().start(1, function(f):Void
							{
								OverworldState.eventManager.finishTransaction("mamamove");
							});
						});
					});
				});
			});
		});
	});

	// dimmalog
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		startDialogue(["factory/production/monster/dialogue_evilscarybit_3"], function():Void
		{
			OverworldState.eventManager.finishTransaction("dia");
		});
	});

	// robin step right
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("stepright");

		FlxTween.shake(character_player, 0.05, .2, 0x01);

		new FlxTimer().start(0.5, function(F):Void
		{
			character_player.movementSpeed = .3;
			character_player.animation.play("shocked_stepback");
			character_player.move(character_player.x + 20, -1, function():Void
			{
				OverworldState.eventManager.finishTransaction("stepright");
				character_player.animation.play("shocked_idle");
				character_player.facing = LEFT;
			});
		});
	});

	// dimmalog
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("dia");

		new FlxTimer().start(1, function(f):Void
		{
			startDialogue(["factory/production/monster/dialogue_evilscarybit_4"], function():Void
			{
				OverworldState.eventManager.finishTransaction("dia");
			});
		});
	});
	// monster stand up
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("standup");

		character_managerscary.animation.onFrameChange.add(function(name:String, frameNum:Int, frameIndex:Int):Void
		{
			if (name == "standup")
			{
				FlxTween.shake(character_managerscary, 0.05, .2, 0x01);

				if (frameNum == 2)
				{
					character_managerscary.changeAnimationPrefix("stand-");
					character_managerscary.lockAnims = false;
					new FlxTimer().start(1.5, function(f):Void
					{
						OverworldState.eventManager.finishTransaction("standup");
					});
				}
			}
		});

		character_managerscary.lockAnims = true;
		character_managerscary.animation.play("standup");
	});
	// robin center
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("robin center");

		set_lockCamera(true);

		character_player.animation.play("shocked_stepback");

		character_player.movementSpeed = .3;
		character_player.moveToGridSpace(38.5, -1, function():Void
		{
			character_player.animation.play("shocked_idle");
			character_player.movementSpeed = 1.5;
			OverworldState.eventManager.finishTransaction("robin center");
		});
	});

	// rUN AWAY
	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("run away!!!!");

		set_lockCamera(true);

		character_player.animation.play("walk_up_fast");

		character_player.moveToGridSpace(-1, 17);

		FlxTween.shake(character_managerscary, 0.05, .2, 0x01);

		new FlxTimer().start(0.3, function(f):Void
		{
			character_managerscary.movementSpeed = 1.6;
			character_managerscary.moveToGridSpace(38, 19, function():Void
			{
				OverworldState.eventManager.finishTransaction("run away!!!!");
			});
		});
	});

	// fade out
	OverworldState.eventManager.addEvent(function()
	{
		Save.storyFlags.get("factory_monsterscene1").val_bool = true;
		moveRoom("factory_hallway", .5);
	});
}

function moveManagerChain(repeats:Int, timeBetween:Float, tiles:Int, direction:String, ?onComplete:Void->Void):Void
{
	for (i in 0...repeats)
	{
		new FlxTimer().start((2 * i) + (timeBetween * i), function(f):Void
		{
			moveManager(tiles, direction, function():Void
			{
				if (i == (repeats - 1))
				{
					if (onComplete != null)
						onComplete();
				}
			});
		});
	}
}

function moveManager(tiles:Int, direction:String, ?onComplete:Void->Void):Void
{
	character_managerscary.lockAnims = true;

	var distance = tiles * 16 * Constants.overworldPixelScale;

	var x:Float = character_managerscary.hitbox.x;
	var y:Float = character_managerscary.hitbox.y;

	switch (direction)
	{
		case "left":
			character_managerscary.facing = LEFT;
			character_managerscary.animation.play("walk_left");
			x -= distance;
		case "right":
			character_managerscary.facing = RIGHT;
			character_managerscary.animation.play("walk_right");
			x += distance;
		case "up":
			character_managerscary.facing = UP;
			character_managerscary.animation.play("walk_up");
			y -= distance;
		case "down":
			character_managerscary.facing = DOWN;
			character_managerscary.animation.play("walk_down");
			y += distance;
	}

	FlxTween.tween(character_managerscary.hitbox, {x: x, y: y}, 2, {
		ease: FlxEase.quartInOut,
		onUpdate: function(f):Void
		{
			if (FlxG.random.bool(bloodStainChance * FlxG.elapsed))
			{
				spawnBloodStain(Std.int(((character_managerscary.x + character_managerscary.width / 2) / 16) / Constants.overworldPixelScale),
					Std.int(((character_managerscary.y + character_managerscary.height / 2) / 16) / Constants.overworldPixelScale));
			}
		},
		onComplete: function(f):Void
		{
			character_managerscary.lockAnims = false;

			if (onComplete != null)
				onComplete();
		}
	});
}

function spawnBloodStain(xGrid:Int, yGrid:Int):Void
{
	for (i in bloodStainPositions)
	{
		if (i[0] == xGrid && i[1] == yGrid)
		{ // theres a blood stain here already
			return;
		}
	}

	bloodStainPositions.push([xGrid, yGrid]);

	var bloodStain = new CtSprite(xGrid * 16 * Constants.overworldPixelScale,
		yGrid * 16 * Constants.overworldPixelScale).createFromImage(Constants.overworldMiscGraphicPath + "bloodstain" + FlxG.random.int(1, 3) + ".png");
	bloodStain.scale.set(Constants.overworldPixelScale, Constants.overworldPixelScale);
	bloodStain.alpha = 0;
	bloodStain.updateHitbox();
	bloodStain.antialiasing = false;
	spr_behindProps.add(bloodStain);

	for (i in 0...3)
	{
		new FlxTimer().start(FlxG.random.float(.1, .7) * i, function(F):Void
		{
			bloodStain.alpha += FlxG.random.float(.2, .4);
		});
	}
}

function doSnowScene():Void
{
	removeSnowDialogue();

	set_inCutscene(true);

	set_lockCamera(true);

	var ogY = camGame.scroll.y;

	character_player.facing = UP;

	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("cameraUp");

		FlxTween.tween(camGame.scroll, {y: ogY - 150}, 1.5, {
			onComplete: function(f):Void
			{
				new FlxTimer().start(1, function(f):Void
				{
					OverworldState.eventManager.finishTransaction("cameraUp");
				});
			}
		});
	});

	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("d");

		startDialogue(["factory/production/monster/dialogue_snow"], function():Void
		{
			OverworldState.eventManager.finishTransaction("d");
		});
	});

	OverworldState.eventManager.addEvent(function()
	{
		OverworldState.eventManager.startTransaction("cameraUp");

		moveCameraBackToPlayer(1.5, null, function():Void{
			OverworldState.eventManager.finishTransaction("cameraUp");
		});		
	});

	OverworldState.eventManager.addEvent(function()
	{
		set_inCutscene(false);
		set_lockCamera(false);
		character_player.facing = DOWN;
	});
}

function removeSnowDialogue():Void
{
	snowDialogue.disabled = true;
}

// END MONSTER STUFF

function setScaryMode():Void
{
	lightingCover.alpha = .5;
	set_encountersDisabled(false);
}

function killCoworkers():Void{
	coworkerA.kill();
	coworkerB.kill();
	coworkerC.kill();
	coworkerD.kill();
}