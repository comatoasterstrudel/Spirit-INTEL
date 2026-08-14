package;

class Constants 
{
	//
	// BATTLE STUff !!!!!!11
	//
	// LEVELING !!!
	// AT THE TOP FOR EASY ACCESS
	public static final maxLevel:Int = 50;
	public static final baseLvlPerExp:Int = 50; 
	public static final levelExpScaling:Float = 10;
	public static final statsIncreaseFromLeveling:Float = 5; // all stats will be multiplied by 5 when leveled to full
	// COLOR
	public static final color_hp:FlxColor = 0xFFA3E352;
	public static final color_hpLoss:FlxColor = color_hp.getDarkened(0.8);
	public static final color_mp:FlxColor = 0xFF525CE3;
	public static final color_mpLoss:FlxColor = color_mp.getDarkened(0.8);
	// Battle
	public static final battleDataFolder:String = "assets/data/battles/";
	public static final battleDataPath:String = Constants.battleDataFolder + "battle_";
	public static final battleDataMusicPath:String = "assets/music/battletheme/theme_";
	// Grid
    public static final gridSize:Int = 80;
	public static final unitGridGraphicPath:String = "assets/images/grid/units/unit_";
	public static final gridBackgroundSpriteNum:Int = 15;
	// Units
	public static final unitDataFolder:String = "assets/data/units/";
	public static final unitDataPath:String = unitDataFolder + "unit_";
	// Skills
	public static final skillDataPath:String = "assets/data/skills/skill_";
	public static final unitMaxSkills:Int = 5;
	// Status Effects
	public static final statusEffectDataPath:String = "assets/data/status/status_";
	public static final statusEffectAnimTime:Float = 1;
	// UI
	public static final uiYOffset:Float = 0;
	// StatusEffectBar
	public static final statusEffectIconPath:String = "assets/images/statusicons/icon_";
	// MiniHealthBar
	public static final miniHealthBarOutlineColor:FlxColor = FlxColor.BLACK;
	public static final miniHealthBarOutlineWidth:Int = 2;
	public static final miniHealthBarWidth:Int = 45;
	public static final miniHealthBarHeight:Int = 12;
	public static final miniHealthBarYSpacing:Int = -7;
	// TurnOrderDisplay
	public static final turnOrderDisplayUpperBarGraphicPath:String = "assets/images/turnorder/upperBar.png";
	public static final turnOrderDisplayUpperBarDarkGraphicPath:String = "assets/images/turnorder/upperBarDark.png";
	public static final turnOrderDisplayIncomingCallsGraphicPath:String = "assets/images/turnorder/incomingCalls.png";
	public static final turnOrderDisplayStartingX:Float = 564;
	// Top Bar
	public static final topBarTalkerAnimPath:String = "assets/images/turnorder/top/top_talkeranim";
	public static final topBarStatDisplayLeft:String = "assets/images/turnorder/top/top_barleft.png";
	public static final topBarStatDisplayMid:String = "assets/images/turnorder/top/top_barmid.png";
	public static final topBarStatDisplayRight:String = "assets/images/turnorder/top/top_barright.png";
	public static final topBarStatDisplayMinWidth:Int = 150;
	public static final topBarStatDisplayMaxWidth:Int = 500;
	// TurnOrderIcon
	public static final turnOrderIcon:String = "assets/images/turnorder/turnOrderIcon.png";
	public static final turnOrderIconOutline:String = "assets/images/turnorder/turnOrderIconOutline.png";
	// BottomBar
	public static final bottomBarGraphicPath:String = "assets/images/bottombar/bar/bottombar_";
	public static final unitUiGraphicPath:String = "assets/images/bottombar/portraits/portrait_";
	public static final skillOutlineGraphicPath:String = "assets/images/bottombar/skills/box/box_outline.png";
	public static final skillBackgroundGraphicPath:String = "assets/images/bottombar/skills/box/box_bg.png";
	public static final skillIconGraphicPath:String = "assets/images/bottombar/skills/icons/icon_";
	public static final inspectButtonGraphicPath:String = "assets/images/bottombar/inspect.png";
	public static final endTurnButtonGraphicPath:String = "assets/images/bottombar/endturn.png";
	public static final bottomBarTextMiddle:String = "assets/images/bottombar/desctext_bgMiddle.png";
	public static final bottomBarTextEdge:String = "assets/images/bottombar/desctext_bgEdge.png";
	// Cursors
	public static final cursorArrowGraphic:String = "assets/images/cursors/cursor_arrow.png";
	// LevelSelectorState
	public static final levelSelectTextXPos:Int = 120;
	public static final levelSelectTextYPos:Int = 30;
	public static final levelSelectTextYSpacing:Int = 80;
	public static final levelSelectTextSize:Int = 30;
	public static final levelSelectNoLevelMessage:String = "There are no battles available!\nAdd some battle files to "
		+ Constants.battleDataFolder
		+ "\nand then press R to reload this menu!";
	// Exit
	public static final exitTime:Float = 1;
	// Death Effect
	public static final deathEffectTime:Float = 1;
	// Result State
	public static final resultTextWin:String = "WIN";
	public static final resultTextLose:String = "LOSS";
	public static final resultTextTie:String = "TIE";
	public static final resultTextPlaceholder:String = "???";
	public static final resultBgOpacity:Float = .9;
	public static final resultBigTextSize:Int = 80;
	public static final resultBigTextY:Int = 50;
	public static final resultTextSize:Int = 50;
	public static final resultTextX:Int = 300;
	public static final resultTextY:Int = 300;
	public static final resultTextSpacing:Int = 130;
	public static final resultAnimTiming:Float = .65;
	public static final resultAnimShakeTime:Float = 0.08;
	public static final resultAnimShakeIntensity:Float = 0.08;
	// Victory Screen
	public static final vsTopTextPath:String = "assets/images/victoryscreen/vs_text.png";
	public static final vsUnitLevelUiCellWidth:Float = 220;
	public static final vsUnitLevelUiCellHeight:Float = 150;
	public static final vsUnitLevelUiBgCornerPath:String = "assets/images/victoryscreen/vs_boxcorner.png";
	public static final vsPhonePath:String = "assets/images/victoryscreen/vs_phone";
	public static final vsPhoneBlankPath:String = "assets/images/victoryscreen/vs_phoneblank.png";
	public static final vsPhoneBlackPath:String = "assets/images/victoryscreen/vs_phoneblack.png";
	public static final vsPhoneBaseX:Int = -30;
	public static final vsPhoneBaseY:Int = 300;
	public static final vsPhoneBgColor:FlxColor = FlxColor.PURPLE;
	public static final vsPhoneBgPath:String = "assets/images/victoryscreen/vs_phonebg.png";
	public static final vsFloatingTextMiddlePath:String = "assets/images/victoryscreen/vs_textBoxMiddle.png";
	public static final vsFloatingTextEdgePath:String = "assets/images/victoryscreen/vs_textBoxEdge.png";
	public static final vsRobinPath:String = "assets/images/victoryscreen/vs_robin.png";
	public static final vsRobinBlankPath:String = "assets/images/victoryscreen/vs_robinblank.png";
	public static final vsBarPath:String = "assets/images/victoryscreen/vs_bar.png";
	public static final vsSparklesPath:String = "assets/images/victoryscreen/vs_sparkle";
	public static final vsBoxDoodlesPath:String = "assets/images/victoryscreen/vs_doodle_";
	// TurnAttentionAnim
	public static final turnAttentionAnimTime:Float = .6;
	public static final turnAttentionAnimTimeSplit:Float = .7;
	public static final turnAttentionAnimScale:Float = .14;
	public static final turnAttentionAnimAlpha:Float = .7;
	public static final turnAttentionAnimScaler:Float = 1.5;
	// Camera
	public static final battleCameraMovementX:Float = 0.1;
	public static final battleCameraMovementY:Float = 0.05;
	public static final battleCameraMovementSpeed:Float = 3;
	// Battle Background
	public static final battleBackgroundDataPath:String = "assets/data/battlebackgrounds/battlebg_";
	public static final battleBackgroundGraphicPath:String = "assets/images/battlebackgrounds/battlebg_";
	// Scripts
	public static final battleScriptPath:String = "assets/data/battlescripts/battlescript_";
	// GridUnitPlacer
	public static final gridUnitPlacerUnitIconSize:Int = 80;
	public static final gridUnitPlacerUnitIconSpacing:Int = 20;
	public static final gridUnitPlacerUnitsPerRow:Int = 3;
	public static final gridUnitPlacerBgWidth:Float = (gridUnitPlacerUnitIconSize * gridUnitPlacerUnitsPerRow)
		+ (gridUnitPlacerUnitIconSpacing * (gridUnitPlacerUnitsPerRow + 1));
	public static final gridUnitPlacerButtonPath:String = "assets/images/gridunitplacer/button_";
	public static final gridUnitPlacerRobinPath:String = "assets/images/gridunitplacer/robin/";
	public static final gridUnitPlacerUiBgSpriteNum:Int = 15;
	public static final gridUnitPlacerBubble:String = "assets/images/gridunitplacer/gridplacer_bubble";
	//
	// OVERWORLD STUFF !!
	//
	// Pixel Sizing
	public static final overworldPixelScale:Float = 3;
	// Characters
	public static final playerCharacterName:String = "robin";
	public static final characterDataPath:String = "assets/data/characters/character_";
	public static final characterGraphicPath:String = "assets/images/characters/character_";
	public static final characterSpeed:Float = 300;
	public static final characterSpeedDiagonal:Float = characterSpeed * .707;
	public static final characterWalkFps:Int = 5;
	// Rooms
	public static final roomDataFolder:String = "assets/data/rooms/";
	public static final roomDataPath:String = roomDataFolder + "room_";
	// Tilemaps
	public static final ogmoFilePath:String = "assets/data/tilemaps/RPGENGINE.ogmo";
	public static final tilemapsDataPath:String = "assets/data/tilemaps/tilemap_";
	// Tilesets
	public static final tilesetDataPath:String = "assets/data/tilesets/tileset_";
	public static final tilesetGraphicPath:String = "assets/images/tileset/tileset_";
	// Encounters
	public static final encounterCooldown:Float = 3.5;
	// Doors
	public static final doorGraphicPath:String = "assets/images/doors/door_";
	public static final doorDataPath:String = "assets/data/doors/door_";
	public static final doorOpenSoundPath:String = "assets/sounds/doors/dooropen_";
	public static final doorLockSoundPath:String = "assets/sounds/doors/doorlock_";
	// Props
	public static final propDataPath:String = "assets/data/props/prop_";
	public static final propImagePath:String = "assets/images/props/prop_";
	// Scrolling Props
	public static final scrollingPropImagePath:String = "assets/images/scrollingprops/scrollingprop_";
	// Scripts
	public static final roomScriptPath:String = "assets/data/roomscripts/roomscript_";
	// Lighting
	public static final lightSourceGraphicPath:String = "assets/images/lightsources/lightsource_";
	// Overworld Misc
	public static final overworldMiscGraphicPath:String = "assets/images/overworldmisc/overworldmisc_";
	// Cutscenes
	public static final overworldCutsceneGraphicPath:String = "assets/images/cutscene/cutscene_";
	// Save spots
	public static final saveSpotGraphicPath:String = "assets/images/savespots/savespot_";
	public static final saveSpotDataPath:String = "assets/data/savespots/savespot_";
	// Player Menu
	public static final playerMenuBgLeftUp:String = "assets/images/playermenu/bg/bg_leftUp.png";
	public static final playerMenuBgLeft:String = "assets/images/playermenu/bg/bg_left.png";
	public static final playerMenuBgLeftDown:String = "assets/images/playermenu/bg/bg_leftDown.png";
	public static final playerMenuBgRightUp:String = "assets/images/playermenu/bg/bg_rightUp.png";
	public static final playerMenuBgRight:String = "assets/images/playermenu/bg/bg_right.png";
	public static final playerMenuBgRightDown:String = "assets/images/playermenu/bg/bg_rightDown.png";
	public static final playerMenuBgTop:String = "assets/images/playermenu/bg/bg_top.png";
	public static final playerMenuBgBottom:String = "assets/images/playermenu/bg/bg_bottom.png";
	public static final playerMenuStatusNamePlatePath:String = "assets/images/playermenu/status/status_nameplate.png";
	public static final playerMenuStatusRobinAuraPath:String = "assets/images/playermenu/status/status_robinaura.png";
	public static final playerMenuPolaroidBorderPath:String = "assets/images/playermenu/polaroid/polaroid_border.png";
	public static final playerMenuPolaroidBorderShadowPath:String = "assets/images/playermenu/polaroid/polaroid_borderShadow.png";
	public static final playerMenuPolaroidBgPath:String = "assets/images/playermenu/polaroid/bg/polaroidbg_";
	public static final playerMenuPolaroidScriptPath:String = "assets/data/playermenu/polaroid.hx";
	public static final playerMenuPolaroidImgPath:String = "assets/images/playermenu/polaroid/img/polaroidimg_";
	public static final playerMenuUnitSelectorWidth:Int = 420;
	public static final playerMenuUnitSelectorHeight:Int = 100;
	public static final playerMenuUnitSelectorBarOverlayPath:String = "assets/images/playermenu/unitselector/unitselector_baroverlay.png";
	//
	// DIALOGUE STUFF !!
	//
	public static final dialogueBoxGraphicPath:String = "box";
	public static final dialogueNameBoxGraphicPath:String = "nameBox";
	public static final dialogueNameBoxLeftEndGraphicPath:String = "nameBoxLeft";
	public static final dialogueNameBoxRightEndGraphicPath:String = "nameBoxRight";
	public static final dialogueGraphicsPath:String = "assets/images/dialogue/";
	//
	// MAIN MENU
	//
	public static final mainMenuStartingY:Float = 300;
	public static final mainMenuLogoPath:String = "assets/images/mainmenu/gameLogo.png";
	public static final mainMainBgPath:String = "assets/images/mainmenu/bg.png";
	public static final mainMenuIntroTime:Float = .5;
	//
	// SAVE !!! STUFF !!!
	//
	// story flags
	public static final storyFlagsDataFolder:String = "assets/data/storyflags/";
	public static final storyFlagsDataPath:String = storyFlagsDataFolder + "storyflag_";
	// saveloadmenu
	public static final saveLoadMenuSaveWindowGraphicPath:String = "assets/images/saveloadmenu/saveWindow.png";
	public static final saveLoadMenuSaveWindowArrowGraphicPath:String = "assets/images/saveloadmenu/saveWindowArrow.png";
	public static final saveLoadMenuCallIconGraphicPath:String = "assets/images/saveloadmenu/saveWindowPhone.png";
	public static final saveLoadMenuCallIconNotStartedGraphicPath:String = "assets/images/saveloadmenu/saveWindowPhoneNotStarted.png";
	public static final saveLoadMenuDividerGraphicPath:String = "assets/images/saveloadmenu/saveWindowDivider.png";
	public static final saveLoadMenuBgGraphicPath:String = "assets/images/saveloadmenu/bg/savebg_";
	// time
	public static final timeTrackerStates:Array<Dynamic> = [OverworldState, PlayState];
	public static final timeTrackerExcludedSubStates:Array<Dynamic> = [SaveLoadMenu];
	//
	// BASE STUFF ??
	//
	public static final startingRoom:String = "factory_intro";
	public static final sfxPath:String = "assets/sounds/sfx_";
	public static final fontName:String = "assets/fonts/BestFontEver-Regular.ttf";
	//
	// SAVE STUFF
	//
	public static final saveFileName:String = "s";
	public static final maxSaveFiles:Int = 2;

}