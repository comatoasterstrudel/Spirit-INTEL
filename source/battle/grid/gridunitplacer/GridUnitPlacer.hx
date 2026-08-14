package battle.grid.gridunitplacer;

class GridUnitPlacer extends FlxSpriteGroup
{
    var bg:CtSprite;    
    var uiBg:CtSprite;
	var uiBgAnim:GridUnitPlacerUiBg;
    var uiBgLeftEdge:CtSprite;
    var uiBgRightEdge:CtSprite;

	var robin:GridUnitPlacerRobin;
    
    var unitIcons:FlxSpriteGroup;
    var unitIconArray:Array<GridUnitPlacerUnitIcon> = [];
    
    var allyGrid:Grid;
    var enemyGrid:Grid;

    var selectingMenuManager:CtMenuManager;
    var selectingCursor:Cursor;
    
	var topButtons:Array<CtSprite> = [];

	var bottom:GridUnitPlacerBottom;
    
    var placingMenuManager:CtMenuManager;
    var placingCursor:Cursor;
    var placingUnitCursor:GridUnitPlacerCursor;
    
    var currentPlacingUnit:String = "";

    var status:GridUnitPlacerStatus = SELECTING;
    
    var cursorCamera:CtCamera;
    
    var placedUnits:Array<GridUnitPlacerInfo> = [];
    
    var ghostUnits:Array<GridUnitPlacerGhostUnit> = [];
    var ghostUnitSprites:FlxSpriteGroup;
    
    var onComplete:Array<GridUnitPlacerInfo>->Void;
    
	var startedBefore:Bool = false;
    
	public var inspectTrigger:FlxSignal = new FlxSignal();
    
	var reuseEnabled:Bool = false;
    
    public function new(allyGrid:Grid, enemyGrid:Grid):Void{
        super();
        
        this.allyGrid = allyGrid;
        this.enemyGrid = enemyGrid;

		reuseEnabled = (Save.savedUnitPlacements != null && Save.savedUnitPlacements != [] && Save.savedUnitPlacements.length > 0);
        
        cursorCamera = new CtCamera();
        cursorCamera.bgColor.alpha = 0;
        FlxG.cameras.add(cursorCamera, false);
        
        bg = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;
		bg.scrollFactor.set(0, 0);
        add(bg);  
        
		robin = new GridUnitPlacerRobin();
		robin.alpha = 0;
		add(robin);
        
        uiBg = new CtSprite().createColorBlock(Std.int(Constants.gridUnitPlacerBgWidth), FlxG.height, FlxColor.WHITE);
        uiBg.setPosition(enemyGrid.spaces[0].baseSprite.x + (Grid.calculateGridSize(new FlxPoint(enemyGrid.size.x, enemyGrid.size.y)).x / 2) - uiBg.width / 2, 0);
        uiBg.alpha = 0;
		uiBgAnim = new GridUnitPlacerUiBg(uiBg);
		add(uiBgAnim);
        
        uiBgLeftEdge = new CtSprite().createFromImage(Constants.gridUnitPlacerLeftEdge);
        uiBgLeftEdge.antialiasing = false;
        uiBgLeftEdge.x = uiBg.x - uiBgLeftEdge.width;
        uiBgLeftEdge.alpha = 0;
        add(uiBgLeftEdge);

        uiBgRightEdge = new CtSprite().createFromImage(Constants.gridUnitPlacerLeftEdge);
        uiBgRightEdge.antialiasing = false;
        uiBgRightEdge.x = uiBg.x + uiBg.width;
        uiBgRightEdge.alpha = 0;
        uiBgRightEdge.flipX = true;
        add(uiBgRightEdge);


        add(uiBg);
        
        bottom = new GridUnitPlacerBottom(uiBg);
        add(bottom);
        
		addUnitIcons();  

        initSelectingMenu();
        initPlacingMenu();
    }
    
    override function update(elapsed:Float):Void{
        super.update(elapsed);
        
        selectingMenuManager.update();
        placingMenuManager.update();
    }
    
    function addUnitIcons():Void{
        unitIcons = new FlxSpriteGroup();
        unitIcons.alpha = 0;
        add(unitIcons);
        
		var listOfUnits:Array<String> = Unit.getListOfUnlockedUnits();
        
        var xPos:Int = 0;
        var yPos:Int = 0;
        
        for(i in 0...listOfUnits.length){
            var unitName:String = listOfUnits[i];
            
            var unitIcon = new GridUnitPlacerUnitIcon(unitName, uiBg.x + (xPos * Constants.gridUnitPlacerUnitIconSize) + (Constants.gridUnitPlacerUnitIconSpacing * (xPos + 1)), 200 + (yPos * Constants.gridUnitPlacerUnitIconSize) + (Constants.gridUnitPlacerUnitIconSpacing * (yPos + 1)), xPos, yPos);
            unitIcons.add(unitIcon);
            
            unitIconArray.push(unitIcon);
            
            xPos ++;
            if(xPos >= Constants.gridUnitPlacerUnitsPerRow){
                xPos = 0;
                yPos ++;
            }
        }
    }
    
    function initSelectingMenu():Void{
        selectingMenuManager = new CtMenuManager(CtControls.getInputFunction("right", JUSTPRESSED), CtControls.getInputFunction("left", JUSTPRESSED),
			CtControls.getInputFunction("accept", JUSTPRESSED), CtControls.getInputFunction("cancel", JUSTPRESSED),
			CtControls.getInputFunction("down", JUSTPRESSED), CtControls.getInputFunction("up", JUSTPRESSED));
            
        selectingCursor = new Cursor(Constants.cursorArrowGraphic);
        add(selectingCursor);
        
        selectingMenuManager.addCursor(selectingCursor, 30);
        
		var menuOptions:Array<Array<CtMenuOption>> = [[]];
        
		var xPos:Int = 0;

		for (buttonName in ["finish", "inspect", "reuse"])
		{
			var button = new CtSprite().createFromImage((buttonName == "reuse" && !reuseEnabled) ? Constants.gridUnitPlacerButtonPath
				+ buttonName
				+ "_locked.png" : Constants.gridUnitPlacerButtonPath
				+ buttonName
				+ ".png");

			button.y = 20;
			button.alpha = 0;
			button.antialiasing = false;
			add(button);

			topButtons.push(button);

			menuOptions[0].push({
				sprite: button,
				cursorDirection: DOWN,
				hoverFunction: function(f):Void
				{
					switch (buttonName)
					{
						case "finish":
                            bottom.updateWithText("Start battle", "finish");
						case "inspect":
							bottom.updateWithText("View the board", "inspect");
						case "reuse":
							if (reuseEnabled)
								bottom.updateWithText("Use last formation", "reuse");
							else
								bottom.updateWithText("No formation found", "badreuse");
					}
				},
				clickFunction: function(f):Void
				{
					switch (buttonName)
					{
						case "finish":
							selectingMenuManager.disable();
							deactivate();    
						case "inspect":
							selectingMenuManager.disable();
							deactivate(function():Void
							{
								inspectTrigger.dispatch();
							});
						case "reuse":
							if (reuseEnabled)
							{
								resetPlacedUnits();

								for (i in Save.savedUnitPlacements)
								{
									placeUnit(Grid.getGridSpaceFromGrid(allyGrid, FlxPoint.get(i.x, i.y)), i.unit);
								}
							}
					}
				}
			});

			xPos++;
		}

		CtUtil.centerGroup(cast topButtons, Constants.gridUnitPlacerUnitIconSpacing, uiBg.x + uiBg.width / 2);
        
        for(i in unitIconArray){
            if(menuOptions[i.yPos + 1] == null){
                menuOptions[i.yPos + 1] = [];
            }
            menuOptions[i.yPos + 1].push({sprite: i.bg, cursorDirection: UP, hoverFunction: function(f):Void{
                i.updateSelected(true);
                bottom.updateWithUnit(i.unit, i.placed, true);
            }, nonHoverFunction: function(f):Void{
                i.updateSelected(false);
            }, clickFunction: function(f):Void{
                if(i.placed){
                    removePlacedUnit(i.unit);
						selectingMenuManager.changeSelection();
                } else {
                    startPlacing(i.unit);
                }
            }});
        }
                
        selectingMenuManager.setMenuOptions(menuOptions, true);
    }
    
    function initPlacingMenu():Void{
        placingMenuManager = new CtMenuManager(CtControls.getInputFunction("right", JUSTPRESSED), CtControls.getInputFunction("left", JUSTPRESSED),
			CtControls.getInputFunction("accept", JUSTPRESSED), CtControls.getInputFunction("cancel", JUSTPRESSED),
			CtControls.getInputFunction("down", JUSTPRESSED), CtControls.getInputFunction("up", JUSTPRESSED));
            
        ghostUnitSprites = new FlxSpriteGroup();
        add(ghostUnitSprites);
        
        placingCursor = new Cursor(Constants.cursorArrowGraphic);
        add(placingCursor);
        
        placingMenuManager.addCursor(placingCursor, 30);
        
        placingUnitCursor = new GridUnitPlacerCursor(placingCursor);
        placingUnitCursor.visible = false;
        add(placingUnitCursor);
        
        new FlxTimer().start(0.1, function(f):Void{
            ghostUnitSprites.camera = cursorCamera;
            placingCursor.camera = cursorCamera;
            placingUnitCursor.camera = cursorCamera;
        });
        
        var gridSelectorSpaces:Array<GridSpace> = [];

        var menuOptions:Array<Array<CtMenuOption>> = [];
        
        for (space in allyGrid.spaces)
        {
            gridSelectorSpaces.push(space);
        }

		for (i in 0...Std.int(allyGrid.size.y))
		{
			menuOptions.push([]);
		}

		for (space in gridSelectorSpaces)
		{
			menuOptions[Std.int(space.position.y)].push({sprite: space.baseSprite, cursorDirection: UP, hoverFunction: function(f):Void{
                space.toggleFlashSprite(canPlaceOnSpace(space) ? true : false);
            }, nonHoverFunction: function(f):Void{
                space.toggleFlashSprite(false);
            }, cancelFunction: function(f):Void{
                endPlacing();
            }, clickFunction: function(f):Void{
                if(canPlaceOnSpace(space)){
                    placeUnit(space, currentPlacingUnit);
                }
            }});
        }
        
        placingMenuManager.setMenuOptions(menuOptions);
    }
    
    function hideGridSpaces():Void{
        for (space in allyGrid.spaces)
        {
            if(canPlaceOnSpace(space)) {
                space.baseSprite.alpha = 1;
            } else {
                space.baseSprite.alpha = .5;
            }
        } 
    }
    
    function showGridSpaces():Void{
        for (space in allyGrid.spaces)
        {
            space.baseSprite.alpha = 1;
            space.toggleFlashSprite(false);
        } 
    }
    
    function canPlaceOnSpace(space:GridSpace):Bool{
        var notPlacedOnYet = true;
        
        for(i in placedUnits){
            if(space.position.x == i.x && space.position.y == i.y){
                notPlacedOnYet = false;
            }
        }
        
        return(space.unit == null && notPlacedOnYet);
    }
    
    function startPlacing(unit:String):Void{
        status = PLACING;
        hideGridSpaces();
        placingUnitCursor.updateUnit(unit);
        currentPlacingUnit = unit;
        
        selectingMenuManager.disable();
        
        new FlxTimer().start(0.0001, function(f):Void{
            placingUnitCursor.visible = true;
            placingMenuManager.enable();            
        });
    }
    
    function endPlacing():Void{
        status = SELECTING;
        showGridSpaces();
        placingUnitCursor.visible = false;
        
        placingMenuManager.disable();
        
        new FlxTimer().start(0.0001, function(f):Void{
            selectingMenuManager.enable();            
        });
    }
    
    function placeUnit(space:GridSpace, unit:String):Void{
		if (!canPlaceOnSpace(space))
			return;

		if (status == PLACING)
			endPlacing();
        
        placedUnits.push({unit: unit, x: Std.int(space.position.x), y: Std.int(space.position.y)});
        
        updatePlacedIcons();
        
        var ghost = new GridUnitPlacerGhostUnit(unit, space);
        ghostUnitSprites.add(ghost);
        
        ghostUnits.push(ghost);
    }
    
    function removePlacedUnit(unit:String):Void{
        for(i in placedUnits){
            if(i.unit == unit){
                placedUnits.remove(i);
                break;
            }
        }
        for(i in ghostUnits){
            if(i.unit == unit){
                ghostUnits.remove(i);
                i.destroy();
                break;
            }
        }
        updatePlacedIcons();
    }
    
	function resetPlacedUnits():Void
	{
		for (unit in Unit.getListOfUnits())
		{
			removePlacedUnit(unit);
		}
	}
    
    function updatePlacedIcons():Void{
        for(i in unitIconArray){
            i.updatePlaced(false);
            
            for(unit in placedUnits){
                if(i.unit == unit.unit){
                    i.updatePlaced(true);
                }
            }
        }
    }

	public function activate(?onComplete:Array<GridUnitPlacerInfo>->Void):Void
	{
		if (onComplete != null)
			this.onComplete = onComplete;
        
        FlxTween.tween(bg, {alpha: .85}, 0.5);
        
		FlxTween.tween(robin, {alpha: 1}, 0.5);
		robin.doAnim();

		FlxTween.tween(uiBg, {alpha: 1}, 0.5);
		FlxTween.tween(uiBgLeftEdge, {alpha: 1}, 0.5);
		FlxTween.tween(uiBgRightEdge, {alpha: 1}, 0.5);

		FlxTween.tween(uiBgAnim, {alpha: 1}, 0.5, {
			onComplete: function(f):Void
			{
				uiBgAnim.visible = true;
			}
		}); 
        
        FlxTween.tween(unitIcons, {alpha: 1}, 0.5); 

		FlxTween.tween(ghostUnitSprites, {alpha: .33}, 0.5); 

		for (button in topButtons)
		{
			FlxTween.tween(button, {alpha: 1}, 0.5);
		}

        bottom.doFadeIn();
        
        new FlxTimer().start(0.5, function(f):Void{
			if (!startedBefore)
			{
				startedBefore = true;
				selectingMenuManager.curRack = 1;
			}
            selectingMenuManager.enable(false);
        });
    }
    
	public function deactivate(?newOnComplete:Void->Void):Void
	{
        FlxTween.tween(bg, {alpha: 0}, 0.5);
        
		FlxTween.tween(robin, {alpha: 0}, 0.5);

        FlxTween.tween(uiBg, {alpha: 0}, 0.5); 
        FlxTween.tween(uiBgLeftEdge, {alpha: 0}, 0.5);
		FlxTween.tween(uiBgRightEdge, {alpha: 0}, 0.5);

        FlxTween.tween(unitIcons, {alpha: 0}, 0.5); 

        FlxTween.tween(ghostUnitSprites, {alpha: 0}, 0.5); 

		bottom.doFadeOut();

		FlxTween.tween(uiBgAnim, {alpha: 0}, 0.5, {
			onComplete: function(F):Void
			{
				uiBgAnim.visible = false;
			}
		});

		for (button in topButtons)
		{
			FlxTween.tween(button, {alpha: 0}, 0.5);
		}

        new FlxTimer().start(0.5, function(f):Void{
			if (newOnComplete != null)
			{
				newOnComplete();
			}
			else
			{
				Save.savedUnitPlacements = placedUnits;
				onComplete(placedUnits);
				destroy();   
			}
        });
    }
}