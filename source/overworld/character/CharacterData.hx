package overworld.character;

class CharacterData extends CtJsonLoader
{
	public var id:String;
    
    public var name:String;
    public var graphic:String;
	public var noclip:Bool;
	public var anims:Array<CharacterAnimation>;
    
	public var fromAseprite:Bool;
	
    public function new(id:String){
        this.id = id;
        
		super(Constants.characterDataPath + id + '.json', Constants.characterDataPath + 'mc.json');
        
        this.name = data.name ?? "";
		this.graphic = data.graphic ?? "robin";
		this.noclip = data.noclip ?? false;
		this.fromAseprite = data.fromAseprite ?? false;

		if (data.anims == null)
			anims = [];
		else
		{
			anims = mapCharacterAnimation(data);
		}
    }

	public static function mapCharacterAnimation(data:Dynamic):Array<CharacterAnimation>
	{
		return data.anims.map(function(item)
		{
			return {
				name: item.name ?? "",
				prefix: item.prefix ?? "",
				fps: item.fps ?? 24,
				looped: item.looped ?? false,
				flipX: item.flipX ?? false,
				flipY: item.flipY ?? false
			};
		});
	}
}