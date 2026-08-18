package battle.grid.gridunitplacer;

class SpBar extends FlxSpriteGroup
{
    public var text:CtText;
    public var bar:FlxBar;
    public var barGraphic:SpBarGraphic;
    public var barShadow:SpBarGraphic;

    var targetProgress:Float = 1;
    var progress:Float = 1;

    var fadeTween:FlxTween;

    var shakeTween:FlxTween;

    public function new():Void{
        super();

        var barHeight:Int = Std.int(Constants.spBarBaseHeight + ((Constants.spBarMaxHeight - Constants.spBarBaseHeight) * (Save.levelRobin.getLevel() / Constants.maxLevel)));

        bar = new FlxBar(0,0, BOTTOM_TO_TOP, 62, barHeight, this, "progress", 0, 1);
        bar.createFilledBar(Constants.color_spLoss, Constants.color_sp);

        barShadow = new SpBarGraphic(bar, SHADOW);
        add(barShadow);

        add(bar);

        barGraphic = new SpBarGraphic(bar, NORMAL);
        add(barGraphic);

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
        bar.x = FlxG.width - bar.width - 70;
        bar.screenCenter(Y);
        alignSprites();
    }

    function alignSprites():Void{
        CtUtil.centerSpriteOnSprite(text, bar, true, true);
        text.alpha = bar.alpha;
        text.offset.x = bar.offset.x;
    }

    public function updateSp(value:Int, max:Int, ?snap:Bool = false):Void{
        targetProgress = value/max;
        if(snap) progress = targetProgress;

        text.text = value + "\n/\n" + max;

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

    public function doAngry():Void{
        resetShakeTween();
        shakeTween = FlxTween.shake(bar, 0.05, 0.1, X);
        for(theGraphic in [barGraphic, barShadow]){
            theGraphic.top.animation.play("angry");
            theGraphic.toggleBad(true);
        }
    }

    public function doNormal():Void{
        resetShakeTween();
        for(theGraphic in [barGraphic, barShadow]){
            theGraphic.top.animation.play("normal");
            theGraphic.toggleBad(false);
        }
    }

    public function resetShakeTween():Void{
        if(shakeTween != null){
            shakeTween.cancel();
            shakeTween.destroy();
        }
    }
}