package overworld;

class OverworldState extends FlxState
{
	public static var eventManager:CtEventManager;

	public static var roomName:String = "test";
	public static var roomData:RoomData;
    
	public static var previousRoom:String = "";
	
	public static var savePointName:String = "";
	
	public static var startAtSavePoint:Bool = false;
	
	// CAMERAS
	var camGame:FlxCamera;
	var camLighting:FlxCamera;
	var camOverlay:FlxCamera;
	var camUI:FlxCamera;
	// CAMERA STUFF
	var cameraScrollX:Bool = false;
	var cameraScrollY:Bool = false;
	var cameraFollowingTilemap:FlxTilemap;
	var lockCamera:Bool = false;
	var unbindCamera:Bool = false;
	var cameraBoundsMin:FlxPoint = new FlxPoint();
	var cameraBoundsMax:FlxPoint = new FlxPoint();
	
	// CHARACTERS
    var player:Player;
	// PROPS
	var props:FlxTypedSpriteGroup<FlxSprite>;

	// CUTSCENE
	public static var inCutscene:Bool = false;

	// DIALOGUe
	var inCutsceneBeforeDialogue:Bool = false;
	var dialogueBox:CtDialogueBox;
	var onDialogueComplete:Void->Void;

	// MAP AND TILES
	var map:BetterFlxOgmo3Loader;
	var tileSets:Map<String, FlxTilemap> = [];
	var tile_background:FlxTypedGroup<FlxTilemap>;
	var tile_main_back:FlxTypedGroup<FlxTilemap>;
	var spr_behindTiles:FlxSpriteGroup;
	var tile_main:FlxTypedGroup<FlxTilemap>;
	var spr_behindProps:FlxSpriteGroup;
	var spr_infrontTiles:FlxSpriteGroup;
	var tile_main_front:FlxTypedGroup<FlxTilemap>;
	var tile_foreground:FlxTypedGroup<FlxTilemap>;
	var spr_top:FlxSpriteGroup;

	var underMap:FlxSpriteGroup;
	var overMap:FlxSpriteGroup;

	// MAP SIZE
	var mapSizeStart:FlxPoint = FlxPoint.get();
	var mapSizeEnd:FlxPoint = FlxPoint.get();
	var mapWidth:Float = 0;
	var mapHeight:Float = 0;

	// INTERACTABLES
	var walkInteractables:FlxTypedGroup<Interactable>;
	var interactInteractables:FlxTypedGroup<Interactable>;
	
	// TRANSITION
	public static var lastTransitionTime:Float = 0;
	public static var battleTransition:MosaicEffect;
	
	// FACING
	public static var lastFacing:FlxDirectionFlags = DOWN;
	
	// EXIT
	var exitProgress:Float = 0;
	
	// BATTLE
	public static var leftForBattle:Bool = false;
	public static var positionBeforeBattle:FlxPoint = new FlxPoint();
	
	// RANDOM ENCOUNTEr
	var selectedRandomEncounter:String = "";
	var encounterCooldown:Float = 0;
	var encountersDisabled:Bool = false;

	// SCRIPTS
	var scripts:Array<CtScript> = [];
	
	// LIGHTING
	var lightingCover:LightingSprite;
	var lightingShader:LightingEffectShader;
	
    override function create():Void{
        super.create();
        
		eventManager = new CtEventManager();
		eventManager.reset();
		
		inCutscene = false;

		loadRoom();        
		bgColor = roomData.bgColor;

		setupCameras();

		setupDialogueBox();
		loadMap();
		selectRandomEncounter();
		if (leftForBattle)
		{
			player.positionCharacter(positionBeforeBattle.x, positionBeforeBattle.y);
			leftForBattle = false;
			doBattleTransition(OUT, function():Void
			{
				executeScriptFunction("battleTransitionDone", [PlayState.battleName]);
			});
		}
		else
		{
			doRoomTransition(lastTransitionTime, IN);
		}
		#if debug
		addDebugFunctions();
		#end
	}
    
    override function update(elapsed:Float):Void{
		super.update(elapsed);

		handleCollision();
		handleSorting();
		handleCameraScroll();
		updateCamLighting();
		handleExit(elapsed);
		handleRandomEncounters(elapsed);
		if (battleTransition != null)
		{
			battleTransition.update();
		}
		handlePlayerMenu();
		executeScriptFunction("update", [elapsed]);
		eventManager.update();
		#if debug
		updateDebugFunctions();
		#end
	}

	/**
	 * call this to add the flxcameras that the game uses hehehe
	 */
	function setupCameras():Void
	{
		camGame = new FlxCamera();
		camGame.bgColor.alpha = 0;
		FlxG.cameras.add(camGame, true);

		lightingShader = new LightingEffectShader(roomData.lightingDarkColor, roomData.lightingGlowColor);
		
		camLighting = new FlxCamera();
		camLighting.bgColor.alpha = 0;
		camLighting.filters = [
		(new ShaderFilter(lightingShader))
		];
		FlxG.cameras.add(camLighting, false);
		
		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;
		FlxG.cameras.add(camOverlay, false);
		
		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);
	}
	
	/**
	 * Call this to handle the collisions of the characters
	 */
	function handleCollision():Void
	{
		FlxG.worldBounds.set(camGame.scroll.x, camGame.scroll.y, FlxG.width, FlxG.height); // FUCK EVERYTHING 2

		if (roomData.hasBorders)
		{
			var moved:Bool = false;

			if (player.hitbox.x < 0)
			{
				player.hitbox.x = 0;
				moved = true;
			}
			else if (player.hitbox.x + player.hitbox.width >= mapWidth)
			{
				player.hitbox.x = mapWidth - player.hitbox.width;
				moved = true;
			}

			if (player.hitbox.y < 0)
			{
				player.hitbox.y = 0;
				moved = true;
			}
			else if (player.hitbox.y + player.hitbox.height >= mapHeight)
			{
				player.hitbox.y = mapHeight - player.hitbox.height;
				moved = true;
			}

			if (moved)
				player.centerSpriteOnHitbox();	
		}
		
		for (tile in tileSets)
		{
			FlxG.collide(tile, player.hitbox);
		}
		for (prop in props.members)
		{
			if (prop is Character)
			{
				var character:Character = cast prop;
				
				if (character != player && !character.noclip)
				{
					FlxG.collide(character.hitbox, player.hitbox);
				}
			}
			if (prop is Prop)
			{
				var trueProp:Prop = cast prop;

				FlxG.collide(player.hitbox, trueProp.hitbox);
			}
		}

		if (!inCutscene)
		{
			for (interactable in walkInteractables.members)
			{
				if (FlxG.overlap(interactable, player.hitbox))
				{
					if (triggerInteractable(interactable) == TRIGGERED)
					{
						break;
					};
				}
			}
		}
	}

	/**
	 * Call this to handle the sorting of certain game sprites
	 */
	function handleSorting():Void
	{
		for (prop in props)
		{
			if (prop is Prop)
			{
				var trueProp:Prop = cast prop;
				trueProp.y += (trueProp.data.yStackingOffset * Constants.overworldPixelScale);
			}
		}
		
		props.sort(FlxSort.byY, FlxSort.ASCENDING);
		for (prop in props)
		{
			if (prop is Prop)
			{
				var trueProp:Prop = cast prop;
				trueProp.y -= (trueProp.data.yStackingOffset * Constants.overworldPixelScale);
			}
		}
	}

	function handleCameraScroll():Void
	{
		if (cameraFollowingTilemap == null)
			return; // what!

		if (unbindCamera)
		{
			camGame.setScrollBounds(null, null, null, null);
		}
		else
		{
			camGame.setScrollBounds(cameraBoundsMin.x == -999 ? null : cameraBoundsMin.x, cameraBoundsMax.x == -999 ? null : cameraBoundsMax.x,
				cameraBoundsMin.y == -999 ? null : cameraBoundsMin.y, cameraBoundsMax.y == -999 ? null : cameraBoundsMax.y);
		}

		if (lockCamera || unbindCamera)
			return; // what!

		if (player != null)
		{
			camGame.focusOn(new FlxPoint(player.hitbox.x + player.hitbox.width / 2, player.hitbox.y + player.hitbox.height / 2));
		}

		if (!cameraScrollX)
		{
			camGame.scroll.x = (mapSizeStart.x + mapWidth / 2) - (FlxG.width / 2);
		}

		if (!cameraScrollY)
		{
			camGame.scroll.y = (mapSizeStart.y + mapHeight / 2) - (FlxG.height / 2);
		}
	}
	
	function updateCamLighting():Void
	{
		camLighting.scroll.set(camGame.scroll.x, camGame.scroll.y);
		camLighting.zoom = camGame.zoom;
		camLighting.setScrollBounds(camGame.minScrollX, camGame.maxScrollX, camGame.minScrollY, camGame.maxScrollY);
	}
	
	function handleExit(elapsed:Float):Void
	{
		if (CtControls.checkInput("exit", PRESSED))
		{
			exitProgress += elapsed;

			if (exitProgress >= Constants.exitTime)
			{
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				FlxG.switchState(LevelSelectorState.new);
			}
		}
		else
		{
			exitProgress = 0;
		}
	}
	
	function handleRandomEncounters(elapsed:Float):Void
	{
		if (selectedRandomEncounter == "" || encountersDisabled)
			return;

		if (!inCutscene && player.moving)
		{
			if (encounterCooldown >= Constants.encounterCooldown)
			{
				if (FlxG.random.bool(roomData.encounterChance * elapsed))
				{
					startBattle(selectedRandomEncounter);
				}
			}
			else
			{
				encounterCooldown += elapsed;
			}
		}
	}

	function selectRandomEncounter():Void
	{
		if (roomData.encounters.length == 0 || roomData.encounterChance <= 0)
			return;

		var total:Float = 0;
		var encounterData:Array<Array<Dynamic>> = []; // battle name, low, high

		for (encounter in roomData.encounters)
		{
			encounterData.push([encounter.battleName, total, total + encounter.rarity]);
			total += encounter.rarity;
		}

		var randomNum = FlxG.random.float(0, total);

		for (encounter in encounterData)
		{
			if (randomNum >= encounter[1] && randomNum < encounter[2])
			{
				selectedRandomEncounter = encounter[0];
			}
		}
	}
	
	function handlePlayerMenu():Void
	{
		if (!inCutscene && CtControls.checkInput("cancel", JUSTPRESSED))
		{
			openSubState(new PlayerMenu());
		}
	}
	
	/**
	 * Call this to setup the dialogue box for use in cutscenes
	 */
	function setupDialogueBox():Void
	{
		dialogueBox = new CtDialogueBox();
		dialogueBox.camera = camUI;
		dialogueBox.antialiasing = false;
		add(dialogueBox);
		dialogueBox.onComplete.add(endDialogues);		
	}

	/**
	 * Call this to initialize the roomdata variable
	 */
	function loadRoom():Void
	{
		roomData = new RoomData(roomName);
	}

	/**
	 * Call this to load and add the tiles from the tilemap data!!
	 */
	function loadMap():Void
	{
		underMap = new FlxSpriteGroup();
		underMap.camera = camGame;
		add(underMap);
		
		tile_background = new FlxTypedGroup<FlxTilemap>();
		tile_background.camera = camGame;
		add(tile_background);

		tile_main_back = new FlxTypedGroup<FlxTilemap>();
		tile_main_back.camera = camGame;
		add(tile_main_back);

		spr_behindTiles = new FlxSpriteGroup();
		spr_behindTiles.camera = camGame;
		add(spr_behindTiles);
		
		tile_main = new FlxTypedGroup<FlxTilemap>();
		tile_main.camera = camGame;
		add(tile_main);

		spr_infrontTiles = new FlxSpriteGroup();
		spr_infrontTiles.camera = camGame;

		tile_main_front = new FlxTypedGroup<FlxTilemap>();
		tile_main_front.camera = camGame;
		
		tile_foreground = new FlxTypedGroup<FlxTilemap>();
		tile_foreground.camera = camGame;

		map = new BetterFlxOgmo3Loader(Constants.ogmoFilePath, Constants.tilemapsDataPath + roomData.map + ".json");
		lightingCover = new LightingSprite(map, roomData);
		lightingCover.camera = camLighting;

		var data2D:Array<Array<Int>> = [];

		var realSizeMin = FlxPoint.get();
		var realSizeMax = FlxPoint.get();

		realSizeMin.set(9999999, 9999999);
		
		for (layer in map.getLevelData().layers)
		{
			if (layer.tileset != null)
			{
				if (layer.name == "main")
				{
					var collumn:Int = 0;

					for (i in 0...layer.data.length)
					{
						if (i % layer.gridCellsX == 0 && i != 0)
						{
							collumn++;
						}

						if (data2D[collumn] == null)
							data2D[collumn] = [];

						var tile = layer.data[i];
						data2D[collumn].push(tile);
					}

					for (i in 0...data2D.length)
					{
						var row = data2D[i];

						for (j in 0...row.length)
						{
							var tile = row[j];

							if (tile != -1)
							{ // theres a real tile here
								if (realSizeMin.x > j)
								{
									realSizeMin.x = j;
								}
								if (realSizeMax.x < j)
								{
									realSizeMax.x = j;
								}
								if (realSizeMin.y > i)
								{
									realSizeMin.y = i;
								}
								if (realSizeMax.y < i)
								{
									realSizeMax.y = i;
								}
							}
						}
					}

					realSizeMin.set((((realSizeMin.x) * Constants.overworldPixelScale) * 16), ((realSizeMin.y * Constants.overworldPixelScale) * 16));
					realSizeMax.set((((realSizeMax.x + 1) * Constants.overworldPixelScale) * 16), (((realSizeMax.y + 1) * Constants.overworldPixelScale) * 16));
				}
					
				
				var tilesetData = new TilesetData(layer.tileset);
				var tiles = map.loadTilemap(Constants.tilesetGraphicPath + tilesetData.graphic + ".png", layer.name);
				tiles.scale.set(Constants.overworldPixelScale, Constants.overworldPixelScale);
				tiles.antialiasing = false;
				for (i in 0...tilesetData.collisions.length)
				{
					var val = tilesetData.collisions[i];
					tiles.setTileProperties(i, switch (val)
					{
						case "NONE": NONE;
						case "ANY": ANY;
						default: NONE;
					});
				}
				if (layer.name == "main")
				{
					mapSizeStart.set(realSizeMin.x, realSizeMin.y);
					mapSizeEnd.set(realSizeMax.x, realSizeMax.y);

					mapWidth = mapSizeEnd.x - mapSizeStart.x;
					mapHeight = mapSizeEnd.y - mapSizeStart.y;

					cameraScrollX = mapWidth >= FlxG.width;
					cameraScrollY = mapHeight >= FlxG.height;
					cameraFollowingTilemap = tiles;
					camGame.setScrollBounds(mapSizeStart.x, mapSizeEnd.x, mapSizeStart.y, mapSizeEnd.y);
				}
				if (layer.name == "background")
				{
					tiles.scrollFactor.set(.8, .8);
					tile_background.add(tiles);
				}
				else if (layer.name == "foreground")
				{
					tiles.scrollFactor.set(1.2, 1.2);
					tile_foreground.add(tiles);
				}
				else if (layer.name == "main_back")
				{
					tile_main_back.add(tiles);
				}
				else if (layer.name == "main_front")
				{
					tile_main_front.add(tiles);
				}
				else
				{
					tile_main.add(tiles);
					tileSets.set(layer.tileset, tiles);
				}
			}
		}

		if (cameraFollowingTilemap != null)
		{
			if (!cameraScrollX)
			{
				camGame.minScrollX = null;
				camGame.maxScrollX = null;
			}
			if (!cameraScrollY)
			{
				camGame.minScrollY = null;
				camGame.maxScrollY = null;
			}
			cameraBoundsMin.set(camGame.minScrollX ?? -999, camGame.minScrollY ?? -999);
			cameraBoundsMax.set(camGame.maxScrollX ?? -999, camGame.maxScrollY ?? -999);
			
			handleCameraScroll();
		}
		
		spr_behindProps = new FlxSpriteGroup();
		spr_behindProps.camera = camGame;
		add(spr_behindProps);
		
		props = new FlxTypedSpriteGroup<FlxSprite>();
		props.camera = camGame;
		add(props);
		
		player = new Player(roomData.playerName);
		player.camera = camGame;
		player.facing = lastFacing;
		props.add(player);
		
		var playerPlacePoints:Array<PlayerPlacePoint> = [];

		walkInteractables = new FlxTypedGroup<Interactable>();
		walkInteractables.camera = camGame;
		walkInteractables.visible = false;
		add(walkInteractables);

		interactInteractables = new FlxTypedGroup<Interactable>();
		interactInteractables.camera = camGame;
		interactInteractables.visible = false;
		add(interactInteractables);

		player.interaction.add(function(hb:CtSprite):Void
		{
			if (!inCutscene)
			{
				for (interactable in interactInteractables.members)
				{
					if (FlxG.overlap(interactable, hb))
					{
						if (triggerInteractable(interactable) == TRIGGERED)
						{
							break;
						};
					}
				}	
			}
		});

		map.loadEntities(function(entity:EntityData):Void
		{
			switch (entity.name)
			{
				case "interactable":
					var interactable = new Interactable().addByEntity(entity);

					if (interactable.type == WALK)
					{
						walkInteractables.add(interactable);
					}
					else if (interactable.type == INTERACT)
					{
						interactInteractables.add(interactable);
					}
				case "player":
					playerPlacePoints.push(new PlayerPlacePoint(entity));
				case "character":
					placeCharacter(entity.x * Constants.overworldPixelScale, entity.y * Constants.overworldPixelScale, entity.values.name, entity.values.tag);
				case "door":
					var door = new Door(entity.values.doorName, entity.values.tag, player, Std.int(entity.x * Constants.overworldPixelScale),
						Std.int(entity.y * Constants.overworldPixelScale), entity.values.horizontal, entity.values.room, entity.values.transitionTime,
						entity.values.lockedDialogue, entity.values.scriptFunction);

					props.add(door);
					interactInteractables.add(door);
				case "prop":
					props.add(new Prop(entity.values.propName, entity.values.tag, entity.x, entity.y));
				case "scrollingprop":
					var scrollingprop = new ScrollingProp(entity.values.tag, Constants.scrollingPropImagePath + entity.values.propName + ".png",
						Std.int(entity.x * Constants.overworldPixelScale), Std.int(entity.y * Constants.overworldPixelScale),
						Std.int(entity.width * Constants.overworldPixelScale), Std.int(entity.height * Constants.overworldPixelScale));
					scrollingprop.backdrop.velocity.set(entity.values.velocityX, entity.values.velocityY);
					scrollingprop.backdrop.setGraphicSize(scrollingprop.backdrop.width * Constants.overworldPixelScale,
						scrollingprop.backdrop.height * Constants.overworldPixelScale);
					scrollingprop.updateHitbox();
					scrollingprop.backdrop.setPosition(16, 16);
					props.add(scrollingprop);
				case "lightsource":
					lightingCover.addLightSource(entity.values.graphic, Std.int(entity.x * Constants.overworldPixelScale),
						Std.int(entity.y * Constants.overworldPixelScale), entity.values.tag);
				case "savespot":
					var savespot = new SaveSpot(entity.values.name, entity.values.saveName, entity.values.tag,
						Std.int(entity.x * Constants.overworldPixelScale), Std.int(entity.y * Constants.overworldPixelScale));

					props.add(savespot);
					interactInteractables.add(savespot);
				default:
					//
			}
		}, "entities");

		var placePointsContainsPreviousRoom:Bool = false;
		var placePointsContainsSavePoint:Bool = false;

		if (previousRoom != "" || (savePointName != "" && startAtSavePoint))
		{
			if(startAtSavePoint){
				for (placePoint in playerPlacePoints)
				{
					if (placePoint.entranceSave == savePointName && startAtSavePoint)
					{
						placePointsContainsSavePoint = true;
						break;
					}
				}
			} 
			
			if(!placePointsContainsSavePoint){
				for (placePoint in playerPlacePoints){
					if (placePoint.entrance == previousRoom && placePoint.entrance != "")
					{
						placePointsContainsPreviousRoom = true;
						break;
					}
				}	
			}
		}

		var placed:Bool = false;
		
		for (placePoint in playerPlacePoints)
		{
			if (!placed)
			{
				if ((placePoint.entranceSave == savePointName && startAtSavePoint))
				{
					player.positionCharacter(placePoint.position.x * Constants.overworldPixelScale, placePoint.position.y * Constants.overworldPixelScale);
					placed = true;
					break;
				}
				else if ((placePoint.entrance == previousRoom && placePoint.entrance != "" && !placePointsContainsSavePoint)|| placePoint.entrance == "" && !placePointsContainsPreviousRoom && !placePointsContainsSavePoint)
				{
				player.positionCharacter(placePoint.position.x * Constants.overworldPixelScale, placePoint.position.y * Constants.overworldPixelScale);
					placed = true;
					break;
				}	
			}
		}
		for (prop in props)
		{
			if (prop is Door)
			{
				var door:Door = cast prop;
				door.updateAlpha();
				door.lerpManager.snap();
			}
		}
		add(lightingCover);

		#if showLightSources
		remove(lightingCover);
		#end
		
		overMap = new FlxSpriteGroup();
		overMap.camera = camGame;
		add(overMap);
		
		add(spr_infrontTiles);
		add(tile_main_front);
		add(tile_foreground);

		spr_top = new FlxSpriteGroup();
		spr_top.camera = camGame;
		add(spr_top);
		
		for (script in roomData.script)
		{
			addScript(Constants.roomScriptPath + script + ".hx");
		}
		startAtSavePoint = false;
	}

	/**
	 * Call this to add a character to the map
	 * @param x the x position of the character
	 * @param y the y position of the character
	 * @param name the name of the character
	 * @return the character youre adding
	 */
	function placeCharacter(x:Float, y:Float, name:String, tag:String):Character
	{
		var char = new Character(name, tag);
		char.positionCharacter(x, y);
		char.camera = camGame;
		props.add(char);

		return char;
	}
	
	function getCharacterByTag(tag:String):Character
	{
		for (prop in props)
		{
			if (prop is Character)
			{
				var character:Character = cast prop;
				if (character.tag == tag)
				{
					return character;
				}
			}
		}

		return null;
	}
	function getPropByTag(tag:String):Prop
	{
		for (prop in props)
		{
			if (prop is Prop)
			{
				var realProp:Prop = cast prop;

				if (realProp.tag == tag)
					return realProp;
			}
		}

		return null;
	}
	
	function getInteractableByTag(tag:String):Interactable
	{
		for (interactable in interactInteractables)
		{
			if (interactable.tag == tag)
			{
				return interactable;
			}
		}

		for (interactable in walkInteractables)
		{
			if (interactable.tag == tag)
			{
				return interactable;
			}
		}

		return null;
	}

	function getDoorByTag(tag:String):Door
	{
		for (prop in props)
		{
			if (prop is Door)
			{
				var door:Door = cast prop;

				if (door.tag == tag)
					return door;
			}
		}

		return null;
	}
	
	function getLightSourceByTag(tag:String):LightSourceSprite
	{
		for (light in lightingCover.lightSources)
		{
			if (light.tag == tag)
			{
				return light;
			}
		}

		return null;
	}
	
	function getScrollingPropByTag(tag:String):ScrollingProp
	{
		for (prop in props)
		{
			if (prop is ScrollingProp)
			{
				var scrollingProp:ScrollingProp = cast prop;

				if (scrollingProp.tag == tag)
					return scrollingProp;
			}
		}

		return null;
	}
	
	/**
	 * Call this to trigger an interactable object!!
	 * @param interactable the interactable object to trigger
	 */
	function triggerInteractable(interactable:Interactable):InteractableOutcome
	{
		if (interactable.disabled)
		{
			return BLOCKED;
		}
		
		interactable.triggerSignal.dispatch();
		
		if (interactable.dialogue != "")
		{
			startDialogue([interactable.dialogue]);
		}
		if (interactable.room != "")
		{
			moveRoom(interactable.room, interactable.roomTransitionTime);
		}
		if (interactable.encounterName != "")
		{
			startBattle(interactable.encounterName);
		}
		if (interactable.scriptFunction != "")
		{
			executeScriptFunction(interactable.scriptFunction, []);
		}
		if (interactable.openSave)
		{
			var useDialogue:Bool = false;

			var lastSavedHP:Map<String, Int> = [];
			var lastSavedMP:Map<String, Int> = [];

			for(unit in Unit.getListOfUnits()){
				lastSavedHP.set(unit, Save.savedUnitHP.get(unit));
				lastSavedMP.set(unit, Save.savedUnitMP.get(unit));
			}

			Save.resetSavedHpMp();

			for(unit in Unit.getListOfUnits()){
				if(lastSavedHP.get(unit) != Save.savedUnitHP.get(unit) || lastSavedMP.get(unit) != Save.savedUnitMP.get(unit)){
					useDialogue = true;
					break;
				}
			}

			if(useDialogue){
				startDialogue(["general/dialogue_restorehpmp"], function():Void{
					openSaveMenu(interactable.saveName, interactable.saveBgName);
				});
			} else {
				openSaveMenu(interactable.saveName, interactable.saveBgName);
			}
		}
		
		return TRIGGERED;
	}

	/**
	 * Call this to change which room youre in
	 * @param newRoom the name of the new room
	 * @param transitionTime how long the transition should last
	 */
	function moveRoom(newRoom:String, transitionTime:Float):Void
	{
		previousRoom = roomName;

		roomName = newRoom;
		lastTransitionTime = transitionTime;

		lastFacing = player.facing;
		
		inCutscene = true;

		new FlxTimer().start(0.1, function(f):Void
		{
			doRoomTransition(transitionTime, OUT, function():Void
			{
				FlxG.resetState();
			});
		});
	}
	/**
	 * Call this to add the room transition animation
	 * @param time how long it should last
	 * @param transitionType in vs out 
	 * @param onComplete what should happen when the transition is done
	 */
	function doRoomTransition(time:Float, transitionType:TransitionType, ?onComplete:Void->Void = null):Void
	{
		if (time <= 0)
		{
			if (onComplete != null)
				onComplete();
		}
		else
		{
			var timeToWait:Float = 0;

			var cover:CtSprite = null;

			if (transitionType == IN)
			{
				cover = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.BLACK);
				cover.camera = camUI;
				add(cover);

				timeToWait = 0.1;
			}

			new FlxTimer().start(timeToWait, function(f):Void
			{
				if (cover != null)
					cover.destroy();
				
				var tranSubState = new RoomTransitionSubState(time, transitionType);
				tranSubState.onComplete.add(function():Void
				{
					if (onComplete != null)
						onComplete();
				});
				openSubState(tranSubState);
				persistentUpdate = false;
			});
		}
	}

	/**
	 * Call this to start a dialogue box cutscene!!
	 * @param dialogues 
	 */
	function startDialogue(dialogues:Array<String>, ?onComplete:Void->Void):Void
	{
		inCutsceneBeforeDialogue = inCutscene;
		inCutscene = true;
		dialogueBox.loadDialogueFiles(dialogues);
		dialogueBox.openBox();
		dialogueBox.playDialogue();
		onDialogueComplete = onComplete;
	}

	/**
	 * Call this when a dialogue is finished
	 */
	function endDialogues():Void
	{
		new FlxTimer().start(0.1, function(f):Void
		{
			inCutscene = inCutsceneBeforeDialogue;
			if (onDialogueComplete != null)
				onDialogueComplete();
		});
	}
	/**
	 * Call this to start a battle !!
	 * @param name 
	 */
	function startBattle(name:String):Void
	{
		leftForBattle = true;

		lastFacing = player.facing;

		positionBeforeBattle.set(player.x, player.y);

		FlxG.sound.play(Constants.sfx_encounter + ".ogg", 1);

		if(FlxG.sound.music != null){
			FlxG.sound.music.stop();
			FlxG.sound.music.destroy();
		}

		PlayState.setUpMusic(new BattleData(name));

		doBattleTransition(IN, function():Void
		{
			PlayState.setBattle(name, STORY);
			FlxG.switchState(PlayState.new);
		});
	}

	function doBattleTransition(transitionType:TransitionType, ?onComplete:Void->Void):Void
	{
		player.facing = DOWN;

		var startZoom:Float = 1;
		var endZoom:Float = 10;

		camGame.zoom = startZoom;

		handleCameraScroll();

		var startCameraPosition:FlxPoint = FlxPoint.get(camGame.scroll.x, camGame.scroll.y);
		var endCameraPosition:FlxPoint = FlxPoint.get(player.x + player.width / 2 - FlxG.width / 2, player.y + player.height / 2 - FlxG.height / 2);

		var startBlockWidth:Float = 1;
		var endBlockWidth:Float = FlxG.width / 2 * (FlxG.random.float(0.8, 1.2));

		var startBlockHeight:Float = 1;
		var endBlockHeight:Float = FlxG.height / 2 * (FlxG.random.float(0.8, 1.2));

		var startFadeAlpha:Float = 0;
		var endFadeAlpha = 1;

		lockCamera = true;
		inCutscene = true;

		new FlxTimer().start(transitionType == IN ? .5 : 0, function(f):Void
		{
			battleTransition = new MosaicEffect();
			battleTransition.thewidth = transitionType == IN ? startBlockWidth : endBlockWidth;
			battleTransition.theheight = transitionType == IN ? startBlockHeight : endBlockHeight;

			var shaderfilter = (new ShaderFilter(battleTransition));

			camGame.filters = [shaderfilter];
			camLighting.filters.push(shaderfilter);
			
			FlxTween.tween(battleTransition, {
				thewidth: transitionType == IN ? endBlockWidth : startBlockWidth,
				theheight: transitionType == IN ? endBlockHeight : startBlockHeight
			}, 1, {
				ease: transitionType == IN ? FlxEase.quartIn : FlxEase.quartOut,
				onComplete: function(f):Void
				{
					if (transitionType == OUT)
					{
						camGame.filters = [];
						camLighting.filters.remove(shaderfilter);
						shaderfilter = null;
						battleTransition = null;
					}
				}
			});
		});

		camGame.scroll.set(transitionType == IN ? startCameraPosition.x : endCameraPosition.x,
			transitionType == IN ? startCameraPosition.y : endCameraPosition.y);

		FlxTween.tween(camGame.scroll,
			{x: transitionType == IN ? endCameraPosition.x : startCameraPosition.x, y: transitionType == IN ? endCameraPosition.y : startCameraPosition.y}, 1,
			{startDelay: transitionType == IN ? 0 : .5});

		camGame.zoom = transitionType == IN ? startZoom : endZoom;

		FlxTween.tween(camGame, {zoom: transitionType == IN ? endZoom : startZoom}, 1.5, {
			ease: transitionType == IN ? FlxEase.quartIn : FlxEase.quartOut,
			onComplete: function(f):Void
			{
				if (transitionType == OUT)
				{
					player.facing = lastFacing;
				}

				inCutscene = false;
				lockCamera = false;

				if (onComplete != null)
				{
					onComplete();
				}
			}
		});

		var spr = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.WHITE);
		spr.camera = camUI;
		spr.alpha = transitionType == IN ? startFadeAlpha : endFadeAlpha;
		add(spr);

		new FlxTimer().start(transitionType == IN ? .5 : 0, function(f):Void
		{
			FlxTween.tween(spr, {alpha: transitionType == IN ? endFadeAlpha : startFadeAlpha}, 1, {
				ease: transitionType == IN ? FlxEase.quartIn : FlxEase.quartOut,
				onComplete: function(f):Void
				{
					if (transitionType == OUT)
						spr.destroy();
				}
			});
		});
	}

	function openSaveMenu(saveName:String, bgName:String):Void
	{		
		savePointName = saveName;

		inCutscene = true;

		openSubState(new SaveLoadMenu(SAVE, bgName, function():Void
		{
			inCutscene = false;
		}, function():Void
		{
			inCutscene = false;
		}));
	}
	
	function addScript(path:String):CtScript
	{
		var script = new CtScript(path);

		if (script.script == null)
			return null;

		script.setValue({name: "getCharacterByTag", value: getCharacterByTag});
		script.setValue({name: "getPropByTag", value: getPropByTag});
		script.setValue({name: "getInteractableByTag", value: getInteractableByTag});
		script.setValue({name: "getDoorByTag", value: getDoorByTag});
		script.setValue({name: "getLightSourceByTag", value: getLightSourceByTag});
		script.setValue({name: "getScrollingPropByTag", value: getScrollingPropByTag});

		script.setValue({name: "player", value: player});
		script.setValue({name: "startDialogue", value: startDialogue});

		script.setValue({name: "lightingCover", value: lightingCover});
				
		script.setValue({name: "camGame", value: camGame});
		script.setValue({name: "camLighting", value: camLighting});
		script.setValue({name: "camOverlay", value: camOverlay});
		script.setValue({name: "camUI", value: camUI});

		script.setValue({name: "executeScriptFunction", value: executeScriptFunction});
		script.setValue({name: "executeSingleScriptFunction", value: executeSingleScriptFunction});

		script.setValue({name: "moveRoom", value: moveRoom});
		script.setValue({name: "startBattle", value: startBattle});

		// get, set
		script.setValue({name: "get_inCutscene", value: get_inCutscene});
		script.setValue({name: "set_inCutscene", value: set_inCutscene});

		script.setValue({name: "get_lockCamera", value: get_lockCamera});
		script.setValue({name: "set_lockCamera", value: set_lockCamera});

		script.setValue({name: "get_unbindCamera", value: get_unbindCamera});
		script.setValue({name: "set_unbindCamera", value: set_unbindCamera});

		script.setValue({name: "get_lightingCover", value: get_lightingCover});
		script.setValue({name: "set_lightingCover", value: set_lightingCover});
		
		script.setValue({name: "get_map", value: get_map});
		script.setValue({name: "set_map", value: set_map});

		script.setValue({name: "get_underMap", value: get_underMap});
		script.setValue({name: "set_underMap", value: set_underMap});

		script.setValue({name: "get_overMap", value: get_overMap});
		script.setValue({name: "set_overMap", value: set_overMap});
		
		script.setValue({name: "get_spr_behindTiles", value: get_spr_behindTiles});
		script.setValue({name: "set_spr_behindTiles", value: set_spr_behindTiles});

		script.setValue({name: "get_spr_infrontTiles", value: get_spr_infrontTiles});
		script.setValue({name: "set_spr_infrontTiles", value: set_spr_infrontTiles});
		
		script.setValue({name: "get_lightingShader", value: get_lightingShader});
		script.setValue({name: "set_lightingShader", value: set_lightingShader});
		
		script.setValue({name: "get_player", value: get_player});
		script.setValue({name: "set_player", value: set_player});
		
		script.setValue({name: "get_dialogueBox", value: get_dialogueBox});
		script.setValue({name: "set_dialogueBox", value: set_dialogueBox});

		script.setValue({name: "get_inCutsceneBeforeDialogue", value: get_inCutsceneBeforeDialogue});
		script.setValue({name: "set_inCutsceneBeforeDialogue", value: set_inCutsceneBeforeDialogue});
		
		script.setValue({name: "get_tile_main_front", value: get_tile_main_front});
		script.setValue({name: "set_tile_main_front", value: set_tile_main_front});
		
		script.setValue({name: "get_spr_behindProps", value: get_spr_behindProps});
		script.setValue({name: "set_spr_behindProps", value: set_spr_behindProps});

		script.setValue({name: "get_props", value: get_props});
		script.setValue({name: "set_props", value: set_props});

		script.setValue({name: "get_spr_top", value: get_spr_top});
		script.setValue({name: "set_spr_top", value: set_spr_top});
		
		script.setValue({name: "get_encountersDisabled", value: get_encountersDisabled});
		script.setValue({name: "set_encountersDisabled", value: set_encountersDisabled});

		scripts.push(script);
		script.executeFunction("create");

		return script;
	}

	// inCutscene
	
	public function get_inCutscene():Bool
	{
		return inCutscene;
	}

	function set_inCutscene(val:Bool):Void
	{
		inCutscene = val;
	}

	// lockCamera
	
	function get_lockCamera():Bool
	{
		return lockCamera;
	}

	function set_lockCamera(val:Bool):Void
	{
		lockCamera = val;
	}

	// unbindCamera
	
	function get_unbindCamera():Bool
	{
		return unbindCamera;
	}

	function set_unbindCamera(val:Bool):Void
	{
		unbindCamera = val;
	}
	
	// lightingCover

	function get_lightingCover():LightingSprite
	{
		return (lightingCover);
	}

	function set_lightingCover(val:LightingSprite):Void
	{
		lightingCover = val;
	}
	
	// map

	function get_map():BetterFlxOgmo3Loader
	{
		return (map);
	}

	function set_map(val:BetterFlxOgmo3Loader):Void
	{
		map = val;
	}

	// underMap

	function get_underMap():FlxSpriteGroup
	{
		return (underMap);
	}

	function set_underMap(val:FlxSpriteGroup):Void
	{
		underMap = val;
	}

	// overMap

	function get_overMap():FlxSpriteGroup
	{
		return (overMap);
	}

	function set_overMap(val:FlxSpriteGroup):Void
	{
		overMap = val;
	}
	
	// spr_belowTiles

	function get_spr_behindTiles():FlxSpriteGroup
	{
		return (spr_behindTiles);
	}

	function set_spr_behindTiles(val:FlxSpriteGroup):Void
	{
		spr_behindTiles = val;
	}

	// spr_frontOfTiles

	function get_spr_infrontTiles():FlxSpriteGroup
	{
		return (spr_infrontTiles);
	}

	function set_spr_infrontTiles(val:FlxSpriteGroup):Void
	{
		spr_infrontTiles = val;
	}
	
	// lightingShader

	function get_lightingShader():LightingEffectShader
	{
		return (lightingShader);
	}

	function set_lightingShader(val:LightingEffectShader):Void
	{
		lightingShader = val;
	}
	
	// player

	function get_player():Player
	{
		return player;
	}

	function set_player(val:Player):Void
	{
		player = val;
	}
	
	// dialogueBox

	function get_dialogueBox():CtDialogueBox
	{
		return dialogueBox;
	}

	function set_dialogueBox(val:CtDialogueBox):Void
	{
		dialogueBox = val;
	}

	// inCutsceneBeforeDialogue

	function get_inCutsceneBeforeDialogue():Bool
	{
		return inCutsceneBeforeDialogue;
	}

	function set_inCutsceneBeforeDialogue(val:Bool):Void
	{
		inCutsceneBeforeDialogue = val;
	}
	
	// tile_main_front

	function get_tile_main_front():FlxTypedGroup<FlxTilemap>
	{
		return tile_main_front;
	}

	function set_tile_main_front(val:FlxTypedGroup<FlxTilemap>):Void
	{
		tile_main_front = val;
	}
	
	// spr_behindProps

	function get_spr_behindProps():FlxSpriteGroup
	{
		return (spr_behindProps);
	}

	function set_spr_behindProps(val:FlxSpriteGroup):Void
	{
		spr_behindProps = val;
	}
	
	// props

	function get_props():FlxTypedSpriteGroup<FlxSprite>
	{
		return (spr_behindProps);
	}

	function set_props(val:FlxTypedSpriteGroup<FlxSprite>):Void
	{
		props = val;
	}

	// spr_top

	function get_spr_top():FlxSpriteGroup
	{
		return (spr_top);
	}

	function set_spr_top(val:FlxSpriteGroup):Void
	{
		spr_top = val;
	}

	// encountersDisabled

	function get_encountersDisabled():Bool
	{
		return encountersDisabled;
	}

	function set_encountersDisabled(val:Bool):Void
	{
		encountersDisabled = val;
	}

	function executeScriptFunction(name:String, args:Array<Any>):Void
	{
		for (script in scripts)
		{
			script.executeFunction(name, args);
		}
	}
	
	function executeSingleScriptFunction(scriptName:String, name:String, args:Array<Any>):Dynamic
	{
		for (script in scripts)
		{
			if (script.name == scriptName)
			{
				return script.executeFunction(name, args);
			}
		}

		return null;
	}
	
	public static function resetGlobalVars():Void
	{
		lastTransitionTime = 0;
		lastFacing = DOWN;
		previousRoom = "";
		leftForBattle = false;
		positionBeforeBattle.set(0, 0);
		startAtSavePoint = true;
	}
	#if debug
	function addDebugFunctions():Void
	{
		#if traceRoomInfo
		trace("[Room]");
		trace("cur: " + roomName);
		trace("prev: " + previousRoom);
		trace("save: " + savePointName);
		#end
	}

	function updateDebugFunctions():Void
	{
		FlxG.watch.addQuick("inCutscene", inCutscene);
		FlxG.watch.addQuick("inCutsceneBeforeDialogue", inCutsceneBeforeDialogue);
		FlxG.watch.addQuick("camGame.scroll.x", camGame.scroll.x);
		FlxG.watch.addQuick("camGame.scroll.y", camGame.scroll.y);
		#if enableQuickSave
		if (FlxG.keys.justPressed.SEVEN)
		{
			Save.save();
		}
		#end
	}
	#end
}