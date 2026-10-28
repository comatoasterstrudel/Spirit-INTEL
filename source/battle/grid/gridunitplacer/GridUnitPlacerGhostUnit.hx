package battle.grid.gridunitplacer;

class GridUnitPlacerGhostUnit extends CtSprite
{
    public var unit:String;
    
    public function new(unit:String, space:GridSpace):Void{
        super();
        
        this.unit = unit;
        
        createFromImage(Constants.unitGridGraphicPath + Registry.get(UnitData, unit).gridGraphic + ".png");

        CtUtil.centerSpriteOnSprite(this, space.baseSprite, true, true);
        
        lerpManager.lerpScaleX = true;
		lerpManager.lerpScaleY = true;
		lerpManager.targetScale.set(1, 1);
		scale.set(10, 10);
        lerpManager.lerpSpeed = 8;
        
        antialiasing = false;
    }
}