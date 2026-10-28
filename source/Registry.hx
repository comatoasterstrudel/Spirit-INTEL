package;

/**
 * Class that manages all of the json registries used here ..
 */
class Registry
{
    public static var registry:CtJsonRegistry;

    public static function initRegistry():Void{
        registry = new CtJsonRegistry();

        registry.addRegistry(
            UnitData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.unitDataFolder, [".json"], false, false), [Constants.unitDataPrefix, ".json"])
        );
        registry.addRegistry(
            BattleData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.battleDataFolder, [".json"], false, false), [Constants.battleDataPrefix, ".json"])
        );
        registry.addRegistry(
            SkillData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.skillDataFolder, [".json"], false, false), [Constants.skillDataPrefix, ".json"])
        );
        registry.addRegistry(
            BattleBackgroundData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.battleBackgroundDataFolder, [".json"], false, false), [Constants.battleBackgroundDataPrefix, ".json"])
        );
        registry.addRegistry(
            StatusEffectData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.statusEffectDataFolder, [".json"], false, false), [Constants.statusEffectDataPrefix, ".json"])
        );
        registry.addRegistry(
            RoomData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.roomDataFolder, [".json"], false, false), [Constants.roomDataPrefix, ".json"])
        );
        registry.addRegistry(
            CharacterData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.characterDataFolder, [".json"], false, false), [Constants.characterDataPrefix, ".json"])
        );
        registry.addRegistry(
            FootstepData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.footstepDataFolder, [".json"], false, false), [Constants.footstepDataPrefix, ".json"])
        );
        registry.addRegistry(
            PropData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.propDataFolder, [".json"], false, false), [Constants.propDataPrefix, ".json"])
        );
        registry.addRegistry(
            DoorData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.doorDataFolder, [".json"], false, false), [Constants.doorDataPrefix, ".json"])
        );
        registry.addRegistry(
            SaveSpotData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.saveSpotDataFolder, [".json"], false, false), [Constants.saveSpotDataPrefix, ".json"])
        );
        registry.addRegistry(
            TilesetData, 
            CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.tilesetDataFolder, [".json"], false, false), [Constants.tilesetDataPrefix, ".json"])
        );
    }

    /**
     * i dont want to type Registry.registry when i could just type Registry
     */
    public static function get(cls:Class<CtJsonLoader>, id:String):Dynamic{
        return registry.get(cls, id);
    }
}