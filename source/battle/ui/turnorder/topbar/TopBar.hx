package battle.ui.turnorder.topbar;

class TopBar extends FlxSpriteGroup
{
    var incomingCalls:CtSprite;

    var unitDisplaySprites:Array<FlxSprite> = [];
    var topBarTalkerAnimPath:CtSprite;
    var topText:CtText;
    var levelText:CtText;

    var hpBar:TopBarStatDisplay;
    var mpBar:TopBarStatDisplay;

    var curUnit:Unit;
    var turnOrderDisplay:TurnOrderDisplay;

    public function new(turnOrderDisplay:TurnOrderDisplay):Void{
        super();

        this.turnOrderDisplay = turnOrderDisplay;
        
        incomingCalls = new CtSprite().createFromImage(Constants.turnOrderDisplayIncomingCallsGraphicPath);
		add(incomingCalls);

        // setup unit display

        topBarTalkerAnimPath = new CtSprite(50, turnOrderDisplay.upperBar.y + turnOrderDisplay.upperBar.height - 2).createFromSparrow(Constants.topBarTalkerAnimPath + ".png", Constants.topBarTalkerAnimPath + ".xml");
        topBarTalkerAnimPath.animation.addByPrefix("idle", "idle", 2);
        topBarTalkerAnimPath.animation.play("idle");
        topBarTalkerAnimPath.lerpManager.lerpX = true;
        topBarTalkerAnimPath.lerpManager.lerpSpeed = 5;
        topBarTalkerAnimPath.lerpManager.targetPosition.x = 50;
        add(topBarTalkerAnimPath);

        topText = new CtText(20, 5);
        topText.setFormat(Constants.fontName, 50, FlxColor.BLACK);
        topText.antialiasing = false;
        add(topText);

        levelText = new CtText(20, 20);
        levelText.setFormat(Constants.fontName, 35, FlxColor.GRAY);
        levelText.antialiasing = false;
        add(levelText);

        hpBar = new TopBarStatDisplay(20, 60, Constants.color_hp, Constants.color_hpLoss, "HP");
        add(hpBar);

        mpBar = new TopBarStatDisplay(20, 115, Constants.color_mp, Constants.color_mpLoss, "MP");
        add(mpBar);

        unitDisplaySprites = [topBarTalkerAnimPath, topText, levelText, hpBar, mpBar];

        updateCurrentUnit(null);
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        updateBars();
    }

    public function updateCurrentUnit(unit:Unit):Void{
        this.curUnit = unit;
        
		if (unit != null){
            incomingCalls.visible = false;

            for(spr in unitDisplaySprites){
                spr.visible = true;
            }

            topBarTalkerAnimPath.animation.play("idle");
            topBarTalkerAnimPath.x = 35;

            turnOrderDisplay.upperBar.createFromImage(Constants.turnOrderDisplayUpperBarGraphicPath);
            turnOrderDisplay.upperBar.setGraphicSize(Constants.turnOrderDisplayStartingX, turnOrderDisplay.upperBar.height);
            turnOrderDisplay.upperBar.updateHitbox();
            turnOrderDisplay.upperBar.x = 0;

            topText.text = unit.data.name;
            levelText.text = "LVL " + unit.level;
            levelText.setPosition(topText.x + topText.width + 20, topText.y + topText.height - levelText.height);

            hpBar.changeWidth(Constants.topBarStatDisplayMinWidth + curUnit.maxHp.value);
            mpBar.changeWidth(Constants.topBarStatDisplayMinWidth + curUnit.maxMp.value);

            updateBars();
        } else {
            incomingCalls.visible = true;

            for(spr in unitDisplaySprites){
                spr.visible = false;
            }

            topBarTalkerAnimPath.animation.pause();

            turnOrderDisplay.upperBar.createFromImage(Constants.turnOrderDisplayUpperBarDarkGraphicPath);
            turnOrderDisplay.upperBar.setGraphicSize(Constants.turnOrderDisplayStartingX, turnOrderDisplay.upperBar.height);
            turnOrderDisplay.upperBar.updateHitbox();
            turnOrderDisplay.upperBar.x = 0;
        }
    }

    function updateBars():Void{
        if(curUnit != null){
            hpBar.updateValues(curUnit.hp.value, curUnit.maxHp.value);
            mpBar.updateValues(curUnit.mp.value, curUnit.maxMp.value);
        }
    }
}