package battle.units;

class UnitBossEffect extends FlxSpriteGroup
{
    public var unit:Unit;

    var effectTimer:FlxTimer;
    var effectTween1:FlxTween;
    var effectTween2:FlxTween;

    var ended:Bool = false;

    public function new(unit:Unit):Void{
        super();

        this.unit = unit;

        doEffect();
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        if(unit != null){
            visible = unit.visible;
        }
    }

    function doEffect():Void{
        effectTimer = new FlxTimer().start(Constants.bossEffectDelay, function(f):Void{
            var spr = new CtSprite(unit.x, unit.y);
            spr.loadGraphicFromSprite(unit);
            spr.colorTransform.color = 0xFFFF0000;
            spr.alpha = .6;
            add(spr);

            effectTween1 = FlxTween.tween(spr.scale, {x: 2, y: 2}, Constants.bossEffectTime, {onUpdate: function(f):Void{
                if(spr != null && !ended){
                    spr.updateHitbox();
                    CtUtil.centerSpriteOnSprite(spr, unit, true, true);
                }
            }});

            effectTween2 = FlxTween.tween(spr, {alpha: 0}, Constants.bossEffectTime, {onComplete: function(f):Void{
                if(spr != null && !ended){
                    remove(spr);
                    spr.destroy();
                    spr = null;
                }
            }});

            doEffect();
        });
    }

    override function destroy():Void{
        ended = true;

        var removethese = [];

        for(spr in members){
            removethese.push(spr);
        }

        for(spr in removethese){
            remove(spr);
            spr.destroy();
            spr = null;
        }

        if(effectTimer != null){
            effectTimer.cancel();
            effectTimer.destroy();
            effectTimer = null;
        }

        if(effectTween1 != null){
            effectTween1.cancel();
            effectTween1.destroy();
            effectTween1 = null;
        }

        if(effectTween2 != null){
            effectTween2.cancel();
            effectTween2.destroy();
            effectTween2 = null;
        }

        super.destroy();
    }
}