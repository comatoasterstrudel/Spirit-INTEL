package save.saveloadmenu;

class SaveLoadMenu extends FlxSubState
{
    var camUI:FlxCamera;
    var camFade:FlxCamera;
    
    var bg:CtSprite;
    var saveWindow:CtSprite;
    
	var bgName:String;
	
    var rows:Array<SaveLoadMenuRow> = [];
    var saveWindowArrow:CtSprite;
    
    var topText:CtText;
    
    var type:SaveLoadMenuType;
    
    var menuManager:CtMenuManager;
    var cursor:Cursor;
    
	var allowedSaves:SaveLoadMenuAllowedSavesType;

	var onComplete:Void->Void;
	var onExit:Void->Void;
    
	var confirmSprites:FlxSpriteGroup;
	var confirmBg:CtSprite;
	var confirmText:CtText;
	var confirmYes:CtText;
	var confirmNo:CtText;
	var confirmMenuManager:CtMenuManager;
	var confirmCursor:Cursor;
	
	public function new(type:SaveLoadMenuType, bgName:String, ?onComplete:Void->Void, ?onExit:Void->Void):Void
	{
        super();
        
        this.type = type;
		this.bgName = bgName;
		this.onComplete = onComplete;
		this.onExit = onExit;

		allowedSaves = switch (type)
		{
			case NEWGAME: NOTSTARTED;
			case CONTINUE | CONTINUEDEBUG: STARTED;
			case ERASE: STARTED;
			case SAVE: ANY;
		};
        
        setupCameras();        
                
        setUpMenu();

        doTransition(function():Void{
            setupUI();
			setUpConfirm();
        }, function():Void{
            menuManager.enable();
        });

    }
    
    override function update(elapsed:Float):Void{
        super.update(elapsed);
        
		menuManager.update();  
		if (confirmMenuManager != null)
			confirmMenuManager.update();        
    }
    
    /**
	 * Call this to set up the MenuManager. in a seperate function for tidiness
	 */
	function setUpMenu():Void
	{
		menuManager = new CtMenuManager(CtControls.getInputFunction("right", JUSTPRESSED), CtControls.getInputFunction("left", JUSTPRESSED),
			CtControls.getInputFunction("accept", JUSTPRESSED), CtControls.getInputFunction("cancel", JUSTPRESSED),
			CtControls.getInputFunction("down", JUSTPRESSED), CtControls.getInputFunction("up", JUSTPRESSED));
		cursor = new Cursor(Constants.cursorArrowGraphic);
        cursor.camera = camUI;
	}

    function setupCameras():Void{
        camUI = new FlxCamera();
        camUI.bgColor.alpha = 0;
        FlxG.cameras.add(camUI, false);
        
        camFade = new FlxCamera();
        camFade.bgColor.alpha = 0;
        FlxG.cameras.add(camFade, false);
    }
    
    function setupUI():Void{
		bg = new CtSprite().createFromImage(Constants.saveLoadMenuBgGraphicPath + bgName + ".png");
		bg.screenCenter();
		bg.antialiasing = false;
        bg.camera = camUI;
        add(bg);
        
        saveWindow = new CtSprite().createFromImage(Constants.saveLoadMenuSaveWindowGraphicPath);
        saveWindow.camera = camUI;
        saveWindow.screenCenter(Y);
        saveWindow.x = FlxG.width - saveWindow.width;
        saveWindow.antialiasing = false;
        add(saveWindow);   
        
		saveWindowArrow = new CtSprite(saveWindow.x + 30, 40).createFromImage(Constants.saveLoadMenuSaveWindowArrowGraphicPath);
        saveWindowArrow.camera = camUI;
        saveWindowArrow.antialiasing = false;
        add(saveWindowArrow);
        
		topText = new CtText(saveWindow.x + 430, saveWindow.y + 70, "", Constants.fontName, 30);
        topText.color = FlxColor.BLACK;
        topText.text = switch(type){
            case NEWGAME: "//  NEW";
            case CONTINUE | CONTINUEDEBUG: "//  CONTINUE";
            case ERASE: "//  ERASE";
            case SAVE: "//  SAVE";
        };
        topText.camera = camUI;
        add(topText);
        
        var menuOptions:Array<Array<CtMenuOption>> = [];
        var startNum:Int = 0;
        
		if (type == SAVE)
		{
			menuOptions.push([
				{
					sprite: saveWindowArrow,
					cursorDirection: LEFT,
					cancelFunction: exit,
					clickFunction: function(f):Void
					{
						menuManager.disable();

						addConfirm();
					}
				}
			]);
			startNum = Save.loadedSaveSlot + 1;
        } else {
			saveWindowArrow.alpha = .4;
        }
        
        var baseY:Float = saveWindow.y + 150;
        
        for(i in 0...Constants.maxSaveFiles + 1){
			var allowed:Bool = false;

			switch (allowedSaves)
			{
				case STARTED:
					allowed = Save.isSaveStarted(i);
				case NOTSTARTED:
					allowed = !Save.isSaveStarted(i);
				case ANY:
					allowed = true;
			}

			var row = new SaveLoadMenuRow(saveWindow, baseY + (190 * i), i, (i != Constants.maxSaveFiles), allowed);
            row.camera = camUI;
            rows.push(row);
            add(row);    
            
			menuOptions.push([
				{
					sprite: row.callIcon,
					cursorDirection: LEFT,
					cancelFunction: exit,
					clickFunction: function(f):Void
					{
						if (allowed)
						{
							menuManager.disable();

							switch (type)
							{
								case NEWGAME:
									startSave(i);
								case CONTINUE | CONTINUEDEBUG:
									continueSave(i);
								case ERASE:
									row.doConfirmation("Erase File " + (i + 1) + "?", function():Void
									{
										eraseSave(i);
									}, function():Void
									{
										menuManager.enable();
									});
								case SAVE:
									if (Save.isSaveStarted(i))
									{
										row.doConfirmation("Overwrite File " + (i + 1) + "?", function():Void
										{
											save(i);
										}, function():Void
										{
											menuManager.enable();
										});
									}
									else
									{
										save(i);
									}
							}
						}
					}
				}
			]);
        }
        
        add(menuManager.addCursor(cursor, 50, false));
        menuManager.setMenuOptions(menuOptions);
        menuManager.curRack = startNum;
    }
	function setUpConfirm():Void
	{
		confirmSprites = new FlxSpriteGroup();
		confirmSprites.camera = camUI;
		confirmSprites.visible = false;
		add(confirmSprites);

		confirmBg = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.BLACK);
		confirmBg.alpha = .9;
		confirmSprites.add(confirmBg);

		confirmText = new CtText(10, 10, "Return to the Main Menu?", Constants.fontName, 65, false);
		confirmText.screenCenter();
		confirmSprites.add(confirmText);

		confirmYes = new CtText(10, 10, "Yes", Constants.fontName, 55, false);
		confirmYes.screenCenter();
		confirmYes.setPosition(confirmYes.x - 200, confirmYes.y + 300);
		confirmSprites.add(confirmYes);

		confirmNo = new CtText(10, 10, "No", Constants.fontName, 55, false);
		confirmNo.screenCenter();
		confirmNo.setPosition(confirmNo.x + 200, confirmNo.y + 300);
		confirmSprites.add(confirmNo);

		for (spr in [confirmText, confirmYes, confirmNo])
		{
			spr.y -= 100;
		}

		confirmMenuManager = new CtMenuManager(CtControls.getInputFunction("right", JUSTPRESSED), CtControls.getInputFunction("left", JUSTPRESSED),
			CtControls.getInputFunction("accept", JUSTPRESSED), CtControls.getInputFunction("cancel", JUSTPRESSED),
			CtControls.getInputFunction("down", JUSTPRESSED), CtControls.getInputFunction("up", JUSTPRESSED));
		confirmCursor = new Cursor(Constants.cursorArrowGraphic);

		confirmSprites.add(confirmMenuManager.addCursor(confirmCursor, 20, false));

		confirmMenuManager.setMenuOptions([
			[
				{
					sprite: confirmYes,
					cursorDirection: DOWN,
					clickFunction: function(F):Void
					{
						removeConfirm();
						doTransition(function():Void
						{
							FlxG.switchState(MainMenuState.new);
						});
					},
					cancelFunction: function(f):Void
					{
						removeConfirm();
						new FlxTimer().start(0.01, function(f):Void
						{
							menuManager.enable();
						});
					}
				},
				{
					sprite: confirmNo,
					cursorDirection: DOWN,
					clickFunction: function(F):Void
					{
						removeConfirm();
						new FlxTimer().start(0.01, function(f):Void
						{
							menuManager.enable();
						});
					},
					cancelFunction: function(f):Void
					{
						removeConfirm();
						new FlxTimer().start(0.01, function(f):Void
						{
							menuManager.enable();
						});
					}
				}
			]
		]);
	}

	function addConfirm():Void
	{
		confirmSprites.visible = true;
		new FlxTimer().start(0.1, function(f):Void
		{
			confirmMenuManager.enable(true);
			confirmMenuManager.curSelected = 1;
			confirmMenuManager.changeSelection();
		});
	}

	function removeConfirm():Void
	{
		confirmSprites.visible = false;
		confirmMenuManager.disable();
	}

	function exit(spr:FlxSprite):Void
	{
		menuManager.disable();

		doTransition(function():Void
		{
			camUI.visible = false;
		}, function():Void
		{
			if (onExit != null)
			{
				onExit();
			}
			close();
		});
	}
    
    function doTransition(?step1:Void->Void, ?step2:Void->Void):Void{
        var tranSpr = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.BLACK);
        tranSpr.camera = camFade;
        tranSpr.alpha = 0;
        add(tranSpr);
        
        FlxTween.tween(tranSpr, {alpha: 1}, .25, {onComplete: function(f):Void{
            if(step1 != null) step1();
            
                FlxTween.tween(tranSpr, {alpha: 0}, .25, {onComplete: function(f):Void{
                    tranSpr.destroy();
                    if(step2 != null) step2();
                }});
        }});
    }
	function startSave(slot:Int):Void
	{
		doTransition(function():Void
		{
			Save.load(slot);
			OverworldState.roomName = Constants.startingRoom;
			FlxG.switchState(OverworldState.new);
			if (onComplete != null)
				onComplete();
		});
	}

	function continueSave(slot:Int):Void
	{
		doTransition(function():Void
		{
			Save.load(slot);

			if(type == CONTINUEDEBUG){
				FlxG.switchState(LevelSelectorState.new);
			} else {
				OverworldState.startAtSavePoint = true;
				FlxG.switchState(OverworldState.new);
			}

			if (onComplete != null)
				onComplete();
		});
	}

	function eraseSave(slot:Int):Void
	{
		rows[slot].updateColor(FlxColor.RED);

		new FlxTimer().start(1, function(f):Void
		{
			
			var save = new FlxSave();
			save.bind(Constants.saveFileName + slot);
			save.erase();
			if (onComplete != null)
				onComplete();
			close();
		});	
	}

	function save(slot:Int):Void
	{
		Save.save(slot);

		rows[slot].updateRow();
		rows[slot].updateColor(FlxColor.BLUE);

		new FlxTimer().start(1, function(f):Void
		{
			doTransition(function():Void
			{
				camUI.visible = false;
			}, function():Void
			{
				onComplete();
				close();
			});
		});
	}
}