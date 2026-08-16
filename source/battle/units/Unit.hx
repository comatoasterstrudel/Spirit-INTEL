package battle.units;

class Unit extends CtSprite
{
    /**
     * the id for this unit, basically its name
     */
    public var unitID:String;
    
	public var uniqueUnitID:Int;
	
	public var data:UnitData;
    
    public var grid:Grid;
    
    public var position:FlxPoint;

	public var controllable:Bool;
	
	public var maxHp:Stat = new Stat("maxHp", 0, 1);
	public var maxMp:Stat = new Stat("maxMp", 0, 1);
	public var speed:Stat = new Stat("speed", 0);
	public var attack:Stat = new Stat("attack", 0, 0);
	public var sattack:Stat = new Stat("sattack", 0, 0);

	var stats:Array<Stat>;

	public var hp:Stat;
	public var mp:Stat;

	var lastHp:Int = 0;
	var lastMp:Int = 0;

	public var skills:Array<SkillData> = [];
	
	public static var uniqueUnitIDnum:Int = 0;

	public var dead:Bool = false;
	
	public var statuses:Array<StatusEffect> = [];
	
	public var level:Int = 1;

	public var placedByPlayer:Bool = false;

	// SIGNALS
	public var onStatusChanged = new FlxTypedSignal<Array<StatusEffect>->Void>();

	public function new(unitID:String, grid:Grid, position:FlxPoint, controllable:Bool, level:Int, ?placedByPlayer:Bool = false):Void
	{
        super();

        this.unitID = unitID;
		this.data = new UnitData(unitID);
        
        this.grid = grid;
        this.position = position;
        
		this.controllable = controllable;
		
		Unit.uniqueUnitIDnum++;

		this.uniqueUnitID = uniqueUnitIDnum;
		
		this.level = Std.int(FlxMath.bound(level, 1, Constants.maxLevel));

		this.placedByPlayer = placedByPlayer;
		
		applyStats();
		
		applySkills();
		
        applyGraphic();
        
        lerpManager.lerpX = true;
        lerpManager.lerpY = true;
		lerpManager.lerpSpeed = 8;
	}

	override function update(elapsed:Float):Void{
		super.update(elapsed);

		if(placedByPlayer && controllable){
			if(hp.value != lastHp){
				Save.savedUnitHP.set(unitID, Std.int(FlxMath.bound(hp.value, 1)));
			}
			if(mp.value != lastMp){
				Save.savedUnitMP.set(unitID, mp.value);
			}
			lastHp = hp.value;
			lastMp = mp.value;
		}
	}

	function applyStats():Void
	{		
		var levelMult:Float = FlxMath.bound(1 + ((Constants.statsIncreaseFromLeveling - 1) * ((level - 1) / (Constants.maxLevel - 1))), 1);

		this.maxHp.value = Std.int(data.stat_maxHp * levelMult);
		this.maxMp.value = Std.int(data.stat_maxMp * levelMult);
		this.speed.value = Std.int(data.stat_speed * levelMult);
		this.attack.value = Std.int(data.stat_attack * levelMult);
		this.sattack.value = Std.int(data.stat_sattack * levelMult);

		this.hp = new Stat("hp", maxHp.value, 0, maxHp.value);
		this.mp = new Stat("mp", maxMp.value, 0, maxMp.value);

		if(placedByPlayer && controllable){
			if(Save.savedUnitHP.exists(unitID)){
				hp.value = Save.savedUnitHP.get(unitID);
			}
			if(Save.savedUnitMP.exists(unitID)){
				mp.value = Save.savedUnitMP.get(unitID);
			}
		}

		stats = [maxHp, maxMp, speed, hp, mp, attack, sattack];

		lastHp = hp.value;
		lastMp = hp.value;
	}
	
	function applySkills():Void
	{
		for (i in 0...data.skills.length)
		{
			var skill = new SkillData(data.skills[i]);

			if(i == 0){
				skill.mpCost = 0;
			}
			
			skills.push(skill);
		}
	}
	
    function applyGraphic():Void{
		var path = Constants.unitGridGraphicPath + data.gridGraphic + '.png';

		if (Assets.exists(path))
		{
			createFromImage(path);
		}
		else
		{
			FlxG.log.error("Can't find unit grid graphic \"" + path + "\".");
			createColorBlock(40, 40, FlxColor.BLUE);
		}        
		antialiasing = false;
    }

	public function doEntranceAnimation():Void
	{
		lerpManager.lerpScaleX = true;
		lerpManager.lerpScaleY = true;
		lerpManager.targetScale.set(1, 1);
		scale.set(10, 10);
	}
	public function changeStat(name:String, amount:Int):Void
	{
		for (stat in stats)
		{
			if (stat.name == name)
			{
				stat.changeValue(amount);
				return;
			}
		}

		FlxG.log.error("Can't change stat \"" + name + "\". It doesn't exist!");
	}
	public function takeDamage(amount:Int):Void
	{
		var transactionName = uniqueUnitID + "_" + "damageAnim";
		
		if (amount < 0)
		{
			heal(amount);
			return;
		}
		
		PlayState.eventManager.finishTransaction(transactionName);
		var transaction = PlayState.eventManager.startTransaction(transactionName);
		changeStat("hp", -amount);
		if (hp.value == 0)
		{
			dead = true;
		}
		FlxFlicker.flicker(this, .5, 0.03, true, true, function(f):Void
		{
			PlayState.eventManager.finishTransaction(transactionName);
		});
		cast(FlxG.state, PlayState).damageTextSignal.dispatch(this, "- " + Std.string(amount), FlxColor.RED);
	}

	public function heal(amount:Int):Void
	{
		if (dead)
			return;
		
		var transactionName = uniqueUnitID + "_" + "healAnim";

		if (amount < 0)
		{
			takeDamage(amount);
			return;
		}
		
		PlayState.eventManager.finishTransaction(transactionName);
		var transaction = PlayState.eventManager.startTransaction(transactionName);
		changeStat("hp", amount);
		FlxFlicker.flicker(this, .2, 0.01, this.visible, function(f):Void // placeholder
		{
			PlayState.eventManager.finishTransaction(transactionName);
		});
		cast(FlxG.state, PlayState).damageTextSignal.dispatch(this, "+ " + Std.string(amount), FlxColor.LIME);
	}
	public function applyStatusEffect(id:String, turns:Int):Void
	{
		var statusData = new StatusEffect(id, turns);

		var previousData = getStatusByName(id);
		if (previousData != null)
		{
			if (previousData.turns < turns)
			{
				previousData.turns = turns;
				previousData.changeTurns(0);
			}
		}
		else
		{
			statuses.push(statusData);
			onStatusChanged.dispatch(statuses);
		}

		doStatusEffectAnim(statusData.id);

		statusData.finished.add(function():Void
		{
			statuses.remove(statusData);
			onStatusChanged.dispatch(statuses);
		});
	}

	public function getStatusByName(id:String):StatusEffect
	{
		for (i in statuses)
		{
			if (i.id == id)
			{
				return i;
			}
		}
		return null;
	}

	public function doStatusEffectAnim(id:String, showText:Bool = true):Void
	{
		var status = getStatusByName(id);

		if (status != null)
		{
			var transactionName = uniqueUnitID + "_" + "statusAnim_" + status.id;

			var transaction = PlayState.eventManager.startTransaction(transactionName);

			if(showText) cast(FlxG.state, PlayState).damageTextSignal.dispatch(this, status.data.text, status.data.color);

			var statusEffectAnim = new StatusEffectAnim(this, status);
			this.shader = statusEffectAnim;
			statusEffectAnim.finished.add(function():Void
			{
				PlayState.eventManager.finishTransaction(transactionName);
				this.shader = null;
			});
		}
	}
	public static function getListOfUnits():Array<String>
	{
		return CtUtil.stripTextFromStrings(CtUtil.findFilesInPath(Constants.unitDataFolder, [".json"], false, false), ["unit_", ".json"]);
	}
	public static function getListOfUnlockedUnits():Array<String>
	{
		var list = getListOfUnits();

		var trueList = [];

		for(unit in list){
			if(Save.unlockedUnits.get(unit)) trueList.push(unit);
		}

		return(trueList);
	}
}