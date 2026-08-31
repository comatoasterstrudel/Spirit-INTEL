package levelselector;

/**
 * The main menu of the game I guess
 * You can select levels here!!!!
 */
class LevelSelectorState extends FlxState
{	
	/**
	 * This is the list of room files that this menu is displaying
	 */
	var listOfRoomFiles:Array<RoomData> = [];
	
	/**
	 * This is the list of battle files that this menu is displaying
	 */
    var listOfBattleFiles:Array<BattleData> = [];
    
	var camUI:FlxCamera;
	
	/**
	 * The group of text objects for this menu
	 */
	var textOptions:FlxTypedGroup<CtText>;
    
	/**
	 * The menu manager for this menu
	 */
    var menuManager:CtMenuManager;

	/**
	 * The cursor for the menu
	 */
	var cursor:Cursor;

	/**
	 * The last value that was selected
	 */
	public static var savedCurSelected:Int = 0;

    override function create():Void{
		if(FlxG.sound.music != null){
			FlxG.sound.music.stop();
			FlxG.sound.music.destroy();
			FlxG.sound.music = null;
		}

		OverworldState.resetGlobalVars();
		
        bgColor = FlxColor.WHITE;
        
		setUpCameras();
		
        setUpMenu();
                
        populateMenuOptions();
        
        super.create();
    }
    
    override function update(elapsed:Float):Void{
        if(FlxG.keys.justPressed.R){
			updateSavedCurSelected();
            populateMenuOptions();
        }
        
        menuManager.update();
        
		camUI.focusOn(new FlxPoint(FlxG.width / 2, cursor.y + cursor.height / 2));
		
        super.update(elapsed);
    }

	function setUpCameras():Void
	{
		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);
	}
	
	/**
	 * Call this to set up the MenuManager. in a seperate function for tidiness
	 */
	function setUpMenu():Void
	{	
		menuManager = new CtMenuManager();
		cursor = new Cursor(Constants.cursorArrowGraphic);
		cursor.camera = camUI;
		add(menuManager.addCursor(cursor, 20, false));

		textOptions = new FlxTypedGroup<CtText>();
		textOptions.camera = camUI;
		add(textOptions);
    }
    
	/**
	 * Call this to reset and populate the menu options!! Can be reloaded at runtime
	 */
    function populateMenuOptions():Void{
		menuManager.disable();
		
		listOfRoomFiles = [];

		for (room in CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.roomDataFolder, [".json"], false, false), ["room_", ".json"]))
		{
			listOfRoomFiles.push(new RoomData(room));
		}
		
        listOfBattleFiles = [];
        
        for(battle in CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.battleDataFolder, [".json"], false, false), ["battle_", ".json"])){
            listOfBattleFiles.push(new BattleData(battle));
        }

		clearMenuOptions();
		
        var menuOptions:Array<Array<CtMenuOption>> = [];
        
		if (listOfRoomFiles.length == 0 && listOfBattleFiles.length == 0)
		{
			var text = new CtText(Constants.levelSelectTextXPos, Constants.levelSelectTextYPos, Constants.levelSelectNoLevelMessage);
			text.color = FlxColor.GRAY;
			text.size = Constants.levelSelectTextSize;
			textOptions.add(text);

			menuOptions.push([{sprite: text, cursorDirection: LEFT}]);
		}
		else
		{
			for (i in 0...listOfRoomFiles.length)
			{
				var room = listOfRoomFiles[i];

				var text = new CtText(Constants.levelSelectTextXPos, Constants.levelSelectTextYPos + (Constants.levelSelectTextYSpacing * textOptions.length),
					"ROOM: " + room.id);
				text.font = Constants.fontName;
				text.color = FlxColor.BLACK;
				text.size = Constants.levelSelectTextSize;
				textOptions.add(text);

				menuOptions.push([
					{
						sprite: text,
						cursorDirection: LEFT,
						clickFunction: function(sprite):Void
						{
							updateSavedCurSelected();

							OverworldState.roomName = room.id;
							FlxG.switchState(OverworldState.new);
						},
						cancelFunction: function(spr):Void{
							FlxG.switchState(MainMenuState.new);
						}
					}
				]);
			}  
			
			for (i in 0...listOfBattleFiles.length)
			{
				var battle = listOfBattleFiles[i];

				var text = new CtText(Constants.levelSelectTextXPos, Constants.levelSelectTextYPos + (Constants.levelSelectTextYSpacing * textOptions.length),
					"BATTLE: " + battle.id);
				text.font = Constants.fontName;
				text.color = FlxColor.BLACK;
				text.size = Constants.levelSelectTextSize;
				textOptions.add(text);

				menuOptions.push([
					{
						sprite: text,
						cursorDirection: LEFT,
						clickFunction: function(sprite):Void
						{
							updateSavedCurSelected();

							PlayState.setBattle(battle.id, ARCADE);
							FlxG.switchState(PlayState.new);
						}
					}
				]);
			}   
        }
        
        menuManager.setMenuOptions(menuOptions);
		menuManager.curRack = savedCurSelected;
		new FlxTimer().start(0.05, function(f):Void
		{
			menuManager.enable();
		});
    }
	function clearMenuOptions():Void
	{
		var destroyThese:Array<CtText> = [];

		for (text in textOptions.members)
		{
			destroyThese.push(text);
		}

		textOptions.clear();

		for (i in destroyThese)
		{
			i.destroy();
		}
	}
	
	/**
	 * Call this to set savedCurSelected to menuManger.curRack
	 */
	function updateSavedCurSelected():Void
	{
		savedCurSelected = menuManager.curRack;
	}
}