package battle.victoryscreen;

class VictoryScreenUnitLevelCell extends FlxSpriteGroup
{
    public var unit:String = "";

    public var baseSprite:CtSprite;

    var unitIcon:CtSprite;
    var unitNameText:CtText;
    var levelText:CtText;

    var expBar:FlxBar;

    var lastExp:Float = -45;
    var lastLevel:Int = -5;

    var currentExp:Float = 100;
    var currentMaxExp:Int = 100;

    var progress:Float = 1;

    var victoryScreen:VictoryScreen;

    public function new(unit:String, victoryScreen:VictoryScreen):Void{
        super();

        lastLevel = Save.levelUnits.get(unit).getLevel();

        this.unit = unit;
        this.victoryScreen = victoryScreen;
        
        baseSprite = new CtSprite().createColorBlock(Std.int(Constants.vsUnitLevelUiCellWidth * .8), Std.int(Constants.vsUnitLevelUiCellHeight * .8), FlxColor.GRAY);
        baseSprite.visible = false;
        add(baseSprite);

        var unitData = new UnitData(unit);

        unitIcon = new CtSprite().createFromImage(Constants.unitGridGraphicPath + unitData.gridGraphic + ".png");
        unitIcon.antialiasing = false;
        add(unitIcon);

        unitNameText = new CtText(0,0,unitData.name);
        unitNameText.setFormat(Constants.fontName, 30, FlxColor.BLACK);
        unitNameText.antialiasing = false;
        add(unitNameText);

        expBar = new FlxBar(0,0,LEFT_TO_RIGHT, Std.int(baseSprite.width - unitIcon.width - 10), 20, this, "progress", 0, 1);
        expBar.createColoredFilledBar(FlxColor.BLUE, false);
        expBar.createColoredEmptyBar(FlxColor.BLACK, false);
        add(expBar);

        levelText = new CtText(0,0,"HAHA");
        levelText.setFormat(Constants.fontName, 20, FlxColor.BLACK);
        levelText.antialiasing = false;
        levelText.updateHitbox();
        add(levelText);

        while(unitNameText.width > expBar.width){
            unitNameText.scale.x -= 0.01;
            unitNameText.updateHitbox();    
        }

        alpha = 0;

        updateSpritePositions();
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        updateSpritePositions(elapsed);
    }

    public function doFadeIn():Void{
        FlxTween.tween(this, {alpha: 1}, 0.5);

        baseSprite.y -= 10;

        FlxTween.tween(baseSprite, {y: baseSprite.y + 10}, 0.5);
    }

    public function updateSpritePositions(elapsed:Float = 1):Void{
        unitIcon.setPosition(baseSprite.x, baseSprite.y + baseSprite.height / 2 - unitIcon.height / 2);

        expBar.setPosition(unitIcon.x + unitIcon.width + 5, baseSprite.y + baseSprite.height - (expBar.height + 5));

        unitNameText.y = (baseSprite.y);
        CtUtil.centerSpriteOnSprite(unitNameText, expBar, true, false);

        if(Save.levelUnits.get(unit).expFloat != lastExp){
            levelText.text = "LVL " + Save.levelUnits.get(unit).getLevel() + "\nNEXT: " + (Save.levelUnits.get(unit).getNextlevelExp());

            currentExp = Save.levelUnits.get(unit).getCurrentLevelExpFloat();
            currentMaxExp = CharacterLevel.getExpForNextLevel(Save.levelUnits.get(unit).getLevel());

            lastExp = Save.levelUnits.get(unit).expFloat;
        }

        progress = CtUtil.lerpThing(progress, (currentExp / currentMaxExp), elapsed, 10);

        levelText.setPosition(expBar.x + 10, expBar.y - levelText.height - 2);

        if(Save.levelUnits.get(unit).getLevel() > lastLevel){
            var unitLastLevel:Unit = new Unit(unit, null, FlxPoint.get(1,1), true, lastLevel, true);
            var unitCurLevel:Unit = new Unit(unit, null, FlxPoint.get(1,1), true, Save.levelUnits.get(unit).getLevel(), true);

            Save.savedUnitHP.set(unit, Save.savedUnitHP.get(unit) + (unitCurLevel.maxHp.value - unitLastLevel.maxHp.value));
            Save.savedUnitMP.set(unit, Save.savedUnitMP.get(unit) + (unitCurLevel.maxMp.value - unitLastLevel.maxMp.value));

            unitLastLevel.destroy();
            unitCurLevel.destroy();

            victoryScreen.textSignal.dispatch("LVL UP!", FlxColor.YELLOW, expBar);
            lastLevel = Save.levelUnits.get(unit).getLevel();
        }
    }
}