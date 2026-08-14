package overworld.playermenu.pages.unitselector;

class UnitSelectorBar extends FlxSpriteGroup
{
    public var bar:FlxBar;
    public var overlay:CtSprite;
    public var text:CtText;
    
    var progress:Float = 1;

    var prefix:String = "";

    var tab:UnitSelectorTab;
    var type:UnitSelectorBarType;

    public function new(type:UnitSelectorBarType, tab:UnitSelectorTab):Void{
        super();

        this.type = type;
        this.tab = tab;

        var fillColor:FlxColor = FlxColor.BLACK;
        var emptyColor:FlxColor = FlxColor.BLACK;

        switch(type){
            case HP:
                fillColor = Constants.color_hp;
                emptyColor = Constants.color_hpLoss;
                prefix = "HP";
            case MP:
                fillColor = Constants.color_mp;
                emptyColor = Constants.color_mpLoss;
                prefix = "MP";
        }

        var gap:Int = 20;

        bar = new FlxBar(0,0,LEFT_TO_RIGHT, Std.int((Constants.playerMenuUnitSelectorWidth / 2) - (gap)), 40, this, "progress", 0, 1);
        bar.createColoredEmptyBar(emptyColor);
        bar.createColoredFilledBar(fillColor);
        add(bar);

        overlay = new CtSprite().createFromImage(Constants.playerMenuUnitSelectorBarOverlayPath);
        overlay.antialiasing = false;
        add(overlay);

        text = new CtText();
        text.setFormat(Constants.fontName, 22, fillColor.getDarkened(.5), LEFT, SHADOW, fillColor.getDarkened(.7));
        add(text);

        refreshValues();
    }

    public function refreshValues():Void{
        var val:Int = 1;
        var maxVal:Int = 1;

        switch(type){
            case HP:
                val = tab.realUnit.hp.value;
                maxVal = tab.realUnit.maxHp.value;
            case MP:
                val = tab.realUnit.mp.value;
                maxVal = tab.realUnit.maxMp.value;

        }

        progress = val / maxVal;

        text.text = prefix + " " + val + " / " + maxVal;

        updatePosition();
    }

    public function updatePosition():Void{
        overlay.setPosition(bar.x, bar.y);

        text.x = bar.x + 10;
        CtUtil.centerSpriteOnSprite(text, bar, false, true);
    }
}