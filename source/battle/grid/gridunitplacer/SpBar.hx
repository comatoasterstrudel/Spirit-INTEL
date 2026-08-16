package battle.grid.gridunitplacer;

class SpBar extends FlxSpriteGroup
{
    public var text:CtText;
    public var bar:FlxBar;

    var targetProgress:Float = 1;
    var progress:Float = 1;

    var fadeTween:FlxTween;

    public function new():Void{
        super();

        var barHeight:Int = Std.int(Constants.spBarBaseHeight + ((Constants.spBarMaxHeight - Constants.spBarBaseHeight) * (Save.levelRobin.getLevel() / Constants.maxLevel)));

        bar = new FlxBar(0,0, BOTTOM_TO_TOP, 120, barHeight, this, "progress", 0, 1);
        bar.createFilledBar(Constants.color_spLoss, Constants.color_sp);
        add(bar);

        text = new CtText();
        text.setFormat(Constants.fontName, 35, Constants.color_sp.getDarkened(.25), CENTER, SHADOW, Constants.color_spLoss.getDarkened(.5));
        add(text);

        bar.alpha = 0;
        positionBar();
    }

    override function update(elapsed:Float):Void{
        progress = CtUtil.lerpThing(progress, targetProgress, elapsed);

        alignSprites();

        super.update(elapsed);
    }

    function positionBar():Void{
        bar.x = FlxG.width - bar.width - 50;
        bar.screenCenter(Y);
        alignSprites();
    }

    function alignSprites():Void{
        CtUtil.centerSpriteOnSprite(text, bar, true, false);
        text.y = bar.y + bar.height - text.height - 20;
        text.alpha = bar.alpha;
    }

    public function updateSp(value:Int, max:Int, ?snap:Bool = false):Void{
        targetProgress = value/max;
        if(snap) progress = targetProgress;

        text.text = "SP\n" + value + " / " + max;

        alignSprites();
    }

    public function doFadeIn():Void{
        positionBar();
        bar.x += 35;

        cancelFadeTween();
        fadeTween = FlxTween.tween(bar, {alpha: 1, x: bar.x - 35}, .8, {ease: FlxEase.quartOut});
    }

    public function doFadeOut():Void{
        cancelFadeTween();
        fadeTween = FlxTween.tween(bar, {alpha: 0, x: bar.x + 35}, .5, {ease: FlxEase.quartOut});
    }

    function cancelFadeTween():Void{
        if(fadeTween != null){
            fadeTween.cancel();
            fadeTween.destroy();
        }
    }
}