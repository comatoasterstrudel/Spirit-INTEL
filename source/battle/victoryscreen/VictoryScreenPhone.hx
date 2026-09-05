package battle.victoryscreen;

class VictoryScreenPhone extends FlxSpriteGroup
{
    var phoneBlank:CtSprite;
    var blankOffset:Float = 0;

    var phoneSprite:CtSprite;
    var phoneScreen:VictoryScreenPhoneUi;
    var black:CtSprite;
    var black2:CtSprite;
    
    var victoryScreen:VictoryScreen;

    public function new(victoryScreen:VictoryScreen):Void{
        super();

        this.victoryScreen = victoryScreen;
        
        phoneBlank = new CtSprite().createFromImage(Constants.vsPhoneBlankPath);
        phoneBlank.alpha = 0;
        phoneBlank.color = 0xFF110066;
        add(phoneBlank);

        phoneSprite = new CtSprite().createFromSparrow(Constants.vsPhonePath + ".png", Constants.vsPhonePath + ".xml");
        phoneSprite.animation.addByPrefix("closed", "closed", 0);
        phoneSprite.animation.addByPrefix("open", "open", 0);
        phoneSprite.animation.play("open");
        phoneSprite.visible = false;

        black = new CtSprite().createFromImage(Constants.vsPhoneBlackPath);
        add(black);

        phoneScreen = new VictoryScreenPhoneUi(phoneSprite, victoryScreen);
        add(phoneScreen);

        black2 = new CtSprite().createFromImage(Constants.vsPhoneBlackPath);
        add(black2);

        add(phoneSprite);

        phoneSprite.setPosition(Constants.vsPhoneBaseX, Constants.vsPhoneBaseY);
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        for(blackspr in [black, black2, phoneBlank]){
            CtUtil.centerSpriteOnSprite(blackspr, phoneSprite, true, true);
            blackspr.angle = phoneSprite.angle;
            blackspr.offset.set(phoneSprite.offset.x, phoneSprite.offset.y);
            blackspr.visible = (phoneSprite.visible && phoneSprite.animation.curAnim.name == "open");
        }

        phoneBlank.x += blankOffset;
    }

    public function doFadeIn():Void{
        phoneSprite.animation.play("closed");

        phoneSprite.x -= 200;

        phoneSprite.visible = true;

        FlxTween.tween(phoneSprite, {angle: 35, x: phoneSprite.x + 350}, .5, {ease: FlxEase.circOut, onComplete: function(f):Void{
            phoneSprite.animation.play("open");
            FlxTween.shake(phoneSprite, 0.1 , 0.05,  XY);
            FlxTween.tween(black2, {alpha: 0}, .7);
            phoneScreen.doFadeIn();
            FlxTween.tween(phoneBlank, {alpha: 0.5}, 1);
            FlxTween.num(0, 20, 1, {ease: FlxEase.quartOut}, function(num:Float):Void{
                blankOffset = num;
            });

            FlxTween.tween(phoneSprite, {angle: 0, x: Constants.vsPhoneBaseX, y: Constants.vsPhoneBaseY}, .5, {ease: FlxEase.circOut, onComplete: function(f):Void{
                //
            }});
        }});
    }

    public function doFadeOut():Void{
        phoneSprite.animation.play("closed");

        FlxTween.tween(phoneSprite, {alpha: 0}, .5);
    };
}