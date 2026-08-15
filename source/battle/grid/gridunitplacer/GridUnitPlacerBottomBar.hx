package battle.grid.gridunitplacer;

class GridUnitPlacerBottomBar extends FlxSpriteGroup
{
    var type:GridUnitPlacerBottomBarType;

    var bar:FlxBar;
    var text:CtText;

    var lEdge:CtSprite;
    var rEdge:CtSprite;

    var progress:Float = 1;

    public function new(type:GridUnitPlacerBottomBarType, y:Int):Void{
        super();
        
        this.type = type;

        bar = new FlxBar(720, y, LEFT_TO_RIGHT, 330, 40, this, "progress", 0, 1);
        
        var fillColor:FlxColor = FlxColor.WHITE;
        var emptyColor:FlxColor = FlxColor.BLACK;

        switch(type){
            case HP:
                fillColor = Constants.color_hp;
                emptyColor = Constants.color_hpLoss;
            case MP:
                fillColor = Constants.color_mp;
                emptyColor = Constants.color_mpLoss;
        }

        bar.createColoredFilledBar(fillColor);
        bar.createColoredEmptyBar(emptyColor);

        add(bar);

        text = new CtText(bar.x + 30, bar.y + 4);
        text.setFormat(Constants.fontName, 25, fillColor.getDarkened(.5), LEFT, SHADOW, fillColor.getDarkened(.7));
        text.antialiasing = false;
        add(text);

        lEdge = new CtSprite().createFromImage(Constants.gridUnitPlacerBarEdge);
        lEdge.antialiasing = false;
        add(lEdge);

        rEdge = new CtSprite().createFromImage(Constants.gridUnitPlacerBarEdge);
        rEdge.antialiasing = false;
        rEdge.flipX = true;
        add(rEdge);
    }

    public function updateWithUnit(unit:Unit):Void{
        var val:Int = 0;
        var max:Int = 100;

        switch(type){
            case HP:
                val = unit.hp.value;
                max = unit.maxHp.value;
            case MP:
                val = unit.mp.value;
                max = unit.maxMp.value;
        }

        bar.setGraphicSize(FlxMath.bound((160 + (val / 2)), 160, 330), bar.height);
        bar.updateHitbox();
        
        progress = val / max;

        var prefix:String = "";

        switch(type){
            case HP:
                prefix = "HP ";
            case MP:
                prefix = "MP ";
        }

        text.text = prefix + val + " / " + max;

        text.x = bar.x + 20;
        CtUtil.centerSpriteOnSprite(text, bar, false, true);

        lEdge.setPosition(bar.x, bar.y);
        rEdge.setPosition(bar.x + bar.width - rEdge.width, bar.y);
    }
}