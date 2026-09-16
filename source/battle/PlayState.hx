package battle;

class PlayState extends FlxState
{
	public static var eventManager:CtEventManager;
	
	public static var battleName:String = "test";
	public static var battleData:BattleData;
	public static var battleType:BattleType;

	// CAMERAS
	var camGame:CtCamera;
	var camUI:FlxCamera;
	var camDialogue:FlxCamera;
	var cameraTrackerType:BattleCameraTrackingType = CENTERED;	

	// BG STUFF
	var bg:BattleBackground;
	var bgLine:CtSprite;

	// GRID STUFF
	var gridSize:FlxPoint = new FlxPoint();

	var allyGrid:Grid;
	var enemyGrid:Grid;

	var allyGridBg:GridBackground;
	var enemyGridBg:GridBackground;

	var grids:Array<Grid> = [];
	
	var gridSelectorOptions:Array<Array<CtMenuOption>> = [];
	var gridSelectorSpaces:Array<GridSpace> = [];

	var currentSelectedGridSpace:FlxSprite;

	var gridUnitPlacer:GridUnitPlacer;
	
	// UI STUFF
	var statusEffectBars:StatusEffectBars;

	var miniHealthBars:MiniHealthBars;

	var turnAttentionAnim:TurnAttentionAnim;
 
	var turnOrderDisplay:TurnOrderDisplay;
	
	var bottomBar:BottomBar;
	
	var damageTexts:FlxTypedGroup<DamageText>;

	public var damageTextSignal = new FlxTypedSignal<Unit->String->FlxColor->Void>();
	
	var roundAnim:RoundAnim;
	
	var inspectingSpr:CtSprite;

	var dialogueBox:CtDialogueBox;
	var dialogueBg:CtSprite;
	var onDialogueComplete:Void->Void;

	// MENU MANAGERS
	var menuManagerPlayerUI:CtMenuManager;
	var menuManagerGridSelector:CtMenuManager;
	var menuManagerUnitInspector:CtMenuManager;
	var menus:Array<CtMenuManager> = [];
	
	// GAME STUFF

	var units:Array<Unit> = [];
	var allyUnitGroup:FlxTypedGroup<Unit>;
	var enemyUnitGroup:FlxTypedGroup<Unit>;

	var roundNum:Int = 0;
	var turnNum:Int = 0;
	var turnOrder:Array<Unit> = [];
	
	var currentTurnUnit:Unit;

	var uiStatus:UIStatus = INACTIVE;
	
	var disableInspectButton:Bool = false;
	var disableEndTurnButton:Bool = false;

	// EXIT
	var exitProgress:Float = 0;
	
	// DEATH EFFECT
	var deathEffects:Array<DeathEffect> = [];
	
	// SCRIPTS
	var scripts:Array<CtScript> = [];
	
	// EXP
	var expReward:Int = 0;

	public static var battleFrozen:Bool = false;
	public static var preventBattleEnding:Bool = false;

	override public function create()
	{
		persistentUpdate = true;
		
		eventManager = new CtEventManager();
		eventManager.reset();
		
		battleFrozen = false;
		preventBattleEnding = false;
		
		loadBattle();

		setupCameras();
		setUpBg();
		setUpGrids();
		setUpUI();
		addInitialUnits();

		setUpMenus();

		if(FlxG.sound.music == null && battleData.music != "") setUpMusic(battleData);
		
		setUpScripts();

		doIntroAnim();
		
		#if debug
		addDebugFunctions();
		#end
		
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		removeUnusedDamageTexts();
		updateDeathEffects(elapsed);
		for (menu in menus)
		{
			menu.update();
		}
		if (CtControls.checkInput("exit", PRESSED))
		{
			exitProgress += elapsed;

			if (exitProgress >= Constants.exitTime)
			{	
				FlxG.switchState(LevelSelectorState.new);
			}
		}
		else
		{
			exitProgress = 0;
		}
		eventManager.update();
		handleCamera(elapsed);

		if(uiStatus == GRID_INSPECT || uiStatus == GRID_PLACER_INSPECT){
			inspectingSpr.lerpManager.targetAlpha = .3;
		} else {
			inspectingSpr.lerpManager.targetAlpha = 0;
		}

		executeScriptFunction("update", [elapsed]);
	}
	
	/**
	 * Call this to initialize this battles JSON file
	 */
	function loadBattle():Void
	{
		battleData = new BattleData(battleName);

		bgColor = FlxColor.GRAY;

		gridSize.set(battleData.gridSizeX, battleData.gridSizeY);
	}

	/**
	 * call this to add the flxcameras that the game uses hehehe
	 */
	function setupCameras():Void
	{
		camGame = new CtCamera();
		camGame.bgColor.alpha = 0;
		camGame.lerpManager.lerpX = true;
		camGame.lerpManager.lerpY = true;
		camGame.lerpManager.lerpSpeed = Constants.battleCameraMovementSpeed;
		FlxG.cameras.add(camGame, true);

		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);

		camDialogue = new FlxCamera();
		camDialogue.bgColor.alpha = 0;
		FlxG.cameras.add(camDialogue, false);
	}
	
	function handleCamera(elapsed:Float):Void
	{
		var scrollPoint = FlxPoint.get();

		switch (cameraTrackerType)
		{
			case CENTERED:
				scrollPoint.set(0, 0);
			case UNIT | GRID:
				var trackableSpr:FlxSprite = new FlxSprite();

				if (cameraTrackerType == UNIT)
				{
					trackableSpr = currentTurnUnit;
				}
				else if (cameraTrackerType == GRID)
				{
					trackableSpr = currentSelectedGridSpace;
				}

				scrollPoint.set(-(((FlxG.width / 2) - (trackableSpr.x + trackableSpr.width / 2)) * Constants.battleCameraMovementX),
					-(((FlxG.height / 2) - (trackableSpr.y + trackableSpr.height / 2))) * Constants.battleCameraMovementY);
		}

		camGame.lerpManager.targetPosition.set(scrollPoint.x, scrollPoint.y);
	}
	
	/**
	 * Call this to add the background sprites
	 */
	function setUpBg():Void
	{
		bg = new BattleBackground(battleData.background);
		bg.camera = camGame;
		add(bg);
		
		var sizing = Grid.calculateGridSize(gridSize);

		bgLine = new CtSprite().createColorBlock(FlxG.width * 2, Std.int(sizing.y + Constants.gridSize), FlxColor.WHITE);
		bgLine.alpha = (.5 * bg.data.gridBgAlpha);
		bgLine.screenCenter(X);
		bgLine.y = (FlxG.height / 2 - bgLine.height / 2) + Constants.uiYOffset;
		bgLine.camera = camGame;
		add(bgLine);
	}

	/**
	 * Call this to initialize the grids
	 */
	function setUpGrids():Void
	{
		var sizing = Grid.calculateGridSize(gridSize);
		var midPointX = FlxG.width / 2 - (sizing.x / 2);
		var midPointY = (bgLine.y + bgLine.height / 2) - (sizing.y / 2);
		var spacing:Float = sizing.x + 15;

		allyGrid = new Grid(gridSize, new FlxPoint(midPointX - (spacing), midPointY));
		allyGrid.camera = camGame;

		enemyGrid = new Grid(gridSize, new FlxPoint(midPointX + (spacing), midPointY));
		enemyGrid.camera = camGame;

		enemyGridBg = new GridBackground(enemyGrid);
		enemyGridBg.camera = camGame;
		add(enemyGridBg);

		add(enemyGrid);
		enemyUnitGroup = new FlxTypedGroup<Unit>();
		enemyUnitGroup.camera = camGame;
		add(enemyUnitGroup);

		if (!battleData.disableUnitPlacer)
		{
			gridUnitPlacer = new GridUnitPlacer(allyGrid, enemyGrid);
			gridUnitPlacer.camera = camGame;
			add(gridUnitPlacer);	
		}

		allyGridBg = new GridBackground(allyGrid);
		allyGridBg.camera = camGame;
		add(allyGridBg);

		add(allyGrid);

		allyUnitGroup = new FlxTypedGroup<Unit>();
		allyUnitGroup.camera = camGame;
		add(allyUnitGroup);

		grids = [allyGrid, enemyGrid];
		updateGridSelectorOptions();
	}

	/**
	 * Call this to set up the UI needed for the game
	 */
	function setUpUI():Void
	{
		statusEffectBars = new StatusEffectBars();
		statusEffectBars.camera = camGame;
		add(statusEffectBars);

		miniHealthBars = new MiniHealthBars();
		miniHealthBars.camera = camGame;
		add(miniHealthBars);

		turnAttentionAnim = new TurnAttentionAnim();
		turnAttentionAnim.camera = camGame;
		add(turnAttentionAnim);

		bottomBar = new BottomBar(bg.data.uiStyle);
		bottomBar.camera = camUI;
		add(bottomBar);
		
		inspectingSpr = new CtSprite().createFromImage(Constants.inspect2ButtonGraphicPath);
		inspectingSpr.alpha = 0;
		inspectingSpr.setPosition(bottomBar.inspect.x, bottomBar.inspect.y);
		inspectingSpr.lerpManager.targetAlpha = 0;
		inspectingSpr.lerpManager.lerpSpeed = 15;
		inspectingSpr.lerpManager.lerpAlpha = true;
		inspectingSpr.camera = camUI;
		inspectingSpr.antialiasing = false;
		add(inspectingSpr);

		damageTexts = new FlxTypedGroup<DamageText>();
		damageTexts.camera = camGame;
		add(damageTexts);
		
		damageTextSignal.add(function(unit:Unit, text:String, color:FlxColor)
		{
			damageTexts.add(new DamageText(unit, text, color));
		});

		roundAnim = new RoundAnim();
		add(roundAnim);

		turnOrderDisplay = new TurnOrderDisplay(gridSize);
		turnOrderDisplay.camera = camGame;
		turnOrderDisplay.scrollFactor.set(0, 0);
		add(turnOrderDisplay);

		dialogueBg = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.BLACK);
		dialogueBg.alpha = .6;
		dialogueBg.kill();
		dialogueBg.camera = camUI;
		add(dialogueBg);

		dialogueBox = new CtDialogueBox();
		dialogueBox.camera = camDialogue;
		dialogueBox.antialiasing = false;
		add(dialogueBox);
		dialogueBox.onComplete.add(endDialogues);
	}

	/**
	 * Call this to set up the different menus used for the games ui
	 */
	function setUpMenus():Void
	{
		// init menuManagerPlayerUI
		menuManagerPlayerUI = new CtMenuManager();
		add(menuManagerPlayerUI.addCursor(menuMakeCursor(), 20, false));
		// init menuManagerGridSelector
		menuManagerGridSelector = new CtMenuManager();
		var gridSelectorCursor = menuMakeCursor();
		gridSelectorCursor.camera = camGame;
		add(menuManagerGridSelector.addCursor(gridSelectorCursor, 20, false));
		menuManagerGridSelector.selectSoundPath = Constants.sfx_ui_gridSelect;
		menuManagerGridSelector.scrollRackSoundPath = Constants.sfx_ui_gridScroll;
		menuManagerGridSelector.scrollSelectedSoundPath = Constants.sfx_ui_gridScroll;
		// init menuManagerUnitInspector
		menuManagerUnitInspector = new CtMenuManager();
		add(menuManagerUnitInspector.addCursor(menuMakeCursor(), 20, false));

		menus = [menuManagerPlayerUI, menuManagerGridSelector, menuManagerUnitInspector];
	}

	function menuMakeCursor():Cursor
	{
		var cursor = new Cursor(Constants.cursorArrowGraphic);
		cursor.camera = camUI;
		return cursor;
	}
	
	/**
	 * Call this to add the units listed in this battles JSON file to the field
	 */
	function addInitialUnits():Void
	{
		for (unit in battleData.allyUnits)
		{
			placeUnit(unit.id, allyGrid, unit.position, true, unit.level, false, false, unit.tag);
		}
		for (unit in battleData.enemyUnits)
		{
			placeUnit(unit.id, enemyGrid, unit.position, false, unit.level, false, false, unit.tag);
		}
	}
	
	/**
	 * Call this to place a unit down on the grid.
	 * @param unitID The id/name of the unit you want to place
	 * @param grid Which grid you want to place it on
	 * @param position Which position on the grid you want to place it on
	 * @param controllable Should this unit be controllable or not? basically is it an enemy or ally
	 */
	function placeUnit(unitID:String, grid:Grid, position:FlxPoint, controllable:Bool, level:Int, ?doAnim:Bool = true, ?placedByPlayer:Bool = false, ?tag:String = ""):Void
	{
		if (position.x >= gridSize.x || position.y >= gridSize.y)
		{
			FlxG.log.error("Can't place unit \"" + unitID + "\" at " + position.x + ", " + position.y + ". Out of bounds!");
			return;
		}
		
		if (Grid.getGridSpaceFromGrid(grid, position).unit != null)
		{
			FlxG.log.error("Can't place unit \"" + unitID + "\" at " + position.x + ", " + position.y + ". Occupied!");
			return;
		}
		
		var unit = new Unit(unitID, grid, position, controllable, level, placedByPlayer, tag);
		unit.camera = camGame;
		if (controllable)
		{
			allyUnitGroup.add(unit);
		}
		else
		{
			expReward += Std.int(unit.data.expReward * (unit.level / 1.5));
			enemyUnitGroup.add(unit);
		}

		grid.placeUnit(unit);

		if (doAnim)
			unit.doEntranceAnimation();

		units.push(unit);
		statusEffectBars.addNewBar(unit);
		miniHealthBars.addNewBar(unit);
	}

	/**
	 * Call this to remove a unit!!! this will delete its hp bar, its slot in the turn order and remove it from its grid
	 * @param unit the unit to remove from tjhe game
	 */
	function removeUnit(unit:Unit):Void
	{
		statusEffectBars.removeBarByUnit(unit);
		miniHealthBars.removeBarByUnit(unit);

		var changedTurn:Bool = false;
		
		for (i in 0...turnOrder.length)
		{
			if (turnOrder[i] == unit && !changedTurn)
			{
				if (i <= turnNum)
				{
					turnNum--;
				}
				changedTurn = true;
				break;
			}
		}

		turnOrder.remove(unit);
		turnOrderDisplay.updateTurnOrderDisplay(turnOrder);

		for (grid in grids)
		{
			for (space in grid.spaces)
			{
				if (space.unit != null && space.unit.uniqueUnitID == unit.uniqueUnitID)
				{
					space.unit = null;
					break;
				}
			}
		}

		units.remove(unit);
		unit.destroy();
		unit = null;
	}
	
	function getUnitByTag(tag:String):Unit
	{
		for(unit in units){
			if(unit.tag == tag) return unit;
		}

		return null;
	}

	public static function setUpMusic(battleData:BattleData):Void
	{
		var path = Constants.battleDataMusicPath + battleData.music + ".ogg";

		if (battleData.music != "" && Assets.exists(path))
		{
			CtSound.playMusic(path);
			FlxG.sound.music.fadeIn(1, 0, FlxG.sound.music.volume);
		}
	}
	
	/**
	 * Call this to advance the battle turn
	 * @param amount How many turns to advance by. Defaults to 1
	 */
	function advanceTurn(amount:Int = 1):Void
	{
		eventManager.addEvent(function()
		{			
			doDeathCheck();

			eventManager.addEvent(function():Void
			{
				executeScriptFunction("onAdvanceTurn", []);

				if(battleFrozen){
					return;
				}

				turnNum += amount;

				if (turnNum >= turnOrder.length)
				{
					advanceRound();
					return;
				}

				currentTurnUnit = turnOrder[turnNum];

				turnOrderDisplay.updateCurrentTurn(currentTurnUnit);
				bottomBar.updateCurrentUnit(currentTurnUnit);
				turnOrderDisplay.topBar.updateCurrentUnit(currentTurnUnit);

				if (currentTurnUnit.controllable){
					bottomBar.addMenu();
					if(disableEndTurnButton){
						bottomBar.endTurn.kill();
					}
					if(disableInspectButton){
						bottomBar.inspect.kill();
					}
				}

				turnAttentionAnim.doAnim(currentTurnUnit);

				allyGrid.updateHighlightedSpace(0xFFD7FFBA, currentTurnUnit);
				enemyGrid.updateHighlightedSpace(0xFFFFBABA, currentTurnUnit);
				
				cameraTrackerType = UNIT;
				
				new FlxTimer().start(Constants.turnAttentionAnimTime, function(f):Void
				{
					applySingleUnitStatusEffects(currentTurnUnit, "startOfTurn");

					eventManager.addEvent(function():Void
					{
						doDeathCheck();

						if (!currentTurnUnit.dead)
						{
							eventManager.addEvent(function():Void
							{
								if (currentTurnUnit.controllable)
								{
									startAllyTurn();
								}
								else
								{
									startEnemyTurn();
								}
							});	
						}
						else
						{
							advanceTurn();
						}
					});
				});
			});
		});
	}

	/**
	 * Call this to advance the battle round.
	 */
	function advanceRound(?enableUI:Bool = false):Void
	{
		roundNum++;

		calculateTurnOrder();

		turnNum = 0;

		cameraTrackerType = CENTERED;

		allyGrid.updateHighlightedSpace(0xFFD7FFBA, null);
		enemyGrid.updateHighlightedSpace(0xFFFFBABA, null);
				
		bottomBar.updateCurrentUnit(null);
		turnOrderDisplay.topBar.updateCurrentUnit(null);
		
		roundAnim.doAnim("Round " + roundNum, function():Void
		{
			if (enableUI)
			{
				new FlxTimer().start(0.1, function(f):Void
				{
					bottomBar.visible = true;
					turnOrderDisplay.visible = true;
					miniHealthBars.visible = true;
					statusEffectBars.visible = true;

					bottomBar.updateCurrentUnit(null);
					turnOrderDisplay.topBar.updateCurrentUnit(null);

					for (ui in [bottomBar, turnOrderDisplay])
					{
						ui.alpha = 0;
						FlxTween.tween(ui, {alpha: 1}, Constants.turnAttentionAnimTime / 1.5);
					}
					advanceTurn(0);
				});
			}
			else
			{
				advanceTurn(0);
			}
		});
	}

	/**
	 * Call this to start an ally units turn
	 */
	function startAllyTurn():Void
	{
		uiStatus = SELECTING_SKILLS;
		
		var menuOptions:Array<Array<CtMenuOption>> = [[]];

		if(!disableInspectButton){
			menuOptions[0].push({
				sprite: bottomBar.inspect,
				cursorDirection: UP,
				clickFunction: function(spr:FlxSprite):Void
				{
					menuManagerPlayerUI.disable(false);
					uiStatus = GRID_INSPECT;
					bottomBar.removeMenu();
					new FlxTimer().start(0.01, function(f):Void{
						addGridSelector();
					});
				},
				hoverFunction: function(spr:FlxSprite):Void
				{
					for (grid in grids)
					{
						grid.updateFlashingSprites([]);
					}
					updateGridSelectorOptions();
					bottomBar.updateText("View the board");
				}
			});
		}

		for(i in getSkillIconMenuOptions()){
			menuOptions[0].push(i);
		}

		if(!disableEndTurnButton){
			menuOptions[0].push({
				sprite: bottomBar.endTurn,
				cursorDirection: UP,
				clickFunction: function(spr:FlxSprite):Void
				{
					cameraTrackerType = CENTERED;
					endPlayerTurn();
				},
				hoverFunction: function(spr:FlxSprite):Void
				{
					for (grid in grids)
					{
						grid.updateFlashingSprites([]);
					}
					updateGridSelectorOptions();
					bottomBar.updateText("End your turn");
				}
			});
		}

		menuManagerPlayerUI.setMenuOptions(menuOptions);

		menuManagerPlayerUI.enable(true);
		
		menuManagerPlayerUI.playScrollSelectedSound = false;
		menuManagerPlayerUI.changeSelection(disableInspectButton ? 0 : 1);
		menuManagerPlayerUI.playScrollSelectedSound = true;

		cameraTrackerType = UNIT;

		executeScriptFunction("onStartPlayerTurn", []);
	}

	/**
	 * Call this when to end a player units turn
	 */
	function endPlayerTurn():Void
	{
		menuManagerPlayerUI.disable();
		uiStatus = INACTIVE;
		doDeathCheck();

		eventManager.addEvent(function():Void
		{
			applySingleUnitStatusEffects(currentTurnUnit, "endOfTurn");
			applySingleUnitStatusEffects(currentTurnUnit, "passive");
		});

		eventManager.addEvent(function():Void
		{
			if (turnOrder[turnNum + 1] == null || !turnOrder[turnNum + 1].controllable)
				bottomBar.removeMenu();

			advanceTurn();
		});
	}

	/**
	 * Call this to start an enemy units turn
	 */
	function startEnemyTurn():Void
	{
		cameraTrackerType = UNIT;

		var aiDecision = new UnitAi(currentTurnUnit, enemyGrid, allyGrid).getSkill();

		if(aiDecision.skillData == null){ //skip
			cameraTrackerType = CENTERED;
			endEnemyTurn();

			return;
		}

		useSkill(aiDecision.skillData, aiDecision.unit, aiDecision.grid, aiDecision.position, function():Void{
			cameraTrackerType = CENTERED;

			endEnemyTurn();
		});
	}

	/**
	 * Call this when to end an enemy units turn
	 */
	function endEnemyTurn():Void
	{
		doDeathCheck();

		eventManager.addEvent(function():Void
		{
			applySingleUnitStatusEffects(currentTurnUnit, "endOfTurn");
			applySingleUnitStatusEffects(currentTurnUnit, "passive");
		});
		eventManager.addEvent(function():Void
		{
			advanceTurn();
		});
	}
	
	function getSkillIconMenuOptions():Array<CtMenuOption>
	{
		var menuOptions:Array<CtMenuOption> = [];

		for (i in bottomBar.skillIcons)
		{
			if (i.enabled)
				menuOptions.push({
					sprite: i.outlineSprite,
					cursorDirection: UP,
					clickFunction: function(spr:FlxSprite):Void
					{
						if(uiStatus == SELECTING_SKILLS){
							if(i.allowed){
								menuManagerPlayerUI.disable(false);
								new FlxTimer().start(0.01, function(f):Void // jank
								{
									uiStatus = GRID_SKILL;
									addGridSelector();		
								});
							} else {
								bottomBar.updateText(" [[DARKBLUE]](NOT ENOUGH MP!)[[DARKBLUE]]");
								bottomBar.shakeText();
								i.shakeBox();
							}
						}
					},
					hoverFunction: function(spr:FlxSprite):Void
					{
						if(uiStatus == SELECTING_SKILLS){
							for (grid in grids)
							{
								grid.updateFlashingSprites([]);
							}
							updateGridSelectorOptions(i.currentSkill.selectType);
						}
						var mpCost:Int = i.currentSkill.mpCost;
						bottomBar.updateText("[[GRAY]]" + i.currentSkill.name + "[[GRAY]]   " + i.currentSkill.description + "   [[BLUE]]MP: " + mpCost + "[[BLUE]]");
					},
					cancelFunction: function(spr:FlxSprite):Void
					{
						if(uiStatus == GRID_INSPECT || uiStatus == GRID_PLACER_INSPECT){
							menuManagerUnitInspector.disable(true);
							menuManagerGridSelector.enable();

							bottomBar.descriptionText.visible = false;
							bottomBar.descriptionText.kill();
						}
					}
				});
		}

		return menuOptions;
	}

	/**
	 * Call this to chekc for and remove dead units
	 */
	function doDeathCheck():Void
	{		
		for (unit in units)
		{
			if (unit.dead)
			{
				eventManager.addEvent(function():Void
				{
					var transactionName = unit.uniqueUnitID + "_" + "deathAnim";

					eventManager.startTransaction(transactionName);

					addDeathEffect(unit);

					new FlxTimer().start(Constants.deathEffectTime, function(f):Void
					{
						removeUnit(unit);
						eventManager.finishTransaction(transactionName);
					});
				});
			}
		}

		if(!preventBattleEnding) isGameOver();
	}
	function isGameOver():Void
	{
		var alliedUnits:Int = 0;
		var enemyUnits:Int = 0;

		for (unit in units)
		{
			if (unit.dead == false)
			{
				if (unit.controllable)
					alliedUnits++;
				else
					enemyUnits++;
			}
		}
		if (alliedUnits == 0 || enemyUnits == 0){ // game is over
			eventManager.addEvent(function():Void
			{
				eventManager.startTransaction("GAMEOVER"); // never finish this

				bottomBar.updateCurrentUnit(null);
				bottomBar.removeMenu();
				
				turnOrderDisplay.topBar.updateCurrentUnit(null);
				turnOrderDisplay.updateTurnOrderDisplay([]);

				var type:ResultType = TIE;

				if (alliedUnits > enemyUnits)
					type = WIN;
				if (enemyUnits > alliedUnits)
					type = LOSS;
				if (alliedUnits == enemyUnits)
					type = TIE;

				switch(type){
					case WIN:
						var unitsToAdd:Array<String> = [];

						for(unit in units){
							if(unit.placedByPlayer && !unitsToAdd.contains(unit.data.id)){
								unitsToAdd.push(unit.data.id);
							}
						}
						openSubState(new VictoryScreen(unitsToAdd, Std.int(FlxMath.bound(expReward, 1)), function():Void{
							goBackToOverworld();
						}));
					case LOSS | TIE:
						openSubState(new ResultState(type));
				}

				if (FlxG.sound.music != null){
					FlxG.sound.music.fadeOut(Constants.resultAnimTiming, 0, function onComplete(f):Void{
						FlxG.sound.music.destroy();
						FlxG.sound.music = null;
					});
				}
			});
		}
	}

	function goBackToOverworld():Void{
		FlxG.switchState(OverworldState.new);
	}
	
	function addDeathEffect(spr:FlxSprite):Void
	{
		var shader = new DeathEffect(spr);

		spr.shader = shader;

		deathEffects.push(shader);
		shader.finished.add(function():Void
		{
			deathEffects.remove(shader);
		});
	}

	function updateDeathEffects(elapsed:Float):Void
	{
		for (i in deathEffects)
		{
			i.update(elapsed);
		}
	}
	

	/**
	 * Call this to calculate and start the turn order for the next round
	 */
	function calculateTurnOrder():Void
	{
		turnOrder = [];

		for (unit in units)
		{
			turnOrder.push(unit);
		}

		ArraySort.sort(turnOrder, function(a, b)
		{
			if (a.speed.value < b.speed.value)
				return 1;
			if (a.speed.value > b.speed.value)
				return -1;
			return 0;
		});
		turnOrderDisplay.updateTurnOrderDisplay(turnOrder);
	}

	/**
	 * call this to use a skill!!!!
	 * @param skillData which skill to use
	 * @param unit which unit is using the skill
	 * @param grid which grid
	 * @param position where on the grid its being used
	 */
	function useSkill(skillData:SkillData, unit:Unit, grid:Grid, position:FlxPoint, ?onFinish:Void->Void):Void
	{
		unit.mp.changeValue(-skillData.mpCost);

		var affectedSpaces = getAffectedSpacesForSkill(skillData, unit, grid, position);
		
		eventManager.addEvent(function():Void
		{
			for (space in affectedSpaces)
			{
				if (space.unit != null)
				{ // this has a unit on it !!!
					applySkillEffects(space.unit, unit, skillData.effects, skillData);
				}
			}
		});
		if (onFinish != null)
		{
			new FlxTimer().start(.01, function(f):Void
			{
				eventManager.addEvent(function():Void
				{
					onFinish();
				});	
			});
		}
	}
	
	function applySkillEffects(unit:Unit, applyingUnit:Unit, effects:SkillEffects, ?skill:SkillData = null):Void
	{
		if (effects.eff_damage > 0)
		{
			eventManager.addEvent(function():Void
			{
				if (unit != null){

					var damage:Int = 1;

					if(skill == null){
						damage = effects.eff_damage;
					} else {
						damage = calculateSkillDamage(skill, unit, applyingUnit);
					}

					unit.takeDamage(damage);	

					if(effects.eff_hpleech > 0){
						if(applyingUnit != null){
							applyingUnit.heal(Std.int(damage * effects.eff_hpleech));
						}
					}
				}			
			});
		}
		if (effects.eff_heal > 0)
		{
			eventManager.addEvent(function():Void
			{
				if (unit != null)
					unit.heal(effects.eff_heal);
			});
		}
		if (effects.eff_statuses.length > 0)
		{
			for (effect in effects.eff_statuses)
			{
				eventManager.addEvent(function():Void
				{
					if (unit != null)
						unit.applyStatusEffect(effect.id, effect.turns);
				});
			}
		}
	}

	public static function calculateSkillDamage(skill:SkillData, affectedUnit:Unit, attackingUnit:Unit):Int{
		var attackingStat:Int = 0;

		if(skill.damageType == "physical"){
			attackingStat = attackingUnit.attack.value;
		} else if(skill.damageType == "spiritual"){
			attackingStat = attackingUnit.sattack.value;
		}
		
		var passiveDamageMult:Float = 1;

		for(passive in attackingUnit.getPassiveEffects()){
			passiveDamageMult += passive.eff_damageDealt;
		}

		for(passive in affectedUnit.getPassiveEffects()){
			passiveDamageMult += passive.eff_damageTaken;
		}

		passiveDamageMult = FlxMath.bound(passiveDamageMult, 0);
		
		return(Std.int((skill.effects.eff_damage * (attackingStat / 100)) * passiveDamageMult));
	}

	public static function getAffectedSpacesForSkill(skillData:SkillData, unit:Unit, grid:Grid, position:FlxPoint)
	{
		var affectedSpaces:Array<GridSpace> = [];
		if (skillData.rangeX >= 1 && skillData.rangeY >= 1)
		{
			affectedSpaces.push(Grid.getGridSpaceFromGrid(grid, position));

			for (i in 0...skillData.rangeX)
			{
				var gridSpaceXNeg = Grid.getGridSpaceFromGrid(grid, new FlxPoint(affectedSpaces[0].position.x - i, affectedSpaces[0].position.y));

				if (gridSpaceXNeg != null)
				{
					if (!affectedSpaces.contains(gridSpaceXNeg))
						affectedSpaces.push(gridSpaceXNeg);
				}

				var gridSpaceXPos = Grid.getGridSpaceFromGrid(grid, new FlxPoint(affectedSpaces[0].position.x + i, affectedSpaces[0].position.y));
				if (gridSpaceXPos != null)
				{
					if (!affectedSpaces.contains(gridSpaceXPos))
						affectedSpaces.push(gridSpaceXPos);
				}
			}

			for (i in 0...skillData.rangeY)
			{
				var gridSpaceYNeg = Grid.getGridSpaceFromGrid(grid, new FlxPoint(affectedSpaces[0].position.x, affectedSpaces[0].position.y - i));

				if (gridSpaceYNeg != null)
				{
					if (!affectedSpaces.contains(gridSpaceYNeg))
						affectedSpaces.push(gridSpaceYNeg);
				}

				var gridSpaceYPos = Grid.getGridSpaceFromGrid(grid, new FlxPoint(affectedSpaces[0].position.x, affectedSpaces[0].position.y + i));
				if (gridSpaceYPos != null)
				{
					if (!affectedSpaces.contains(gridSpaceYPos))
						affectedSpaces.push(gridSpaceYPos);
				}
			}
		}
		return affectedSpaces;
	}

	public static function getAvailableSpacesForSkillType(type:String, unit:Unit, theGrids:Array<Grid>):Array<GridSpace>
	{
		var spaces = [];

		for (grid in theGrids)
		{
			for (space in grid.spaces)
			{
				if (switch (type)
					{
						case "ally_sameRow": (unit.grid == grid
								&& space.position.y == unit.position.y); // all allies in the same row as the current unit
						case "enemy_sameRow": (unit.grid != grid
								&& space.position.y == unit.position.y); // all enemies in the same row as the current unit
						case "ally_sameColumn": (unit.grid == grid
								&& space.position.x == unit.position.x); // all allies in the same column as the current unit
						case "enemy_sameColumn": (unit.grid != grid
								&& space.position.x == unit.position.x); // all enemies in the same commumn as the current unit
						case "ally_all": (unit.grid == grid); // all allies
						case "enemy_all": (unit.grid != grid); // all enemies
						default: (true); // by default, add all spaces
					})
					spaces.push(space);
			}
		}

		return spaces;
	}
	
	function applySingleUnitStatusEffects(unit:Unit, triggerType:String):Void
	{
		if (unit == null)
			return;
		
		for (status in unit.statuses)
		{
			if (status.data.triggerType == triggerType)
			{
				eventManager.addEvent(function():Void
				{
					unit.doStatusEffectAnim(status.id, false);
				});
				applySkillEffects(unit, unit, status.data.effects);
				eventManager.addEvent(function():Void
				{
					status.changeTurns(-1);
				});
			}
		}
	}

	function applyGlobalStatusEffects(triggerType:String):Void
	{
		for (unit in units)
		{
			applySingleUnitStatusEffects(unit, triggerType);
		}
	}
	
	/**
	 * Call this to add the grid selector UI
	 */
	function addGridSelector():Void
	{
		menuManagerGridSelector.setMenuOptions(gridSelectorOptions);
		menuManagerGridSelector.enable();

		for (grid in grids)
		{
			for (space in grid.spaces)
			{
				if (gridSelectorSpaces.contains(space))
				{
					space.baseSprite.alpha = 1;
				}
				else
				{
					space.baseSprite.alpha = .2;
				}
			}
		}
		cameraTrackerType = GRID;

		executeScriptFunction("onAddGridSelector", []);
	}

	/**
	 * Call this to remove the grid selector UI
	 */
	function removeGridSelector():Void
	{
		for (grid in grids)
		{
			grid.updateFlashingSprites([]);
		}
		
		menuManagerGridSelector.disable();
		if (uiStatus == GRID_INSPECT || uiStatus == GRID_SKILL)
		{
			if (uiStatus == GRID_INSPECT)
			{
				bottomBar.updateCurrentUnit(currentTurnUnit);
				turnOrderDisplay.topBar.updateCurrentUnit(currentTurnUnit);
				turnOrderDisplay.updateCurrentTurn(currentTurnUnit);
				bottomBar.addMenu();
			}
			
			uiStatus = SELECTING_SKILLS;
			cameraTrackerType = UNIT;
			menuManagerPlayerUI.enable(false);
		}
		else if (uiStatus == GRID_PLACER_INSPECT)
		{
			bottomBar.updateCurrentUnit(null);

			cameraTrackerType = CENTERED;
			uiStatus = INACTIVE;

			turnOrderDisplay.visible = false;
			
			FlxTween.tween(bottomBar, {alpha: 0}, .6, {
				onComplete: function(f):Void
				{
					bottomBar.visible = false;

					gridUnitPlacer.activate();
				}
			});
		}
		for (grid in grids)
		{
			for (space in grid.spaces)
			{
				space.toggleFlashSprite(false);
				space.baseSprite.alpha = 1;
			}
		}
	}

	/**
	 * Call this to adjust what grid spaces will be in the grid selector
	 * @param type 
	 */
	function updateGridSelectorOptions(type:String = ""):Void
	{
		gridSelectorSpaces = getAvailableSpacesForSkillType(type, currentTurnUnit, grids);

		gridSelectorOptions = [];

		for (i in 0...Std.int(gridSize.y))
		{
			gridSelectorOptions.push([]);
		}

		for (space in gridSelectorSpaces)
		{
			gridSelectorOptions[Std.int(space.position.y)].push({
				sprite: space.baseSprite,
				cursorDirection: UP,
				clickFunction: function(sprite):Void
				{
					if (uiStatus == GRID_SKILL)
					{
						uiStatus = INACTIVE;
						cameraTrackerType = CENTERED;

						removeGridSelector();

						useSkill(currentTurnUnit.skills[menuManagerPlayerUI.curSelected - (disableInspectButton ? 0 : 1)], currentTurnUnit, space.grid,
							new FlxPoint(space.position.x, space.position.y), function():Void
						{
							endPlayerTurn();
						});
					} else if(uiStatus == GRID_INSPECT || uiStatus == GRID_PLACER_INSPECT){
						if(space.unit != null){
							menuManagerGridSelector.disable();

							menuManagerUnitInspector.setMenuOptions([getSkillIconMenuOptions()]);
							menuManagerUnitInspector.enable();

							bottomBar.descriptionText.visible = true;
							bottomBar.descriptionText.revive();
						}
					}
				},
				cancelFunction: function(sprite):Void
				{
					removeGridSelector();
				},
				hoverFunction: function(sprite):Void
				{
					currentSelectedGridSpace = sprite;
					
					if (uiStatus == GRID_SKILL)
					{
						space.grid.updateFlashingSprites(getAffectedSpacesForSkill(currentTurnUnit.skills[menuManagerPlayerUI.curSelected - (disableInspectButton ? 0 : 1)],
							currentTurnUnit, space.grid, new FlxPoint(space.position.x, space.position.y)));
					}
					else if (uiStatus == GRID_INSPECT || uiStatus == GRID_PLACER_INSPECT)
					{
						if(uiStatus == GRID_PLACER_INSPECT)
						{
							if(space.unit == null){
								turnOrderDisplay.visible = false;
							} else {
								turnOrderDisplay.visible = true;
							}
						}

						bottomBar.updateCurrentUnit(space.unit);
						turnOrderDisplay.topBar.updateCurrentUnit(space.unit);
						turnOrderDisplay.updateCurrentTurn(space.unit);
						space.toggleFlashSprite(true);
					}
				},
				nonHoverFunction: function(sprite):Void
				{
					if (uiStatus == GRID_INSPECT || uiStatus == GRID_PLACER_INSPECT)
					{
						space.toggleFlashSprite(false);
					}
				}
			});
		}
		var i = gridSelectorOptions.length;

		while (i-- > 0)
		{
			if (gridSelectorOptions[i].length <= 0)
			{
				gridSelectorOptions.splice(i, 1);
			}
		}
	}

	/**
	 * Call this to clear up damage texts that are off screen
	 */
	function removeUnusedDamageTexts():Void
	{
		var removeThese:Array<DamageText> = [];

		for (text in damageTexts.members)
		{
			if (text.y > FlxG.height)
			{
				removeThese.push(text);
			}
		}

		for (text in removeThese)
		{
			damageTexts.remove(text, true);
			text.destroy();
		}
	}

	/**
	 * Call this to start a dialogue box cutscene!!
	 * @param dialogues 
	 */
	function startDialogue(dialogues:Array<String>, ?onComplete:Void->Void):Void
	{
		dialogueBox.loadDialogueFiles(dialogues);
		dialogueBox.openBox();
		dialogueBox.playDialogue();
		onDialogueComplete = onComplete;
		dialogueBg.revive();
	}

	/**
	 * Call this when a dialogue is finished
	 */
	function endDialogues():Void
	{
		new FlxTimer().start(0.1, function(f):Void
		{
			dialogueBg.kill();
			if (onDialogueComplete != null)
				onDialogueComplete();
		});
	}
	
	function setUpScripts():Void
	{
		for (script in battleData.script)
		{
			addScript(Constants.battleScriptPath + script + ".hx");
		}
	}

	function addScript(path:String):CtScript
	{
		var script = new CtScript(path);

		if (script.script == null)
			return null;

		script.setValue({name: "allyGrid", value: allyGrid});
		script.setValue({name: "enemyGrid", value: enemyGrid});
		script.setValue({name: "grids", value: grids});

		script.setValue({name: "camUI", value: camUI});
		script.setValue({name: "camGame", value: camGame});
		script.setValue({name: "camDialogue", value: camDialogue});

		script.setValue({name: "goBackToOverworld", value: goBackToOverworld});
		
		script.setValue({name: "placeUnit", value: placeUnit});
		script.setValue({name: "getUnitByTag", value: getUnitByTag});

		script.setValue({name: "calculateTurnOrder", value: calculateTurnOrder});

		script.setValue({name: "startDialogue", value: startDialogue});

		script.setValue({name: "advanceTurn", value: advanceTurn});
		
		script.setValue({name: "menuManagerPlayerUI", value: menuManagerPlayerUI});
		script.setValue({name: "menuManagerGridSelector", value: menuManagerGridSelector});

		// get / set
		script.setValue({name: "get_disableEndTurnButton", value: get_disableEndTurnButton});
		script.setValue({name: "set_disableEndTurnButton", value: set_disableEndTurnButton});

		script.setValue({name: "get_disableInspectButton", value: get_disableInspectButton});
		script.setValue({name: "set_disableInspectButton", value: set_disableInspectButton});

		script.setValue({name: "get_dialogueBox", value: get_dialogueBox});
		script.setValue({name: "set_dialogueBox", value: set_dialogueBox});

		script.setValue({name: "get_bottomBar", value: get_bottomBar});
		script.setValue({name: "set_bottomBar", value: set_bottomBar});

		script.setValue({name: "get_turnOrderDisplay", value: get_turnOrderDisplay});
		script.setValue({name: "set_turnOrderDisplay", value: set_turnOrderDisplay});

		script.setValue({name: "get_bgLine", value: get_bgLine});
		script.setValue({name: "set_bgLine", value: set_bgLine});

		scripts.push(script);
		script.executeFunction("create");

		return script;
	}

	// disableEndTurnButton
	
	public function get_disableEndTurnButton():Bool
	{
		return disableEndTurnButton;
	}

	function set_disableEndTurnButton(val:Bool):Void
	{
		disableEndTurnButton = val;
	}

	// disableInspectButton
	
	public function get_disableInspectButton():Bool
	{
		return disableInspectButton;
	}

	function set_disableInspectButton(val:Bool):Void
	{
		disableInspectButton = val;
	}

	// dialogueBox
	
	public function get_dialogueBox():CtDialogueBox
	{
		return dialogueBox;
	}

	public function set_dialogueBox(val:CtDialogueBox):Void{
		dialogueBox = val;
	}

	// bottomBar
	
	public function get_bottomBar():BottomBar
	{
		return bottomBar;
	}

	public function set_bottomBar(val:BottomBar):Void{
		bottomBar = val;
	}
	
	// turnOrderDisplay
	
	public function get_turnOrderDisplay():TurnOrderDisplay
	{
		return turnOrderDisplay;
	}

	public function set_turnOrderDisplay(val:TurnOrderDisplay):Void{
		turnOrderDisplay = val;
	}

	// bgLine
	
	public function get_bgLine():CtSprite
	{
		return bgLine;
	}

	public function set_bgLine(val:CtSprite):Void{
		bgLine = val;
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
	
	public static function setBattle(name:String, type:BattleType):Void
	{
		battleName = name;
		battleType = type;
	}

	function doIntroAnim():Void
	{
		bottomBar.visible = false;
		turnOrderDisplay.visible = false;
		miniHealthBars.visible = false;
		statusEffectBars.visible = false;
		
		hideGrid(allyGrid);
		hideGrid(enemyGrid);

		if (battleType == STORY)
		{
			var spr = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.WHITE);
			spr.camera = camUI;
			add(spr);
			
			eventManager.addEvent(function():Void
			{
				eventManager.startTransaction("fadein");
				FlxTween.tween(spr, {alpha: 0}, 1, {
					onComplete: function(f):Void
					{
						spr.destroy();
						eventManager.finishTransaction("fadein");
					}
				});
			});
		}
		eventManager.addEvent(function():Void
		{
			eventManager.startTransaction("buildGrid");

			buildGrid(allyGrid, 1, FlxEase.quartIn, function():Void
			{
				buildGrid(enemyGrid, 1, FlxEase.quartOut, function():Void
				{
					eventManager.finishTransaction("buildGrid");
				});
			});
		});
		eventManager.addEvent(function():Void
		{
			doGridPlacer();
		});
	}

	function doGridPlacer():Void
	{
		if (battleData.disableUnitPlacer)
		{
			advanceRound(true);
			return;
		}
		
		gridUnitPlacer.inspectTrigger.add(function():Void
		{
			bottomBar.visible = true;
			bottomBar.alpha = 0;
			bottomBar.updateCurrentUnit(null);

			turnOrderDisplay.topBar.updateCurrentUnit(null);
			FlxTween.tween(bottomBar, {alpha: 1}, .3, {
				onComplete: function(f):Void
				{
					uiStatus = GRID_PLACER_INSPECT;

					addGridSelector();
				}
			});
		});
		gridUnitPlacer.activate(function(placedUnits):Void
		{
			if (placedUnits.length == 0)
			{
				advanceRound(true);
			}
			else
			{
				for (i in 0...placedUnits.length)
				{
					new FlxTimer().start(.2 * i, function(f):Void
					{
						var unitInfo = placedUnits[i];
						placeUnit(unitInfo.unit, allyGrid, FlxPoint.get(unitInfo.x, unitInfo.y), true, Save.levelUnits.get(unitInfo.unit).getLevel(), true, true);
					});

					if (i == placedUnits.length - 1)
					{ // done
						new FlxTimer().start(1, function(f):Void
						{
							advanceRound(true);
						});
					}
				}
			}
		});
	}

	function hideGrid(grid:Grid):Void
	{
		for (space in grid.spaces)
		{
			space.visible = false;
			if (space.unit != null)
				space.unit.visible = false;
		}
	}

	function buildGrid(grid:Grid, time:Float, ease:Float->Float, ?onComplete:Void->Void):Void
	{
		FlxTween.num(0, 1, time, {
			ease: ease,
			onComplete: function(f):Void
			{
				if (onComplete != null)
					onComplete();
			}
		}, function(f):Void
		{
			for (i in 0...grid.spaces.length)
			{
				var space = grid.spaces[i];

				if (f >= (i / grid.spaces.length) && !space.visible)
				{
					space.visible = true;
					if (space.unit != null)
					{
						space.unit.visible = true;
						space.unit.doEntranceAnimation();
					}

					CtSound.play(Constants.sfx_gridPlace).pitch = FlxG.random.float(.6, 1.4);
				}
			}
		});
	}
	
	#if debug
	function addDebugFunctions():Void
	{
		FlxG.console.registerFunction("advanceTurn", function()
		{
			advanceTurn(1);
		});
	}
	#end
}
