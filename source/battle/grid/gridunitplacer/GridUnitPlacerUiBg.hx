package battle.grid.gridunitplacer;

class GridUnitPlacerUiBg extends FlxSpriteGroup
{
    var ogBg:CtSprite;
    
    var lastVisible:Bool = false;
    
    var tweens:Array<FlxTween> = [];
    
	var alphaArray:Array<Float> = [];
    
    public function new(ogBg:CtSprite):Void{
        super();
        
        this.ogBg = ogBg;       
        
        visible = false;
        
        for(spr in 0...Constants.gridUnitPlacerUiBgSpriteNum){
            var prog = 1 - FlxMath.bound(spr / (Constants.gridBackgroundSpriteNum - 1), 0, 1);
            
            var color:FlxColor = 0xFF9C9C9C;
            color = color.getDarkened(prog);
            
            var bg = new CtSprite(ogBg.x, ogBg.y).createColorBlock(Std.int(ogBg.width), Std.int(ogBg.height), color);
            var scroll:Float = 1 - prog;
            bg.ID = Constants.gridUnitPlacerUiBgSpriteNum - spr;
            bg.alpha = scroll;
            add(bg);  
			alphaArray.push(scroll);
        } 
    }
    
    override function update(elapsed:Float):Void{
        super.update(elapsed);
        
        if(!lastVisible && visible){
            startAnim();
        }
        
        lastVisible = visible;
    }
    
    function startAnim():Void{
        for(i in members){
            i.x = ogBg.x;
        }
        
        for(tween in tweens){
            tween.cancel();
            tween.destroy();
        }
        
        tweens = [];
        
        for(spr in members){
           tweens.push(FlxTween.tween(spr, {x: ogBg.x + (300 * (spr.ID / Constants.gridUnitPlacerUiBgSpriteNum))}, 5, {ease: FlxEase.quadInOut, type: PINGPONG}));
        }
		for (i in 0...members.length)
		{
			members[i].alpha = alphaArray[i];
		}
    }
}