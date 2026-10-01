package battle.ui.turnorder;

class TurnOrderIcon extends FlxSpriteGroup
{
    public var bg:CtSprite;
    
    public var unitGraphic:CtSprite;
    
	public var bgOutline:CtSprite;
		
	var curUnit:Unit;
    
	var ogColor:FlxColor = FlxColor.WHITE;
	 
	var targetLightening:Float = .8;
	var lightening:Float = .8;

	public var scaleFactor:Float = 1;
	
	public var uniqueID:Int = 0;

    public function new():Void{
        super();
        
		bg = new CtSprite();
        add(bg);
        
        unitGraphic = new CtSprite();
        add(unitGraphic);
        
		bgOutline = new CtSprite();
		add(bgOutline);
        
		bg.antialiasing = false;
		unitGraphic.antialiasing = false;
    }
    
    override function update(elapsed:Float):Void{
        super.update(elapsed);

		updateSpritePositions(elapsed);
    }
    
	public function updateTurnOrderIcon(unit:Unit):Void
	{
		this.curUnit = unit;
		bg.createFromImage(Constants.turnOrderIcon);
		bgOutline.createFromImage(Constants.turnOrderIconOutline);
		unitGraphic.loadGraphicFromSprite(curUnit);
		unitGraphic.scale.set(2,2);
		unitGraphic.updateHitbox();
		ogColor = curUnit.controllable ? FlxColor.LIME : FlxColor.RED;
		updateSpritePositions(1);
	}

	public function updateSpritePositions(elapsed:Float):Void
	{
		CtUtil.centerSpriteOnSprite(unitGraphic, bg, true, true);
		CtUtil.centerSpriteOnSprite(bgOutline, bg, true, true);

		lightening = CtUtil.lerpThing(lightening, targetLightening, elapsed, 12);

		bg.color = ogColor.getLightened(lightening);

		unitGraphic.alpha = FlxMath.bound(1 - lightening, 0.3, 1);
	}

	public function updateCurrentTurn(unit:Unit):Void
	{
		if (unit != null && curUnit.uniqueUnitID == unit.uniqueUnitID)
		{
			targetLightening = 0;
		}
		else
		{
			targetLightening = 0.9;
		}
	}

	public function updateCurrentTurnWithID(id:Int):Void
	{
		if (id == uniqueID)
		{
			targetLightening = 0;
		}
		else
		{
			targetLightening = 0.9;
		}
	}

	public function resize(scaleFactor:Float):Void
	{
		this.scaleFactor = scaleFactor;

		for (spr in [bg, bgOutline])
		{
			spr.scale.x = (scaleFactor);
			spr.updateHitbox();
		}

		unitGraphic.scale.x = scaleFactor + 1;

		updateSpritePositions(1);
	}
}