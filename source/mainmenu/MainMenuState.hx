package mainmenu;

class MainMenuState extends FlxState
{
	var texts:FlxTypedGroup<CtText>;

	var menuManager:CtMenuManager;
	var cursor:Cursor;
	var menuOptions:Array<Array<CtMenuOption>> = [];

	var bg:CtSprite;
	var logo:CtSprite;
    
    override function create():Void{
        super.create();
        
		bg = new CtSprite().createFromImage(Constants.mainMainBgPath);
		bg.screenCenter();
		bg.antialiasing = false;
		add(bg);
		
		setUpMenu();

		addTexts(Constants.mainMenuIntroTime);

		logo = new CtSprite(30, 40).createFromImage(Constants.mainMenuLogoPath);
		logo.antialiasing = false;
		add(logo);
		doIntroAnim();
    }
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		menuManager.update();
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
		add(menuManager.addCursor(cursor, 20, false));

		texts = new FlxTypedGroup<CtText>();
		add(texts);
	}

	function addTexts(delay:Float = 0):Void
	{
		clearMenuOptions();

		addOption("New File", function():Void
		{
			menuManager.disable();

			openSubState(new SaveLoadMenu(NEWGAME, "mainmenu", null, function():Void
			{
				menuManager.enable();
			}));
		});

		var allowContinue:Bool = Save.isAnySaveStarted();

		var continueText:CtText = addOption("Continue", function():Void
		{
			if (allowContinue)
			{
				menuManager.disable();

				openSubState(new SaveLoadMenu(CONTINUE, "mainmenu", null, function():Void
				{
					menuManager.enable();
				}));
			}
			else
			{
				//
			}
		});

		var eraseText:CtText = addOption("Erase File", function():Void
		{
			if (allowContinue)
			{
				menuManager.disable();

				openSubState(new SaveLoadMenu(ERASE, "mainmenu", function():Void
				{
					FlxG.camera.shake(0.05, 0.1, null, true, X);
					addTexts();
					menuManager.enable();
				}, function():Void
				{
					menuManager.enable();
				}));
			}
			else
			{
				//
			}
		});

		if (!allowContinue)
		{
			continueText.alpha = .25;
			eraseText.alpha = .25;
		}

		addOption("Quit", function():Void
		{
			Sys.exit(1);
		});

		menuManager.setMenuOptions(menuOptions);

		new FlxTimer().start(delay, function(f):Void
		{
			menuManager.enable();
		});
	}

	function addOption(text:String, onClick:Void->Void):CtText
	{
		var text = new CtText(110, Constants.mainMenuStartingY + (80 * texts.members.length), text, Constants.fontName, 60);
		text.antialiasing = false;
		texts.add(text);

		menuOptions.push([
			{
				sprite: text,
				clickFunction: function(f):Void
				{
					onClick();
				},
				cursorDirection: LEFT
			}
		]);
		return text;
	}

	function clearMenuOptions():Void
	{
		var destroyThese:Array<CtText> = [];

		for (text in texts.members)
		{
			destroyThese.push(text);
		}

		texts.clear();

		for (i in destroyThese)
		{
			i.destroy();
		}

		menuOptions = [];
		menuManager.disable();
	}
	function doIntroAnim():Void
	{
		var black = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(black);

		FlxTween.tween(black, {alpha: 0}, Constants.mainMenuIntroTime, {
			onComplete: function(f):Void
			{
				black.destroy();
			}
		});
	}
}