package save;

class Save
{
	// story flags
    public static var storyFlags:Map<String, StoryFlag> = [];
    
	// time
	public static var playtime:Float = 0;
	
	// saved unit placements
	public static var savedUnitPlacements:Array<GridUnitPlacerInfo> = [];
	
	// unlocked units
	public static var unlockedUnits:Map<String, Bool> = [];

	//character levels
	public static var levelRobin:CharacterLevel;
	public static var levelUnits:Map<String, CharacterLevel> = [];

	// saved unit hp / mp 
	// these dont actually get saved
	public static var savedUnitHP:Map<String, Int> = [];
	public static var savedUnitMP:Map<String, Int> = [];

    public static function init():Void{
        // add story flags
        for (storyFlagName in CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.storyFlagsDataFolder, [".json"], false, false), ["storyflag_", ".json"]))
		{
			storyFlags.set(storyFlagName, new StoryFlag(storyFlagName));
		}
        
		FlxG.plugins.addPlugin(new TimeHandler());
		
		// setup character levels
		levelRobin = new CharacterLevel("robin", ROBIN);
		for(unitName in Unit.getListOfUnits()){
			levelUnits.set(unitName, new CharacterLevel(unitName, UNIT));	
		}
        reset();
    }
    
	public static var loadedSaveSlot:Int = -1;

    public static function reset():Void{
        // reset story flags
        
        for(storyFlag in storyFlags){
            storyFlag.restoreDefault();
        }
		// reset last room

		OverworldState.roomName = "";
		OverworldState.previousRoom = "";
		OverworldState.savePointName = "";
		OverworldState.lastTransitionTime = 0;
		OverworldState.resetGlobalVars();
		// reset time

		playtime = 0;

		// reset saved unit placements
		savedUnitPlacements = [];
		
		// reset unlocked units
		for(unitName in Unit.getListOfUnits()){
			unlockedUnits.set(unitName, Registry.get(UnitData, unitName).unlockedByDefault ? true : false);
		}

		// reset character levels
		levelRobin.exp = 0;
		for(levelUnit in levelUnits){
			levelUnit.exp = 0;
		}

		// reset saved hp / mp
		resetSavedHpMp();
	}

	public static function save(?slot:Int = -5, ?onComplete:Void->Void):Void
	{
		if (slot == -5)
			slot = loadedSaveSlot;

		if (slot < 0)
		{
			return; // dont load on a slot that doesnt exist dawg..
		}

		loadedSaveSlot = Std.int(FlxMath.bound(slot, 0, Constants.maxSaveFiles));
		trace("Starting Save (Slot " + loadedSaveSlot + ")");

		var save = new FlxSave();
		save.bind(Constants.saveFileName + loadedSaveSlot);

		// set save as created
		save.data.saveCreated = true;

		// save story flags
		save.data.storyFlags = new Map<String, StoryFlag>();

		for (storyFlag in storyFlags)
		{
			var newFlag:StoryFlag = new StoryFlag(storyFlag.id);
			newFlag.val_string = storyFlag.val_string;
			newFlag.val_bool = storyFlag.val_bool;
			newFlag.val_int = storyFlag.val_int;
			newFlag.val_float = storyFlag.val_float;

			save.data.storyFlags.set(newFlag.id, newFlag);
		}

		// save last room

		save.data.roomName = OverworldState.roomName;
		save.data.previousRoom = OverworldState.previousRoom;
		save.data.savePointName = OverworldState.savePointName;
		save.data.lastTransitionTime = OverworldState.lastTransitionTime;

		// save time

		save.data.playtime = playtime;
		
		// save unit placements
		save.data.savedUnitPlacements = savedUnitPlacements;
		
		// save unlocked units
		save.data.unlockedUnits = new Map<String, Bool>();

		for(unitName in Unit.getListOfUnits()){
			save.data.unlockedUnits.set(unitName, unlockedUnits.get(unitName));
		}

		// save character levels
		save.data.levelRobinExp = levelRobin.exp;

		save.data.levelUnitsExp = new Map<String, Int>();

		for(levelUnit in levelUnits){
			save.data.levelUnitsExp.set(levelUnit.name, levelUnit.exp);
		}
		// flush
        
		save.flush();

		trace("Finished Save (Slot " + loadedSaveSlot + ")");
		if (onComplete != null)
		{
			onComplete();
		}
	}

	public static function load(?slot:Int = -5, ?onComplete:Void->Void):Void
	{
		if (slot == -5)
			slot = loadedSaveSlot;

		reset(); // reset before loading in case youre loading a different slot or smth

		if (slot < 0)
		{
			return; // dont load on a slot that doesnt exist dawg..
		}

		loadedSaveSlot = Std.int(FlxMath.bound(slot, 0, Constants.maxSaveFiles));

		trace("Starting Load (Slot " + loadedSaveSlot + ")");

		var save = new FlxSave();
		save.bind(Constants.saveFileName + loadedSaveSlot);

		if (save.data.saveCreated == null)
		{
			OverworldState.roomName = Constants.startingRoom;
			Save.save();
		}

		// load story flags
		if (save.data.storyFlags != null)
		{
			var saved_storyFlags:Map<String, StoryFlag> = cast save.data.storyFlags;

			for (storyFlag in saved_storyFlags)
			{
				if (storyFlags.exists(storyFlag.id))
				{
					storyFlags.get(storyFlag.id).val_string = storyFlag.val_string;
					storyFlags.get(storyFlag.id).val_bool = storyFlag.val_bool;
					storyFlags.get(storyFlag.id).val_int = storyFlag.val_int;
					storyFlags.get(storyFlag.id).val_float = storyFlag.val_float;
				}
			}
		}

		// load last room
		if (save.data.roomName != null)
		{
			OverworldState.roomName = save.data.roomName;
		}
		if (save.data.previousRoom != null)
		{
			OverworldState.previousRoom = save.data.previousRoom;
		}
		if (save.data.savePointName != null)
		{
			OverworldState.savePointName = save.data.savePointName;
		}
		if (save.data.lastTransitionTime != null)
		{
			OverworldState.lastTransitionTime = save.data.lastTransitionTime;
		}
		// load time

		if (save.data.playtime != null)
		{
			playtime = save.data.playtime;
		}
		
		// load saved unit placements
		if (save.data.savedUnitPlacements != null)
		{
			savedUnitPlacements = save.data.savedUnitPlacements;
		}

		// load unlocked units 
		if(save.data.unlockedUnits != null){
			for(unitName in Unit.getListOfUnits()){
				var savedUnlockedUnits:Map<String, Bool> = cast save.data.unlockedUnits;

				if(savedUnlockedUnits.exists(unitName)){
					unlockedUnits.set(unitName, Registry.get(UnitData, unitName).unlockedByDefault ? true : savedUnlockedUnits.get(unitName));
				}
			}
		}
		
		// load character levels
		if(save.data.levelRobinExp != null){
			levelRobin.exp = save.data.levelRobinExp;
		}
		if(save.data.levelUnitsExp != null){
			for(levelUnit in levelUnits){
				var savedLevelUnitsEXP:Map<String, Int> = save.data.levelUnitsExp;
				
				if(savedLevelUnitsEXP.exists(levelUnit.name)){
					levelUnit.exp = savedLevelUnitsEXP.get(levelUnit.name);
				}
			}
		}

		// reset saved hp / mp
		resetSavedHpMp();
		
		trace("Finished Load (Slot " + loadedSaveSlot + ")");
		if (onComplete != null)
		{
			onComplete();
		}
	}
	public static function isSaveStarted(slot:Int):Bool
	{
		var save = new FlxSave();
		save.bind(Constants.saveFileName + slot);

		return save.data.saveCreated;
	}

	public static function isAnySaveStarted():Bool
	{
		var yes:Bool = false;

		for (i in 0...Constants.maxSaveFiles)
		{
			if (isSaveStarted(i))
			{
				yes = true;
				break;
			}
		}

		return yes;
	}

	public static function resetSavedHpMp():Void{
		for(unitName in Unit.getListOfUnits()){
			var realUnit:Unit = new Unit(unitName, null, FlxPoint.get(1,1), true, CharacterLevel.getLevelFromExp(levelUnits.get(unitName).exp), true);

			savedUnitHP.set(unitName, realUnit.maxHp.value);
			savedUnitMP.set(unitName, realUnit.maxMp.value);

			realUnit.destroy();
		}
	}
}