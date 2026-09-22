package battle.ui.bottombar;

class UnitPortrait extends CtSprite
{
    public var unit:Unit;
    
	var outline:UnitPortraitOutlineEffect;

    public function new():Void{
        super();
        
        lerpManager.lerpX = true;
		lerpManager.lerpSpeed = 8;
        
        antialiasing = false;
		visible = false;

		outline = new UnitPortraitOutlineEffect();

		this.shader = outline;
		
    }
     
    override function update(elapsed:Float):Void{
        super.update(elapsed);        
    }
    
    public function applyUnitGraphic(unit):Void{
        this.unit = unit;
        
		var graphicPath:String = "";

		if(unit.controllable){
			graphicPath = unit.data.uiGraphicAlly;
		} else {
			graphicPath = unit.data.uiGraphicEnemy;
		}

        var path = Constants.unitUiGraphicPath + graphicPath + '.png';

		if (Assets.exists(path))
		{
			createFromImage(path);
		}
		else
		{
			FlxG.log.error("Can't find unit ui graphic \"" + path + "\".");
			createColorBlock(300, 350, FlxColor.BLUE);
		}        

		updateHitbox();
		setPosition(150 - width / 2, FlxG.height - height);
		visible = true;

		lerpManager.targetPosition.set(this.x, this.y);

		this.x -= 30;

		outline.updateValues(unit.data.isBoss ? FlxColor.RED : FlxColor.WHITE, 2, 2);
	}
}