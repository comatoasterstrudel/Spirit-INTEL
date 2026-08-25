package battle.skills;

class SkillData extends CtJsonLoader
{
    var id:String = "";
    
    public var name:String;
    public var description:String;
    
    public var iconGraphic:String;
    
	public var selectType:String;
    
	public var rangeX:Int;
	public var rangeY:Int;

	public var effects:SkillEffects;
	
	public var type:String = "";

	public var mpCost:Int;

	public final types:Array<String> = [
		"damage",
		"healing",
		"debuff",
		"buff",
		"na"
	];

	// PHYSICAL vs SPIRITUAL
	public var damageType:String = "";
	public var damageTypes:Array<String> = [
		"physical",
		"spiritual"
	];

    public function new(id:String){
        this.id = id;
                
        super(Constants.skillDataPath + id + '.json', Constants.skillDataPath + 'stab.json');
        
        this.name = data.name;
        this.description = data.description;
        
        this.iconGraphic = data.iconGraphic;

		this.selectType = data.selectType ?? "";
		this.rangeX = data.rangeX ?? 1;
		this.rangeY = data.rangeY ?? 1;

		if(types.contains(data.type)){
			this.type = data.type;
		} else {
			this.type = "na";
		}

		if(damageTypes.contains(data.damageType)){
			this.damageType = data.damageType;
		} else {
			this.damageType = "physical";
		}
		 
		effects = mapSkillEffects(data);

		this.mpCost = data.mpCost == null ? 0 : data.mpCost;
	}

	public static function mapSkillEffects(data:Dynamic):SkillEffects
	{
		var thing:Array<StatusParams> = [];
		
		var effects:SkillEffects = {
			eff_damage: data.effects.eff_damage ?? 0,
			eff_heal: data.effects.eff_heal ?? 0,
			eff_statuses: StatusEffect.mapStatusParams(data.effects.eff_statuses) ?? thing,
		};

		return effects;
	}

	public static function mapPassiveSkillEffects(data:Dynamic):PassiveSkillEffects
	{		
		var effects:PassiveSkillEffects = {
			eff_damageDealt: data.passiveEffects.eff_damageDealt == null ? 0 : data.passiveEffects.eff_damageDealt,
			eff_damageTaken: data.passiveEffects.eff_damageTaken == null ? 0 : data.passiveEffects.eff_damageTaken,
		};

		return effects;
	}
}