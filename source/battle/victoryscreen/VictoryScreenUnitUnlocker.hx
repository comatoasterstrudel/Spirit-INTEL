package battle.victoryscreen;

class VictoryScreenUnitUnlocker extends FlxSpriteGroup
{
    var units:Array<String> = [];
    var progress:Int = 0;

    public var readySignal = new FlxSignal();
    public var finishedSignal = new FlxSignal();

    public var bg_topLeft:CtSprite;
    public var bg_top:CtSprite;
    public var bg_topRight:CtSprite;
    public var bg_midLeft:CtSprite;
    public var bg:CtSprite;
    public var bg_midRight:CtSprite;
    public var bg_bottomLeft:CtSprite;
    public var bg_bottom:CtSprite;
    public var bg_bottomRight:CtSprite;

    var spiritUnlocked:CtSprite;

    var unitPortrait:CtSprite;

    var unitText:CtText;
    var lvlText:CtText;

    public function new():Void{
        super();

        initBg();

        spiritUnlocked = new CtSprite().createFromImage(Constants.vsSpiritUnlocked);
        spiritUnlocked.antialiasing = false;
        spiritUnlocked.kill();
        add(spiritUnlocked);

        unitPortrait = new CtSprite();
        unitPortrait.antialiasing = false;
        unitPortrait.kill();
        add(unitPortrait);

        unitText = new CtText();
        unitText.setFormat(Constants.fontName, 50, FlxColor.BLACK);
        unitText.kill();
        add(unitText);

        lvlText = new CtText();
        lvlText.setFormat(Constants.fontName, 40, FlxColor.GRAY);
        lvlText.kill();
        add(lvlText);
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        updateBg();
    }

    public function setUnits(units:Array<String>):Void{
        this.units = units;
        progress = 0;
    }

    public function fadeIn():Void{
        bg.revive();
        bg.x -= 50;
        bg.alpha = 0;

        FlxTween.tween(bg, {x: bg.x + 50, alpha: 1}, .75, {ease: FlxEase.quartOut, onComplete: function(f):Void{
            advance();
        }});
    }

    public function advance(amount:Int = 0):Void{
        progress += amount;

        if(progress >= units.length){
            finishedSignal.dispatch();
        } else {
            var wait:Float = 0.01;
            if(spiritUnlocked.alive && unitPortrait.alive && unitText.alive && lvlText.alive){
                wait = .6;

                for(spr in [spiritUnlocked, unitPortrait, unitText, lvlText]){
                    FlxTween.tween(spr, {alpha: 0}, .5, {onComplete: function(f):Void{
                        spr.kill();
                    }});
                }
            }

            new FlxTimer().start(wait, function(f):Void{
                spiritUnlocked.revive();
                CtUtil.centerSpriteOnSprite(spiritUnlocked, bg, true, true);
                spiritUnlocked.scale.set(4, 4);
                spiritUnlocked.alpha = 1;

                FlxTween.tween(spiritUnlocked, {x: bg.x + 100, y: bg.y + 30}, .4, {ease: FlxEase.quartInOut});

                FlxTween.tween(spiritUnlocked.scale, {x: 2, y: 2}, .4, {ease: FlxEase.backIn, onComplete: function(f):Void{
                    FlxTween.shake(spiritUnlocked, 0.1, .1, X);
                }});

                var unitData = new UnitData(units[progress]);
                
                unitPortrait.revive();
                unitPortrait.createFromImage(Constants.unitUiGraphicPath + unitData.uiGraphicAlly + ".png");
                unitPortrait.setPosition(bg.x + bg.width - unitPortrait.width, bg_bottom.y + bg_bottom.height - unitPortrait.height);
                unitPortrait.alpha = 0;

                unitPortrait.x -= 200;

                unitText.revive();
                unitText.text = unitData.name;
                unitText.setPosition(bg.x, bg.y + 250);
                unitText.alpha = 0;

                lvlText.revive();
                lvlText.text = "Lvl. " + Save.levelUnits.get(units[progress]).getLevel();
                lvlText.setPosition(unitText.x + unitText.width + 20, unitText.y + unitText.height - lvlText.height);
                lvlText.alpha = 0;

                new FlxTimer().start(1, function(f):Void{
                    FlxTween.tween(unitPortrait, {x: unitPortrait.x + 200, alpha: 1}, 1, {ease: FlxEase.quartOut});

                    for(txt in [unitText, lvlText]){
                        FlxTween.tween(txt, {x: txt.x + 30, alpha: 1}, 1, {ease: FlxEase.quartOut});
                    }
                });

                new FlxTimer().start(2.2, function(f):Void{
                    readySignal.dispatch();
                });
            });
        }
    }
    
    function initBg():Void{
        bg_topLeft = new CtSprite().createFromImage(Constants.vsUnitLevelUiBgCornerPath);
        bg_topLeft.alpha = 0;
        bg_topLeft.antialiasing = false;
        add(bg_topLeft);

        bg_topRight = new CtSprite().createFromImage(Constants.vsUnitLevelUiBgCornerPath);
        bg_topRight.alpha = 0;
        bg_topRight.flipX = true;
        bg_topRight.antialiasing = false;
        add(bg_topRight);

        bg_bottomLeft = new CtSprite().createFromImage(Constants.vsUnitLevelUiBgCornerPath);
        bg_bottomLeft.alpha = 0;
        bg_bottomLeft.flipY = true;
        bg_bottomLeft.antialiasing = false;
        add(bg_bottomLeft);

        bg_bottomRight = new CtSprite().createFromImage(Constants.vsUnitLevelUiBgCornerPath);
        bg_bottomRight.alpha = 0;
        bg_bottomRight.flipX = true;
        bg_bottomRight.flipY = true;
        bg_bottomRight.antialiasing = false;
        add(bg_bottomRight);

        bg_top = new CtSprite().createColorBlock(10,10,FlxColor.WHITE);
        bg_top.alpha = 0;
        add(bg_top);
        
        bg_midLeft = new CtSprite().createColorBlock(10,10,FlxColor.WHITE);
        bg_midLeft.alpha = 0;
        add(bg_midLeft);

        bg_midRight = new CtSprite().createColorBlock(10,10,FlxColor.WHITE);
        bg_midRight.alpha = 0;
        add(bg_midRight);

        bg_bottom = new CtSprite().createColorBlock(10,10,FlxColor.WHITE);
        bg_bottom.alpha = 0;
        add(bg_bottom);

        bg = new CtSprite().createColorBlock(700, 300, FlxColor.WHITE);
        bg.screenCenter();
        bg.y += 140;
        add(bg);

        bg.kill();
        bg.alpha = 0;
    }

    function updateBg():Void{
        bg_topLeft.setPosition(bg.x - bg_topLeft.width, bg.y - bg_topLeft.height);
        bg_topLeft.alpha = bg.alpha;

        bg_top.setGraphicSize(bg.width, bg_topLeft.height);
        bg_top.updateHitbox();
        bg_top.setPosition(bg_topLeft.x + bg_topLeft.width, bg_topLeft.y);
        bg_top.alpha = bg.alpha;

        bg_topRight.setPosition(bg_top.x + bg_top.width, bg_top.y);
        bg_topRight.alpha = bg.alpha;

        bg_midLeft.setGraphicSize(bg_topLeft.width, bg.height);
        bg_midLeft.updateHitbox();
        bg_midLeft.setPosition(bg_topLeft.x, bg_topLeft.y + bg_topLeft.height);
        bg_midLeft.alpha = bg.alpha;

        bg_midRight.setGraphicSize(bg_topLeft.width, bg.height);
        bg_midRight.updateHitbox();
        bg_midRight.setPosition(bg_topRight.x, bg_topLeft.y + bg_topLeft.height);
        bg_midRight.alpha = bg.alpha;

        bg_bottomLeft.setPosition(bg_topLeft.x, bg.y + bg.height);
        bg_bottomLeft.alpha = bg.alpha;

        bg_bottom.setGraphicSize(bg.width, bg_bottomLeft.height);
        bg_bottom.updateHitbox();
        bg_bottom.setPosition(bg_bottomLeft.x + bg_bottomLeft.width, bg_bottomLeft.y);
        bg_bottom.alpha = bg.alpha;

        bg_bottomRight.setPosition(bg_bottom.x + bg_bottom.width, bg_bottom.y);
        bg_bottomRight.alpha = bg.alpha;
    }
}