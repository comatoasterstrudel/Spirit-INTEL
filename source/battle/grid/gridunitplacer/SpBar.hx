package battle.grid.gridunitplacer;

class SpBar extends FlxSpriteGroup
{
    public var text:CtText;
    public var bar:FlxBar;

    var targetProgress:Float = 1;
    var progress:Float = 1;

    public function new():Void{
        super();

        var barHeight:Int = Std.int(Constants.spBarBaseHeight + ((Constants.spBarMaxHeight - Constants.spBarBaseHeight) * (Save.levelRobin.getLevel() / Constants.maxLevel)));

        bar = new FlxBar(0,0, BOTTOM_TO_TOP, 60, barHeight, this, "progress", 0, 1);
        bar.createFilledBar(Constants.color_spLoss, Constants.color_sp);
        add(bar);

        positionBar();
    }

    override function update(elapsed:Float):Void{
        progress = CtUtil.lerpThing(progress, targetProgress, elapsed);

        super.update(elapsed);
    }

    function positionBar():Void{
        bar.x = FlxG.width - bar.width - 30;
        bar.screenCenter(Y);
    }

    public function updateSp(value:Int, max:Int, ?snap:Bool = false):Void{
        targetProgress = value/max;
        if(snap) progress = targetProgress;
    }
}