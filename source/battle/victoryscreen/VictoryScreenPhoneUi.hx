package battle.victoryscreen;

class VictoryScreenPhoneUi extends FlxSkewedSprite
{
    var phoneSprite:CtSprite;

    public var bgCamera:FlxCamera;

    var cropEffect:VictoryScreenPhoneCropEffect;

    var bg:CtSprite;
    var expBar:FlxBar;
    var levelText:CtText;
    
    var lastExp:Float = -45;
    var lastLevel:Int = -5;

    var currentExp:Float = 100;
    var currentMaxExp:Int = 100;

    var victoryScreen:VictoryScreen;

    var progress:Float = 1;

    public function new(phoneSprite:CtSprite, victoryScreen:VictoryScreen):Void{
        super();

        this.phoneSprite = phoneSprite;
        this.victoryScreen = victoryScreen;
        
        initCameraSystem();

        setupScreen();

        skew.y = -15.2;
        skew.x = 8.3;
        visible = false;

        lastLevel = Save.levelRobin.getLevel();
    }

    function initCameraSystem():Void{
        makeGraphic(Std.int(phoneSprite.width), Std.int(phoneSprite.height), Constants.vsPhoneBgColor);

        bgCamera = new FlxCamera(0, 0, Std.int(phoneSprite.width), Std.int(phoneSprite.height));
        bgCamera.bgColor = Constants.vsPhoneBgColor;
        FlxG.cameras.list.insert(0, bgCamera);    

        cropEffect = new VictoryScreenPhoneCropEffect();

        this.shader = cropEffect;
    }

    function setupScreen():Void{
        bg = new CtSprite(70, 20).createFromImage(Constants.vsPhoneBgPath);
        bg.antialiasing = false;
        bg.camera = bgCamera;
        FlxG.state.add(bg);

        expBar = new FlxBar(0,0,LEFT_TO_RIGHT, 120, 20, this, "progress", 0, 1);
        expBar.createColoredFilledBar(FlxColor.BLUE, false);
        expBar.createColoredEmptyBar(FlxColor.BLACK, false);
        expBar.camera = bgCamera;
        FlxG.state.add(expBar);

        CtUtil.centerSpriteOnSprite(expBar, bg, true, true);
        expBar.x += 6;
        expBar.y += 50;

        levelText = new CtText(0,0,"sdsd");
        levelText.setFormat(Constants.fontName, 20, FlxColor.WHITE);
        levelText.camera = bgCamera;
        FlxG.state.add(levelText);
    }

    override function update(elapsed:Float):Void{          
        loadGraphic(CtUtil.renderFlxCameraToBitmapData(pixels, bgCamera));

        CtUtil.centerSpriteOnSprite(this, phoneSprite, true, true);
        angle = phoneSprite.angle;
        offset.set(phoneSprite.offset.x, phoneSprite.offset.y);
        visible = (phoneSprite.visible && phoneSprite.animation.curAnim.name == "open");

        #if phoneChangeSkew
        var movement:Float = 1;

        if(CtControls.checkInput("left", PRESSED)){
            skew.x -= movement * elapsed;
        }
        if(CtControls.checkInput("right", PRESSED)){
            skew.x += movement * elapsed;
        }
        if(CtControls.checkInput("up", PRESSED)){
            skew.y += movement * elapsed;
        }
        if(CtControls.checkInput("down", PRESSED)){
            skew.y -= movement * elapsed;
        }
        trace("SKEW - X: " + skew.x + " Y: " + skew.y);
        #end

        updateExp(elapsed);
        super.update(elapsed);
    }

    function updateExp(elapsed:Float):Void{
        if(Save.levelRobin.expFloat != lastExp){
            levelText.scale.set(1,1);
            levelText.text = "LVL " + Save.levelRobin.getLevel() + "\nNEXT: " + (Save.levelRobin.getNextlevelExp());
            while(levelText.width > expBar.width - 5){
                levelText.scale.x -= 0.01;
                levelText.updateHitbox();
            }
            levelText.setPosition(expBar.x + 5, expBar.y - levelText.height - 5);

            currentExp = Save.levelRobin.getCurrentLevelExpFloat();
            currentMaxExp = CharacterLevel.getExpForNextLevel(Save.levelRobin.getLevel());
                        
            lastExp = Save.levelRobin.expFloat;
        }

        if(Save.levelRobin.getLevel() > lastLevel){
            victoryScreen.textSignal.dispatch("LVL UP!", FlxColor.YELLOW, phoneSprite);
            lastLevel = Save.levelRobin.getLevel();
        }

        progress = CtUtil.lerpThing(progress, (currentExp / currentMaxExp), elapsed, 10);
    }

    public function doFadeIn():Void{
        visible = true;
    }

    override function destroy():Void{
        if(FlxG.cameras.list.contains(bgCamera)){
            FlxG.cameras.remove(bgCamera, true);
        }

        super.destroy();            
    }
}