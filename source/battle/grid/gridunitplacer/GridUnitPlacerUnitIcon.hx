package battle.grid.gridunitplacer;

class GridUnitPlacerUnitIcon extends FlxSpriteGroup
{    
    public var bg:CtSprite;
    public var unitGraphic:CtSprite;

    public var unit:String;
    public var xPos:Int;
    public var yPos:Int; 
    
    public var baseY:Float = 0;

    public var selected:Bool = false;

    public var placed:Bool = false;
    
    public function new (unit:String, x:Float, y:Float, xPos:Int, yPos:Int):Void{
        super();
        
        this.unit = unit;
        this.xPos = xPos;
        this.yPos = yPos;
                
        this.baseY = y;
        
        bg = new CtSprite(Std.int(x), Std.int(y)).createFromImage(Constants.gridUnitPlacerUnitBg);
        bg.lerpManager.targetPosition.set(x, y);
        bg.lerpManager.lerpY = true;
        add(bg);
        
        unitGraphic = new CtSprite().createFromImage(Constants.unitGridGraphicPath + new UnitData(unit).gridGraphic + ".png");
        unitGraphic.antialiasing = false;
        add(unitGraphic);
        
        updatePositions();
        
        updateSelected(false);
    }
    
    override function update(elapsed:Float):Void{
        super.update(elapsed);

        updatePositions();
    }

    function updatePositions():Void{
        CtUtil.centerSpriteOnSprite(unitGraphic, bg, true, true);
    }

    public function updateSelected(selected:Bool):Void{
        this.selected = selected;
        
        if(this.selected){
            bg.color = 0xFF626262;
        } else {
			bg.color = 0xFFDADADA;
        }
    }
    
    public function updatePlaced(placed:Bool):Void{
        this.placed = placed;
        
        if(this.placed){
            unitGraphic.visible = false;
        } else {
            unitGraphic.visible = true;
        }
    }
}