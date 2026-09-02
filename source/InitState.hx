package;

import ctDialogueBox.ctdb.namebox.NameBoxFollowType;

class InitState extends FlxState{
	public static var init_forceCutscene:String = "";

    override function create():Void{
        super.create();
        
		#if release // show the mouse for the debugger
		openfl.ui.Mouse.hide();
		#end 
		
		initControls();

		initDialogueBox();
		
		initScripts();
		
		initSave();
	
		hideSoundTray();
		
		#if debug
		#if forceCutscene
		init_forceCutscene = Compiler.getDefine("forceCutscene").split('=')[0];
		#end
		#if testLevelCurve
		for(level in 0...(Constants.maxLevel)){
			trace("EXP for level " + (level) + ": " + CharacterLevel.getExpForNextLevel(level));
		}
		#end
		#if testBattle
		Save.load(0);
		PlayState.setBattle(Compiler.getDefine("testBattle").split('=')[0], ARCADE);
		FlxG.switchState(PlayState.new);
		return;
		#end
		#if testOverworld
		Save.load(0);
		OverworldState.roomName = Compiler.getDefine("testOverworld").split('=')[0];
		FlxG.switchState(OverworldState.new);
		return;
		#end
		#if levelSelector
		Save.load(0);
		FlxG.switchState(LevelSelectorState.new);
		return;
		#end
		#end
        
		FlxG.switchState(MainMenuState.new);
    }
	function initControls():Void
	{
		CtControls.registerControl({id: "left", inputKey: [LEFT, A], inputPad: [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT]});
		CtControls.registerControl({id: "right", inputKey: [RIGHT, D], inputPad: [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]});
		CtControls.registerControl({id: "up", inputKey: [UP, W], inputPad: [DPAD_UP, LEFT_STICK_DIGITAL_UP]});
		CtControls.registerControl({id: "down", inputKey: [DOWN, S], inputPad: [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN]});
		CtControls.registerControl({id: "accept", inputKey: [Z, ENTER], inputPad: [A]});
		CtControls.registerControl({id: "cancel", inputKey: [X, BACKSPACE], inputPad: [B]});
		CtControls.registerControl({id: "exit", inputKey: [ESCAPE], inputPad: [START]});

		CtMenuManager.setDefaultControls(CtControls.getInputFunction("right", JUSTPRESSED), CtControls.getInputFunction("left", JUSTPRESSED),
			CtControls.getInputFunction("accept", JUSTPRESSED), CtControls.getInputFunction("cancel", JUSTPRESSED),
			CtControls.getInputFunction("down", JUSTPRESSED), CtControls.getInputFunction("up", JUSTPRESSED));
	}
	
	function initDialogueBox():Void
	{
		CtDialogueBox.defaultSettings = {
			antialiasing: false,
			textAntialiasing: false,
			pressedAcceptFunction: CtControls.getInputFunction("accept", JUSTPRESSED),
			choicerPressedUpFunction: CtControls.getInputFunction("up", JUSTPRESSED),
			choicerPressedDownFunction: CtControls.getInputFunction("down", JUSTPRESSED),
			choicerPressedAcceptFunction: CtControls.getInputFunction("accept", JUSTPRESSED),
			boxImgPath: Constants.dialogueBoxGraphicPath,
			nameBoxFont: Constants.fontName,
			nameBoxImgPath: Constants.dialogueNameBoxGraphicPath,
			nameBoxLeftEndImgPath: Constants.dialogueNameBoxLeftEndGraphicPath,
			nameBoxRightEndImgPath: Constants.dialogueNameBoxRightEndGraphicPath,
			nameBoxFontSize: 75,
			font: Constants.fontName,
			fontSize: 58,
			textFieldWidth: 1000,
			portraitFieldWidthRight: 600,
			textOffset: new FlxPoint(100, 100),
			boxPosition: new FlxPoint(0, 170),
			textRows: 4,
			portraitOnTopOfBox: true,
			portraitOffsetRight: new FlxPoint(330, 320),
			nameBoxOffsetLeft: new FlxPoint(45, 60),
			nameBoxOffsetRight: new FlxPoint(-45, 60),
			sentencePauseLength: .2,
			excludedTextSoundCharacters: [" ", ".", "!", "?"],
			choicerFont: Constants.fontName,
			choicerCursorPath: "cursor_arrow",
			choicerFontSize: 55,
			choicerSpacing: 50,
			choicerOffset: new FlxPoint(100, 70),
			positionPortraitFromBottom: true,
			nameBoxFollowType: Opposite,
		}

		CtDialogueBox.preloadFont(CtDialogueBox.defaultSettings.font, CtDialogueBox.defaultSettings.fontSize);

		CtDialogueBox.addTextEffect({typableStartText: "[[BLUE]]", typableEndText: "[[ENDBLUE]]", startText: "@[NUM]331640A", endText: "@[NUM]0", effectClass: BlueEffect});

	}
	function initScripts():Void
	{
		CtScript.init();
		CtScript.setDefaultValue({name: "Character", value: Character});
		CtScript.setDefaultValue({name: "Player", value: Player});
		CtScript.setDefaultValue({name: "DOWN", value: FlxDirectionFlags.DOWN});
		CtScript.setDefaultValue({name: "LEFT", value: FlxDirectionFlags.LEFT});
		CtScript.setDefaultValue({name: "UP", value: FlxDirectionFlags.UP});
		CtScript.setDefaultValue({name: "RIGHT", value: FlxDirectionFlags.RIGHT});
		CtScript.setDefaultValue({name: "FlxTimer", value: FlxTimer});
		CtScript.setDefaultValue({name: "FlxTween", value: FlxTween});
		CtScript.setDefaultValue({name: "FlxEase", value: FlxEase});
		CtScript.setDefaultValue({name: "Constants", value: Constants});
		CtScript.setDefaultValue({name: "FlxMath", value: FlxMath});
		CtScript.setDefaultValue({name: "LightingSprite", value: LightingSprite});
		CtScript.setDefaultValue({name: "FlxSpriteGroup", value: FlxSpriteGroup});
		CtScript.setDefaultValue({name: "BetterFlxOgmo3Loader", value: BetterFlxOgmo3Loader});
		CtScript.setDefaultValue({name: "Std", value: Std});
		CtScript.setDefaultValue({name: "FlxColor.interpolate", value: FlxColor.interpolate});
		CtScript.setDefaultValue({name: "FlxColor.fromInt", value: FlxColor.fromInt});
		CtScript.setDefaultValue({name: "LightingEffectShader", value: LightingEffectShader});
		CtScript.setDefaultValue({name: "Save", value: Save});
		CtScript.setDefaultValue({name: "StoryFlag", value: StoryFlag});
		CtScript.setDefaultValue({name: "Door", value: Door});
		CtScript.setDefaultValue({name: "Interactable", value: Interactable});
		CtScript.setDefaultValue({name: "LightSourceSprite", value: LightSourceSprite});
		CtScript.setDefaultValue({name: "CtEventManager", value: CtEventManager});
		CtScript.setDefaultValue({name: "CtEventTransaction", value: CtEventTransaction});
		CtScript.setDefaultValue({name: "OverworldState", value: OverworldState});
		CtScript.setDefaultValue({name: "CtDialogueBox", value: CtDialogueBox});
		CtScript.setDefaultValue({name: "ScrollingProp", value: ScrollingProp});
		CtScript.setDefaultValue({name: "BitmapData", value: BitmapData});
		CtScript.setDefaultValue({name: "FlxGame", value: FlxGame});
		CtScript.setDefaultValue({name: "FlxTypedGroup", value: FlxTypedGroup});
		CtScript.setDefaultValue({name: "FlxTilemap", value: FlxTilemap});
		CtScript.setDefaultValue({name: "FlxSprite", value: FlxSprite});
		CtScript.setDefaultValue({name: "FlxAxes.X", value: FlxAxes.X});
		CtScript.setDefaultValue({name: "CharacterStatus.IDLE", value: CharacterStatus.IDLE});
		CtScript.setDefaultValue({name: "CtUtil", value: CtUtil});
		CtScript.setDefaultValue({name: "FlxSound", value: FlxSound});
		CtScript.setDefaultValue({name: "InitState", value: InitState});
		CtScript.setDefaultValue({name: "CtSound", value: CtSound});
		CtScript.setDefaultValue({name: "FlxG", value: FlxG});
		CtScript.setDefaultValue({name: "StringTools", value: StringTools});
	}

	function initSave():Void
	{
		Save.init();

		#if traceStoryFlags
		for (storyFlag in Save.storyFlags)
		{
			trace("[StoryFlag]");
			trace(storyFlag.id);
			trace(storyFlag.val_string);
			trace(storyFlag.val_bool);
			trace(storyFlag.val_int);
			trace(storyFlag.val_float);
		}
		#end
	}
	function hideSoundTray():Void
	{
		FlxG.plugins.addPlugin(new SoundTrayManager());
	}
}