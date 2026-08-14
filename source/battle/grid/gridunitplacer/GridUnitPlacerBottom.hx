package battle.grid.gridunitplacer;

class GridUnitPlacerBottom extends FlxSpriteGroup
{
    var bottomSprite:CtSprite;

    var animTimer:FlxTimer;
    var animFrame:Int = 0;

    var bg:CtSprite;
    var status:GridUnitPlacerBottomStatus = NONE;

    // unit info

    // big text
    var bigText:CtText;

    public function new(bg:CtSprite):Void{
        super();

        this.bg = bg;

        bottomSprite = new CtSprite().createFromSparrow(Constants.gridUnitPlacerBubble + ".png", Constants.gridUnitPlacerBubble + ".xml");
        bottomSprite.alpha = 0;
        bottomSprite.antialiasing = false;
        for(anim in ["blank", "finish", "inspect", "reuse", "badreuse"]){
            bottomSprite.animation.addByPrefix(anim, anim, 1, true);
        }
        bottomSprite.x -= 30;
        bottomSprite.animation.play("blank");
        add(bottomSprite);
 
        animTimer = new FlxTimer().start(1, function(f):Void{
            if(animFrame == 0) animFrame = 1; else animFrame = 0;

            animTimer.reset(1);
        });

        // unit info

        // big text
        bigText = new CtText();
        bigText.fieldWidth = 300;
        bigText.setFormat(Constants.fontName, 60, FlxColor.BLACK, LEFT);
        add(bigText);

        updateVisibility();
    }

    override function draw():Void{
        bottomSprite.animation.curAnim.curFrame = animFrame;

        super.draw();
    }

    public function updateWithUnit(unit:String, placed:Bool, allowed:Bool):Void{
        status = UNIT;

        bottomSprite.animation.play("blank");

        updateVisibility();
    }

    public function updateWithText(text:String, ?icon:String = ""):Void{
        status = TEXT;

        bigText.text = text;
        bigText.setPosition(720, 580);

        if(icon == ""){
            bottomSprite.animation.play("blank");
        } else {
            bottomSprite.animation.play(icon);
        }

        updateVisibility();
    }

    public function updateVisibility():Void{
        if(status == UNIT){

        } else {

        }

        if(status == TEXT){
            bigText.visible = true;
        } else {
            bigText.visible = false;
        }
    }

    public function doFadeIn():Void{
        status = NONE;
        updateVisibility();
        bottomSprite.animation.play("blank");

        FlxTween.tween(bottomSprite, {alpha: 1}, 0.3);
    }

    public function doFadeOut():Void{
        status = NONE;
        updateVisibility();
        bottomSprite.animation.play("blank");

        FlxTween.tween(bottomSprite, {alpha: 0}, 0.3);
    }
}