package battle.grid.gridunitplacer;

class SpBarGraphic extends FlxSpriteGroup{
    var bar:FlxBar;

    public var top:CtSprite;
    var mid:CtSprite;
    var bottom:CtSprite;

    var bad:CtSprite;

    var type:SpBarGraphicType;

    public var badEnabled:Bool = false;

    public function new(bar:FlxBar, type:SpBarGraphicType):Void{
        super();

        this.bar = bar;
        this.type = type;

        bad = new CtSprite().createFromImage(Constants.spBarBadPath);
        bad.antialiasing = false;
        bad.setGraphicSize(bad.width, bar.height);
        bad.updateHitbox();
        bad.color = FlxColor.BLACK;
        add(bad);

        top = new CtSprite().createFromSparrow((type == SHADOW ? Constants.spBarTopPathBlank : Constants.spBarTopPath) + ".png", Constants.spBarTopPath + ".xml");
        top.animation.addByPrefix("normal", "normal");
        top.animation.addByPrefix("angry", "angry");
        top.animation.play("normal");
        top.antialiasing = false;
        add(top);

        mid = new CtSprite().createFromImage(type == SHADOW ? Constants.spBarMidPathBlank : Constants.spBarMidPath);
        mid.antialiasing = false;
        mid.setGraphicSize(mid.width, bar.height - 47);
        mid.updateHitbox();
        add(mid);

        bottom = new CtSprite().createFromImage(type == SHADOW ? Constants.spBarBottomPathBlank : Constants.spBarBottomPath);
        bottom.antialiasing = false;
        bottom.color = Constants.color_sp.getLightened(.7);
        add(bottom);

        if(type == SHADOW){
            for(spr in [top, mid, bottom]){
                spr.color = Constants.color_sp.getDarkened(.8);
            }
        }

        alignSprites();
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        alignSprites();
    }

    function alignSprites():Void{ // sorry for magic numbers im kinda busy suckin my thumb #baby
        for(spr in [top, mid, bottom, bad]){
            CtUtil.centerSpriteOnSprite(spr, bar, true, false);
            spr.visible = bar.visible;
            spr.alpha = bar.alpha;
            spr.offset.x = bar.offset.x;
        }

        mid.y = bar.y + 23;
        top.y = mid.y - top.height;
        bottom.y = mid.y + mid.height;

        if(type == SHADOW){
            for(spr in [top, mid, bottom]){
                spr.x += 8;
                spr.y += 4;
            }
        }

        bad.visible = badEnabled;
        bad.alpha = .4;
        bad.y = bar.y;
    }

    public function toggleBad(enabled:Bool):Void{
        this.badEnabled = enabled;
        alignSprites();
    }
}