package battle.ui.statuseffectbar;

class StatusEffectIcon extends FlxSpriteGroup
{
    var unit:Unit;
    
	public var status:StatusEffect;

    public var baseSprite:CtSprite;
    
    public var whiteSprite:CtSprite;
    
	public var fillSprite:CtSprite;
    
    public var iconSprite:CtSprite;

    public function new(unit:Unit):Void{
        super();
        
        this.unit = unit;
        
        baseSprite = new CtSprite().createColorBlock(19, 19, FlxColor.BLACK);
        add(baseSprite);
        
        whiteSprite = new CtSprite().createColorBlock(15, 15, FlxColor.WHITE);
        add(whiteSprite);
        
		fillSprite = new CtSprite().createColorBlock(15, 15, FlxColor.BLACK);
		fillSprite.alpha = .4;
		add(fillSprite);
        
        iconSprite = new CtSprite(0,0, false);
        add(iconSprite);
        
        kill();
    }
    
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (sprite in [baseSprite, whiteSprite, iconSprite])
		{
			sprite.alpha = unit.alpha;
			sprite.visible = unit.visible;
		}
	}
    
    public function updateStatus(status:StatusEffect):Void{
		if (this.status != null)
			this.status.changed.remove(updateFillSprite);

		this.status = status;

		this.status.changed.add(updateFillSprite);

		updateFillSprite(this.status);
        
        whiteSprite.color = status.data.color;
        
        var path = Constants.statusEffectIconPath + status.data.iconGraphic + '.png';
        
        if (Assets.exists(path))
        {
            iconSprite.createFromImage(path);
        }
        else
        {
            FlxG.log.error("Can't find status icon graphic \"" + path + "\".");
            iconSprite.createColorBlock(15, 15, FlxColor.BLUE);
        }        
    }
    
    public function updateSpritesPosition():Void{
        CtUtil.centerSpriteOnSprite(whiteSprite, baseSprite, true, true);
        CtUtil.centerSpriteOnSprite(iconSprite, baseSprite, true, true);
		updateFillSprite(status);
	}

	public function updateFillSprite(status:StatusEffect):Void
	{        
		fillSprite.setGraphicSize(15, FlxMath.bound(15 * (1 - (status.turns / status.maxTurns)), 1, 15));
		fillSprite.updateHitbox();
		CtUtil.centerSpriteOnSprite(fillSprite, baseSprite, true, false);
		fillSprite.y = whiteSprite.y;
	}
}