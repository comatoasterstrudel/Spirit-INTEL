package battle.grid;

class Grid extends FlxTypedGroup<GridSpace>
{
    /**
     * The size of this battle grid.
     * Ex. (4,4) - A 4 tile wide 4 tile tall grid.
     */
	public var size:FlxPoint;
    
    var position:FlxPoint;
    
	public var spaces:Array<GridSpace> = [];
    
    var units:Array<Unit> = [];
    
    public function new(size:FlxPoint, position:FlxPoint){
        super();
        
        this.size = size;
        
        for(xSpace in 0...Std.int(size.x)){
            for(ySpace in 0...Std.int(size.y)){
				var gridSpace = new GridSpace(FlxPoint.get(xSpace, ySpace), this);
                gridSpace.baseSprite.setPosition(position.x + (Constants.gridSize * xSpace), position.y + (Constants.gridSize * ySpace));
                gridSpace.updateGridSprites();
                add(gridSpace);
                
                spaces.push(gridSpace);
            } 
        }
    }
    
    public function placeUnit(unit:Unit):Void{
        if(units.contains(unit)){
            return;
        }
        
        units.push(unit);
        
        updateUnits();
		unit.lerpManager.snap();
    }
    
    function updateUnits():Void{
        for(space in spaces){
            space.unit = null;    
        }
        
        for(unit in units){
            var space = getGridSpaceFromGrid(this, unit.position);
            space.unit = unit;
            space.updateGridSprites();
        }
    }
    
	public function updateHighlightedSpace(color:FlxColor, unit:Unit)
	{
		for (space in spaces)
		{
			if (unit != null && space.unit != null && space.unit.uniqueUnitID == unit.uniqueUnitID)
			{
				space.changeColor(color);
			}
			else
			{
				space.changeColor(FlxColor.WHITE);
			}
		}
	}
    
	public function updateFlashingSprites(spaces:Array<GridSpace>, ?overwrite:Bool = true):Void
	{
		for (space in this.spaces)
		{
			if (spaces.contains(space))
			{
				space.toggleFlashSprite(true);
			}
			else
			{
				if (overwrite)
					space.toggleFlashSprite(false);
			}
		}
	}
    
    public static function getGridSpaceFromGrid(grid:Grid, position:FlxPoint):GridSpace
    {
        for(space in grid.spaces){
            if(CtUtil.compareFlxPoints(space.position, position)) return space;
        }
        
        return null;
    }
    
    public static function calculateGridSize(size:FlxPoint):FlxPoint{
        return FlxPoint.get(Constants.gridSize * size.x, Constants.gridSize * size.y);
    }
}