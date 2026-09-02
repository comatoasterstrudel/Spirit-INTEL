package battle.victoryscreen;

class VictoryScreen extends FlxSubState
{
    final stages = [EXP, UNLOCKUNITS, FINISH];
    var stage:Int = 0;

    var victoryCam:CtCamera;

    var bg:CtSprite;
    var topBar:CtSprite;
    var bottomBar:CtSprite;

    var topText:CtSprite;
    var unitLevelUi:VictoryScreenUnitLevelUi;
    var phone:VictoryScreenPhone;
    
    var unitUnlocker:VictoryScreenUnitUnlocker;

    var robinblank:CtSprite;
    var robin:CtSprite;

    var sparkles:CtSprite;

    var menuManager:CtMenuManager;
    var continueText:CtText;
    var cursor:Cursor;

    var unitsToAdd:Array<String> = [];
    var expReward:Int = 1;

    public var textSignal = new FlxTypedSignal<(String, FlxColor, FlxSprite)->Void>();
    
    var onComplete:Void->Void;

    var expUiEnabled:Bool = true;
    
    public function new (unitsToAdd:Array<String>, expReward:Int, onComplete:Void->Void){
        super();

        updateExpLevels();

        this.unitsToAdd = unitsToAdd;
        this.expReward = expReward;

        #if lotsOfResultsUnits
        this.unitsToAdd = ["chair", "partyhat", "chair", "chair", "partyhat", "chair", "chair"];
        #end
        #if forceResultsValues
        this.expReward = 100;
        #end

        this.onComplete = onComplete;

        victoryCam = new CtCamera();
        victoryCam.bgColor.alpha = 0;
        FlxG.cameras.add(victoryCam, false);

        bg = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.camera = victoryCam;
        bg.alpha = 0;
        add(bg);

        topBar = new CtSprite().createFromImage(Constants.vsBarPath);
        topBar.angle = 180;
        topBar.antialiasing = false;
        topBar.camera = victoryCam;
        topBar.setGraphicSize(FlxG.width, FlxG.height);
        topBar.updateHitbox();
        topBar.screenCenter();
        add(topBar);

        bottomBar = new CtSprite().createFromImage(Constants.vsBarPath);
        bottomBar.antialiasing = false;
        bottomBar.camera = victoryCam;
        bottomBar.setGraphicSize(FlxG.width, FlxG.height);
        bottomBar.updateHitbox();
        bottomBar.screenCenter();
        add(bottomBar);

        robinblank = new CtSprite().createFromImage(Constants.vsRobinBlankPath);
        robinblank.antialiasing = false;
        robinblank.camera = victoryCam;
        robinblank.screenCenter();
        robinblank.alpha = 0;
        robinblank.color = 0xFF110066;
        add(robinblank);

        robin = new CtSprite().createFromImage(Constants.vsRobinPath);
        robin.antialiasing = false;
        robin.camera = victoryCam;
        robin.screenCenter();
        robin.alpha = 0;
        robin.color = FlxColor.GRAY;
        add(robin);

        topText = new CtSprite().createFromImage(Constants.vsTopTextPath);
        topText.antialiasing = false;
        topText.camera = victoryCam;
        topText.alpha = 0;
        add(topText);

        unitLevelUi = new VictoryScreenUnitLevelUi(this.unitsToAdd, this);
        unitLevelUi.camera = victoryCam;
        add(unitLevelUi);

        phone = new VictoryScreenPhone(this);
        phone.camera = victoryCam;
        add(phone);

        unitUnlocker = new VictoryScreenUnitUnlocker();
        unitUnlocker.camera = victoryCam;
        add(unitUnlocker);

        sparkles = new CtSprite().createFromSparrow(Constants.vsSparklesPath + ".png", Constants.vsSparklesPath + ".xml");
        sparkles.animation.addByPrefix("idle", "idle", 1);
        sparkles.animation.play("idle");        
        sparkles.camera = victoryCam;
        sparkles.alpha = 0;
        add(sparkles);

        textSignal.add(addFloatingText);

        setupMenuManager();

        doFadeIn();

        new FlxTimer().start(3.5, function(f):Void{
            distributeExp(this.expReward, function():Void{
                new FlxTimer().start(.5, function(f):Void{
                    continueText.visible = true;
                    menuManager.enable();
                });
            });
        });
    }
    
    override function update(elapsed:Float):Void{
        super.update(elapsed);

        menuManager.update();
    }

    function addFloatingText(text:String, color:FlxColor, baseSprite:FlxSprite):Void{
        var floatingText = new VictoryScreenFloatingText(text, color, baseSprite);
        floatingText.camera = victoryCam;
        add(floatingText);
    }

    function setupMenuManager():Void{
        menuManager = new CtMenuManager();
            
        cursor = new Cursor(Constants.cursorArrowGraphic);
        cursor.camera = victoryCam;
        add(cursor);
        
        menuManager.addCursor(cursor, 30);

        continueText = new CtText(0,0,"Continue");
        continueText.setFormat(Constants.fontName, 50, FlxColor.WHITE);
        continueText.camera = victoryCam;
        continueText.setPosition(unitLevelUi.bg.x + cursor.width + 30, unitLevelUi.bg.y - continueText.height - 30);
        continueText.antialiasing = false;
        continueText.visible = false;
        add(continueText);

        if(unitLevelUi.tall >= 3) continueText.x += 300;
        if(unitsToAdd.length <= 0) continueText.x -= 150;

        menuManager.setMenuOptions([[{sprite: continueText, cursorDirection: LEFT, clickFunction: function(F):Void{
            menuManager.disable();
            continueText.visible = false;

            if(stages[stage] == UNLOCKUNITS){
                unitUnlocker.advance(1);
            } else {
                advanceStage();
            }
        }}]]);
    }

    function doFadeIn():Void{
        FlxTween.tween(bg, {alpha: .94}, .7);

        var barDistance:Float = 300;
        topBar.y -= barDistance;
        bottomBar.y += barDistance;
        for(bar in [topBar, bottomBar]){
            FlxTween.tween(bar, {y: 0}, 1, {ease: FlxEase.quartOut});
        }

        new FlxTimer().start(1, function(F):Void{
            topText.setPosition(50, 40);
            
            FlxTween.tween(topText, {alpha: 1}, .5);
            topText.scale.set(2,2);
            FlxTween.tween(topText.scale, {x: 1, y: 1}, .5, {ease: FlxEase.backIn, onComplete: function(f):Void{
                FlxTween.shake(topText, 0.075, 0.05, XY);
            }});

            new FlxTimer().start(.85, function(F):Void{
                robinblank.x += 30;
                FlxTween.tween(robinblank, {x: robin.x - 50, alpha: .5}, 1, {ease: FlxEase.quartOut});

                robin.x += 30;
                FlxTween.tween(robin, {x: robin.x - 30, alpha: 1}, 1, {ease: FlxEase.quartOut});

                phone.doFadeIn();

                unitLevelUi.doFadeIn();

                new FlxTimer().start(.5, function(F):Void{
                    sparkles.scale.set(1.1, 1.1);
                    FlxTween.tween(sparkles.scale, {x: 1, y: 1}, 1, {ease: FlxEase.quartOut});
                    FlxTween.tween(sparkles, {alpha: 1}, 2, {ease: FlxEase.quartOut});
                });
            });
        });
    }

    function distributeExp(exp:Int, ending:Void->Void):Void{
        var time:Float = 2 + (5 * FlxMath.bound(exp / 3000, 0));
        // robin
        FlxTween.tween(Save.levelRobin, {exp: Save.levelRobin.exp + exp, expFloat: Save.levelRobin.exp + exp}, time);

        for(unit in unitsToAdd){
            var exptogive = FlxMath.bound(exp / unitsToAdd.length, 1);
            FlxTween.tween(Save.levelUnits.get(unit), {exp: Save.levelUnits.get(unit).exp + exptogive, expFloat: Save.levelUnits.get(unit).exp + exptogive}, time);
        }

        new FlxTimer().start(time, function(f):Void{
            ending();
        });
    }

    function advanceStage():Void{
        stage ++;

        switch(stages[stage]){
            case EXP:
                // ???
            case UNLOCKUNITS:
                unlockUnits();
            case FINISH:
                doEnding();
        }
    }

    function hideExpUi():Void{
        if(!expUiEnabled) return;

        phone.doFadeOut();
        unitLevelUi.doFadeOut();
        expUiEnabled = false;
    }

    function unlockUnits():Void{
        var unlockThese:Array<String> = [];

        for(unit in PlayState.battleData.unlockableUnits){
            if(FlxG.random.bool(unit.chance) && !Save.unlockedUnits.get(unit.id)){
                unlockThese.push(unit.id);
                Save.unlockedUnits.set(unit.id, true);
                Save.levelUnits.get(unit.id).exp = CharacterLevel.getExpFromLevel(unit.level);
                var realunit = new Unit(unit.id, null, FlxPoint.get(1,1), true, unit.level, true);
                Save.savedUnitHP.set(unit.id, realunit.maxHp.value);
                Save.savedUnitMP.set(unit.id, realunit.maxMp.value);
            }
        }

        if(unlockThese.length > 0){
            var wait:Float = 0.01;

            if(expUiEnabled){
                hideExpUi();
                wait = .5;
            }

            new FlxTimer().start(wait, function(f):Void{
                unitUnlocker.readySignal.add(function():Void{
                    continueText.x = unitUnlocker.bg.x + 150;
                    continueText.y = unitUnlocker.bg.y - 100;
                    continueText.visible = true;
                    menuManager.enable();
                });

                unitUnlocker.finishedSignal.add(function():Void{
                    advanceStage();
                });

                unitUnlocker.setUnits(unlockThese);
                unitUnlocker.fadeIn();
            });
        } else {
            advanceStage();
        }
    }

    function doEnding():Void{
        sparkles.animation.pause();

        var spr = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.WHITE);
		spr.camera = victoryCam;
		spr.alpha = 0;
		add(spr);

		FlxTween.tween(spr, {alpha: 1}, 1, {
			onComplete: function(f):Void
			{
				if (onComplete != null)
				{
					onComplete();
				}
			}
		});
    }

    function updateExpLevels():Void{
        Save.levelRobin.expFloat = Save.levelRobin.exp;

        for(unit in Save.levelUnits){
            unit.expFloat = unit.exp;
        }
    }
}