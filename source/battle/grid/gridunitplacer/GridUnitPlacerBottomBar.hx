package battle.grid.gridunitplacer;

class GridUnitPlacerBottomBar extends FlxSpriteGroup
{
    var type:GridUnitPlacerBottomBarType;

    var bar:FlxBar;

    var progress:Float = 1;

    public function new(type:GridUnitPlacerBottomBarType, y:Int):Void{
        super();
        
        this.type = type;

        bar = new FlxBar(720, y, LEFT_TO_RIGHT, 300, 30, this, "progress", 0, 1);
        
        switch(type){
            case HP:
                bar.createColoredFilledBar(Constants.color_hp);
                bar.createColoredEmptyBar(Constants.color_hpLoss);
            case MP:
                bar.createColoredFilledBar(Constants.color_mp);
                bar.createColoredEmptyBar(Constants.color_mpLoss);
        }

        add(bar);
    }
}