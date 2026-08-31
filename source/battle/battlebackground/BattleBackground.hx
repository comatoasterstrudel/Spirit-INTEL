package battle.battlebackground;

class BattleBackground extends FlxSpriteGroup
{
	public var data:BattleBackgroundData;
    
    public function new(id:String):Void{
        super();
        
        data = new BattleBackgroundData(id);
        
        for(sprite in data.sprites){            
            var spr = new CtSprite(sprite.x, sprite.y);
            add(spr);
            
            switch(sprite.type){
                case "color":
                    spr.createColorBlock(sprite.colorWidth, sprite.colorHeight, FlxColor.fromRGB(sprite.color[0], sprite.color[1], sprite.color[2], sprite.color[3]));
                case "graphic":
                    spr.createFromImage(Constants.battleBackgroundGraphicPath + sprite.graphic + ".png");
                default: 
                    //
            }
            
            spr.scale.set(sprite.scaleX, sprite.scaleY);
            spr.updateHitbox();
            
			spr.scrollFactor.set(sprite.scrollX, sprite.scrollY);    
            
            spr.alpha = sprite.alpha;
        }
    }
}