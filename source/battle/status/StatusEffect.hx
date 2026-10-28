package battle.status;

class StatusEffect
{
    public var id:String;
    
    public var data:StatusEffectData;
    
    public var turns:Int = 0;
    
	public var maxTurns:Int = 0;

	public var finished = new FlxSignal();
	public var changed = new FlxTypedSignal<StatusEffect->Void>();

    public function new(id:String, turns:Int):Void{
        this.id = id;
        
        this.data = Registry.get(StatusEffectData, id);
        
        this.turns = turns;
		this.maxTurns = turns;        
    }
    
    public function changeTurns(amount:Int):Void{
        turns = Std.int(FlxMath.bound(turns + amount, 0));
        
		if (turns > maxTurns)
			maxTurns = turns;

		changed.dispatch(this);
        
        if(turns == 0){
            finished.dispatch();
        }
    }
    
    public static function mapStatusParams(data:Dynamic):Array<StatusParams>{
        if(data == null){
            return([]);
        }
        return(data.map(function(item)
        {
            return {
				id: item.id,
                turns: item.turns
            };
        }));
    }
}