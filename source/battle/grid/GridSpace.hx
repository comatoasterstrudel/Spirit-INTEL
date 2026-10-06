package battle.grid;

class GridSpace extends FlxTypedGroup<CtSprite>{
    /**
     * the position of this grid space on a grid.
     * Ex: (0, 0) - At the top left of the grid
     */
    public var position:FlxPoint;
    
    /**
     * this is the sprite used to position this grid space. should be invisible
     */
    public var baseSprite:CtSprite;
    
    /**
     * this is used to track where the base sprite of this grid space was last frame. if the grid space moves, this grid space will reposition all of its sprites.
     */
    var lastBaseSpritePosition:FlxPoint;
    
    var outlineSprite:CtSprite;
    
	public var fillSprite:CtSprite;
    
	var flashingSprite:CtSprite;

	var flashSpriteTween:FlxTween;
    
    public var unit:Unit;
    
    var lastOccupied:Bool = false;
    
	var lastAlpha:Float = 0;
    
	public var grid:Grid;

	public var colorTween:FlxTween;
    
	public function new(position:FlxPoint, grid:Grid)
	{
        super();
        
        this.position = position;
		this.grid = grid;
        
        baseSprite = new CtSprite().createColorBlock(Constants.gridSize, Constants.gridSize, FlxColor.BLACK);
        baseSprite.visible = false;
        add(baseSprite);
        
        lastBaseSpritePosition = FlxPoint.get();
        
        final outlineSpriteSize:Int = Std.int(Constants.gridSize / 1.2);
        
        outlineSprite = new CtSprite().createColorBlock(outlineSpriteSize, outlineSpriteSize, FlxColor.BLACK);
        add(outlineSprite);
        
        final fillSpriteSize:Int = Std.int(Constants.gridSize / 1.4);
        
        fillSprite = new CtSprite().createColorBlock(fillSpriteSize, fillSpriteSize, FlxColor.WHITE);
        add(fillSprite);
        
		flashingSprite = new CtSprite().createColorBlock(fillSpriteSize, fillSpriteSize, FlxColor.BLACK);
		add(flashingSprite);
        
        updateGridSprites(true);
		toggleFlashSprite(false);
    }
    
    override function update(elapsed:Float){
        super.update(elapsed);
        
        updateGridSprites();
    }
    
    /**
     * call this to update the positions of the sprites on this grid space!!
     * @param force should this happen no matter what?
     */
    public function updateGridSprites(force:Bool = false):Void{
		if (!force
			&& (lastBaseSpritePosition.x == baseSprite.x && lastBaseSpritePosition.y == baseSprite.y)
			&& (lastOccupied == (unit != null) && (lastAlpha == baseSprite.alpha)))
		{
            return;
        }
        
        CtUtil.centerSpriteOnSprite(outlineSprite, baseSprite, true, true);
        CtUtil.centerSpriteOnSprite(fillSprite, baseSprite, true, true);
		CtUtil.centerSpriteOnSprite(flashingSprite, baseSprite, true, true);

		outlineSprite.alpha = baseSprite.alpha;
		fillSprite.alpha = baseSprite.alpha;
        
        if(unit != null) {
			unit.alpha = baseSprite.alpha;
            unit.lerpManager.targetPosition.x = baseSprite.x + baseSprite.width / 2 - unit.width / 2;
            unit.lerpManager.targetPosition.y = baseSprite.y + baseSprite.height / 2 - unit.height / 2;
        }
        
        lastBaseSpritePosition.set(baseSprite.x, baseSprite.y);
        lastOccupied = (unit != null);
		lastAlpha = baseSprite.alpha;
    }
	public function toggleFlashSprite(visibility:Bool):Void
	{
		if (flashSpriteTween != null)
		{
			flashSpriteTween.cancel();
			flashSpriteTween.destroy();
		}

		flashingSprite.visible = visibility;

		if (visibility)
		{
			flashingSprite.alpha = .1;
			flashSpriteTween = FlxTween.tween(flashingSprite, {alpha: .25}, .3, {type: PINGPONG});
		}
	}
	public function changeColor(color:FlxColor):Void
	{
		if (colorTween != null && colorTween.active)
		{
			colorTween.cancel();
		}

		colorTween = FlxTween.color(fillSprite, .5, fillSprite.color, color);
	}
}