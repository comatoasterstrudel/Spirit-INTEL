package overworld.rooms;

class RoomData extends CtJsonLoader
{
	public var id:String;
    
    public var name:String;
    public var map:String;
	public var displayName:String;

	public var encounters:Array<EncounterData>;
	public var encounterChance:Float;
    
	public var lighting:Float;
	public var lightingDarkColor:FlxColor;
	public var lightingGlowColor:FlxColor;

	public var script:Array<String>;
	
	public var bgColor:FlxColor;

	public var hasBorders:Bool;
	
	public var playerName:String;
	
	public var music:String;

    public function new(id:String){
        this.id = id;
        
		super(Constants.roomDataPath + id + '.json', Constants.roomDataPath + 'test_test.json');
        
        this.name = data.name ?? "";
        this.map = data.map ?? "test";
		this.displayName = data.displayName ?? "";
		
		if (data.encounters == null)
		{
			encounters = [];
		}
		else 
		{ 
			encounters = data.encounters.map(function(item)
			{
				return {
					battleName: item.battleName,
					rarity: item.rarity
				};
			});
		}
		this.encounterChance = data.encounterChance ?? 10;
		this.script = data.script ?? cast [];
		this.lighting = data.lighting == null ? 0 : data.lighting;

		var colorArrayDark = data.lightingDarkColor ?? cast [0, 0, 0, 255];
		var colorArrayGlow = data.lightingGlowColor ?? cast [0, 0, 0, 0];
		
		this.lightingDarkColor = FlxColor.fromRGB(colorArrayDark[0], colorArrayDark[1], colorArrayDark[2], colorArrayDark[3]);
		this.lightingGlowColor = FlxColor.fromRGB(colorArrayGlow[0], colorArrayGlow[1], colorArrayGlow[2], colorArrayGlow[3]);
		var colorArrayBg = data.bgColor ?? cast [255, 255, 255];

		this.bgColor = FlxColor.fromRGB(colorArrayBg[0], colorArrayBg[1], colorArrayBg[2], 255);
		this.hasBorders = data.hasBorders ?? false;
		this.playerName = data.playerName ?? Constants.playerCharacterName;

		this.music = data.music ?? "";
    }
} 