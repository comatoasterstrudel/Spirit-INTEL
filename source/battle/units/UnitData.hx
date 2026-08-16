package battle.units;

class UnitData extends CtJsonLoader
{
    public var id:String = "";
    
    public var name:String;
    
    public var gridGraphic:String;
	public var uiGraphicAlly:String;
	public var uiGraphicEnemy:String;

	public var stat_maxHp:Int;
	public var stat_maxMp:Int;
	public var stat_speed:Int;
    public var stat_attack:Int;
    public var stat_sattack:Int;

	public var skills:Array<String> = [];
    
	public var unlockedByDefault:Bool;

	public var expReward:Int;

	public var ai_damage:Float;
	public var ai_healing:Float;
	public var ai_debuff:Float;
	public var ai_buff:Float;

	public var spCost:Int;

    public function new(id:String){
        this.id = id;
                
        super(Constants.unitDataPath + id + '.json', Constants.unitDataPath + 'chair.json');
        
        this.name = data.name;
        this.gridGraphic = data.gridGraphic;
		this.uiGraphicAlly = data.uiGraphicAlly;
		this.uiGraphicEnemy = data.uiGraphicEnemy;

		this.stat_maxHp = data.stat_maxHp;
		this.stat_maxMp = data.stat_maxMp;
		this.stat_speed = data.stat_speed;
		this.stat_attack = data.stat_attack;
		this.stat_sattack = data.stat_sattack;

		this.skills = data.skills;
		if (this.skills.length > Constants.unitMaxSkills)
			this.skills.resize(Constants.unitMaxSkills);

		this.unlockedByDefault = data.unlockedByDefault == null ? false : data.unlockedByDefault;
		this.expReward = data.expReward == null ? 0 : data.expReward;

		this.ai_damage = data.ai_damage == null ? 1 : data.ai_damage;
		this.ai_healing = data.ai_healing == null ? 1 : data.ai_healing;
		this.ai_debuff = data.ai_debuff == null ? 1 : data.ai_debuff;
		this.ai_buff = data.ai_buff == null ? 1 : data.ai_buff;

		this.spCost = data.spCost == null ? 0 : data.spCost;
    }
}