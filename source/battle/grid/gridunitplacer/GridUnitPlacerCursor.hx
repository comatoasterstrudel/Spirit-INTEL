package battle.grid.gridunitplacer;

class GridUnitPlacerCursor extends FlxSpriteGroup
{
    var cursor:Cursor;
    
    var unitGraphic:CtSprite;
    
    public function new(cursor:Cursor):Void{
        super();
        
        this.cursor = cursor;
        
        unitGraphic = new CtSprite();
        unitGraphic.antialiasing = false;
        add(unitGraphic);
        
        antialiasing = false;
    }
    
    override function draw():Void{
        CtUtil.centerSpriteOnSprite(unitGraphic, cursor, true, true);        

        super.draw();        
    }
    
    public function updateUnit(unit:String):Void{
        unitGraphic.createFromImage(Constants.unitGridGraphicPath + Registry.get(UnitData, unit).gridGraphic + ".png");
    }
}