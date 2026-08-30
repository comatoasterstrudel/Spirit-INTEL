package save.saveloadmenu;

class SaveLoadMenuRow extends FlxSpriteGroup{
    var saveWindow:CtSprite;
    
    public var callIcon:CtSprite;
    
    var divider:CtSprite;
        
	var roomText:CtText;

	var saveID:Int;
    
	var confirmMenuManager:CtMenuManager;
	var cursor:Cursor;

	var confirmText:CtText;
	var confirmYes:CtText;
	var confirmNo:CtText;

	var baseSprites:FlxSpriteGroup;
	var confirmSprites:FlxSpriteGroup;
    
	public function new(saveWindow:CtSprite, y:Float, saveID:Int, addDivider:Bool, enabled:Bool):Void
	{
        super();
    
        this.saveWindow = saveWindow;
		this.saveID = saveID;
        
		var started = Save.isSaveStarted(saveID);
		var save = new FlxSave();
		save.bind(Constants.saveFileName + saveID);

		baseSprites = new FlxSpriteGroup();

		confirmSprites = new FlxSpriteGroup();
		confirmSprites.visible = false;
        
		callIcon = new CtSprite().createFromImage(started ? Constants.saveLoadMenuCallIconGraphicPath : Constants.saveLoadMenuCallIconNotStartedGraphicPath,
			.7);
        callIcon.setPosition(saveWindow.x + 30, y + 20);
        callIcon.antialiasing = false;
		baseSprites.add(callIcon);
        
        if(addDivider){
            divider = new CtSprite().createFromImage(Constants.saveLoadMenuDividerGraphicPath);
            CtUtil.centerSpriteOnSprite(divider, saveWindow, true, false);
            divider.y = y + 160;
            divider.antialiasing = false;
            add(divider);
		}     
		roomText = new CtText(10, 10, "sd", Constants.fontName, 35, false);
		baseSprites.add(roomText);

		if (!enabled)
		{
			callIcon.alpha = .4;
			roomText.alpha = .4;
		}
		initConfirmation();

		add(baseSprites);
		add(confirmSprites);
		updateRow();
		updateColor(FlxColor.BLACK);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		confirmMenuManager.update();
	}

	public function doConfirmation(text:String, yesFunc:Void->Void, noFunc:Void->Void):Void
	{
		confirmText.text = text;
		CtUtil.centerSpriteOnSprite(confirmText, saveWindow, true, false);
		CtUtil.centerSpriteOnSprite(confirmText, callIcon, false, true);
		confirmText.y -= 35;

		var menuOptions:Array<Array<CtMenuOption>> = [];

		menuOptions[0] = [
			{
				sprite: confirmYes,
				cursorDirection: DOWN,
				clickFunction: function(f):Void
				{
					closeConfirmation();
					new FlxTimer().start(0.01, function(f):Void
					{
						yesFunc();
					});
				},
				cancelFunction: function(f):Void
				{
					closeConfirmation();
					new FlxTimer().start(0.01, function(f):Void
					{
						noFunc();
					});
				}
			},
			{
				sprite: confirmNo,
				cursorDirection: DOWN,
				clickFunction: function(f):Void
				{
					closeConfirmation();
					new FlxTimer().start(0.01, function(f):Void
					{
						noFunc();
					});
				},
				cancelFunction: function(f):Void
				{
					closeConfirmation();
					new FlxTimer().start(0.01, function(f):Void
					{
						noFunc();
					});
				}
			}
		];
		confirmMenuManager.setMenuOptions(menuOptions);

		openConfirmation();
	}

	function openConfirmation():Void
	{
		baseSprites.visible = false;
		confirmSprites.visible = true;
		confirmMenuManager.enable(true);
	}

	function closeConfirmation():Void
	{
		baseSprites.visible = true;
		confirmSprites.visible = false;
		confirmMenuManager.disable();
	}

	function initConfirmation():Void
	{
		confirmText = new CtText(10, 10, "sd", Constants.fontName, 50, false);
		confirmText.color = FlxColor.BLACK;
		confirmSprites.add(confirmText);

		confirmYes = new CtText(10, 10, "Yes", Constants.fontName, 40, false);
		confirmYes.color = FlxColor.BLACK;
		confirmSprites.add(confirmYes);

		confirmNo = new CtText(10, 10, "No", Constants.fontName, 40, false);
		confirmNo.color = FlxColor.BLACK;
		confirmSprites.add(confirmNo);

		CtUtil.centerSpriteOnSprite(confirmYes, saveWindow, true, false);
		confirmYes.x -= 60;

		CtUtil.centerSpriteOnSprite(confirmNo, saveWindow, true, false);
		confirmNo.x += 60;

		CtUtil.centerSpriteOnSprite(confirmYes, callIcon, false, true);
		confirmYes.y += 40;

		CtUtil.centerSpriteOnSprite(confirmNo, callIcon, false, true);
		confirmNo.y += 40;

		confirmMenuManager = new CtMenuManager();
		cursor = new Cursor(Constants.cursorArrowGraphic);
		confirmSprites.add(confirmMenuManager.addCursor(cursor, 20, false));
	}
	public function updateRow():Void
	{
		var started = Save.isSaveStarted(saveID);
		var save = new FlxSave();
		save.bind(Constants.saveFileName + saveID);

		roomText.x = callIcon.x + callIcon.width + 20;
		roomText.color = FlxColor.BLACK;
		roomText.text = "File " + (saveID + 1);

		if (started)
		{
			var roomData = new RoomData(save.data.roomName);

			var roomName = roomData.displayName;
			var time = FlxStringUtil.formatTime(save.data.playtime, false);
			var level = CharacterLevel.getLevelFromExp(save.data.levelRobinExp);

			roomText.text += ("\n" + roomName + "\nLVL " + level + "\n" + time);
		}
		else
		{
			roomText.text += ("\n(Not Started)");
		}

		CtUtil.centerSpriteOnSprite(roomText, callIcon, false, true);
		roomText.y += 20;
	}

	public function updateColor(color:FlxColor):Void
	{
		for (spr in baseSprites.members)
		{
			spr.color = color;
		}
	}
}