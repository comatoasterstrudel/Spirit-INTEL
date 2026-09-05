package battle.battleData;

class BattleData extends CtJsonLoader
{
	public var id:String;
    
    public var gridSizeX:Int;
    public var gridSizeY:Int;
    
	public var music:String = "";
    
	public var background:String = "";

    public var allyUnits:Array<UnitInfo> = [];
    public var enemyUnits:Array<UnitInfo> = [];

	public var script:Array<String> = [];
    
	public var disableUnitPlacer:Bool = false;
     
    public var unlockableUnits:Array<UnitUnlockInfo> = [];

    public function new(id:String){
        this.id = id;
        
		super(Constants.battleDataPath + id + '.json', Constants.battleDataPath + 'test_test.json');
        
        this.gridSizeX = data.gridSizeX;
        this.gridSizeY = data.gridSizeY;
        
		this.music = data.music ?? "";
        
		this.background = data.background ?? "placeholder";
        
        allyUnits = data.allyUnits.map(function(item)
        {
            return {
				id: item.id,
                position: new FlxPoint(item.x, item.y),
                level: item.level == null ? 1 : item.level
            };
        });
        
        enemyUnits = data.enemyUnits.map(function(item)
        {
            return {
				id: item.id,
                position: new FlxPoint(item.x, item.y),
                level: item.level == null ? 1 : item.level
            };
        });
		this.script = data.script ?? cast [];
		this.disableUnitPlacer = data.disableUnitPlacer ?? false;

        if(data.unlockableUnits == null){
            unlockableUnits = [];
        } else {
            unlockableUnits = data.unlockableUnits.map(function(item)
            {
                return {
                    id: item.id,
                    chance: item.chance == null ? 100 : item.chance,
                    level: item.level == null ? 1 : item.level
                };
            });
        }
    }
}