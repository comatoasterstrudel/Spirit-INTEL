package battle.ui.statuseffectbar;

class StatusEffectBar extends FlxTypedGroup<StatusEffectIcon>
{
    public var unit:Unit;
    
    var curStatuses:Array<StatusEffect> = [];
    
	var lastX:Float = 0;
	var lastY:Float = 0;
    
    public function new(unit:Unit):Void{
        this.unit = unit;
         
        super();
        
        unit.onStatusChanged.add(updateStatuses);
    }
    
    override function update(elapsed:Float):Void{
		super.update(elapsed);
        
		if (curStatuses.length > 0 && (unit.x != lastX || unit.y != lastY))
		{
			updateStatusIconPositions();
        }
    }
    
    public function updateStatuses(statuses:Array<StatusEffect>):Void{
        for(icon in members){
            icon.kill();
        }
        
        for(i in 0...statuses.length){
            var status = statuses[i];
            
            var icon = members[i];
            
            if(icon == null){
               icon = new StatusEffectIcon(unit); 
               add(icon);
            }
            
            icon.revive();
            
            icon.updateStatus(status);
        }
        
        curStatuses = statuses;
		updateStatusIconPositions();
	}

	function updateStatusIconPositions():Void
	{
		var iconsToCenter:Array<FlxSprite> = [];

		forEachAlive(function(icon):Void
		{
			iconsToCenter.push(icon.baseSprite);
		});
		CtUtil.centerGroup(iconsToCenter, 2, unit.x + unit.width / 2);
		forEachAlive(function(icon):Void
		{
			icon.baseSprite.y = unit.y - 35;
			icon.updateSpritesPosition();
		});
		lastX = unit.x;
		lastY = unit.y;
	}

    public function getIconByStatus(status:StatusEffect):StatusEffectIcon{
        for(icon in members){
            if(icon.status.id == status.id) return icon;
        }

        return null;
    }
}