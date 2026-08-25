package battle.status;

class StatusEffectData extends CtJsonLoader
{
    var id:String = "";
    
    public var name:String;

    public var text:String;
    
	public var iconGraphic:String;
     
    public var color:FlxColor;
    
    public var triggerType:String = '';
    
	public var effects:SkillEffects;
    public var passiveEffects:PassiveSkillEffects;

    public function new(id:String){
        this.id = id;
                
        super(Constants.statusEffectDataPath + id + '.json', Constants.statusEffectDataPath + 'poison.json');
        
        this.name = data.name;

        this.text = data.text;
        
		this.iconGraphic = data.iconGraphic;
        
        this.color = FlxColor.fromRGB(data.color[0], data.color[1], data.color[2], 255);
        
        this.triggerType = data.triggerType;
        
		effects = SkillData.mapSkillEffects(data);
        passiveEffects = SkillData.mapPassiveSkillEffects(data);
	}
}