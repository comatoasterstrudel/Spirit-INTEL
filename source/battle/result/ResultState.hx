package battle.result;

class ResultState extends FlxSubState
{
    var bg:CtSprite;
        
    var bigText:CtText;
    
    var texts:FlxTypedGroup<CtText>;
    
    var camMenu:FlxCamera;
    
    var type:ResultType;
    
    var optionList:Array<String> = ["Replay", "Exit to Menu"];
    
    var menuManager:CtMenuManager;
    
    var animManager:CtEventManager;
    
    public function new (type:ResultType){
        super();

        this.type = type;
        
        camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;
		FlxG.cameras.add(camMenu, false);
        
        bg = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = Constants.resultBgOpacity;
        bg.camera = camMenu;
        add(bg);
        
		bigText = new CtText(0, Constants.resultBigTextY, getBigText(), Constants.fontName, Constants.resultBigTextSize);
        bigText.screenCenter(X);
        bigText.camera = camMenu;
        add(bigText);
        
        texts = new FlxTypedGroup<CtText>();
        texts.camera = camMenu;
        add(texts);
        
		setOptionList();
        setUpMenu();
        populateOptions();
        
        doAnim();
    }
    
    override function update(elapsed:Float):Void{
        super.update(elapsed);
        
        menuManager.update();
        animManager.update();
    }
    
    function getBigText():String{
        return switch(type){
			case WIN: Constants.resultTextWin;
			case LOSS: Constants.resultTextLose;
			case TIE: Constants.resultTextTie;
			default: Constants.resultTextPlaceholder;
        };
    }
        
	function setOptionList():Void
	{
		switch (PlayState.battleType)
		{
			case ARCADE:
				optionList = ["Replay", "Exit to Menu"];
			case STORY:
				if (type == WIN)
				{
					optionList = ["Continue"];
				}
				else
				{
					optionList = ["Exit to Menu"];
				}
		}
	}
    
    function setUpMenu():Void{
        menuManager = new CtMenuManager();
            
        var cursor = new Cursor(Constants.cursorArrowGraphic);
        cursor.camera = camMenu;
        add(menuManager.addCursor(cursor, 20, false));
    }
    
    function populateOptions():Void{
        var options:Array<Array<CtMenuOption>> = [];
        
        for(i in 0...optionList.length){
			var text = new CtText(Constants.resultTextX, Constants.resultTextY + Constants.resultTextSpacing * i, optionList[i], Constants.fontName,
				Constants.resultTextSize, false);
            texts.add(text);
                        
            options.push([{sprite: text, cursorDirection: LEFT, clickFunction: function(spr):Void{
                switch(optionList[i]){
                    case "Replay":
                        FlxG.resetState();
                    case "Exit to Menu":
                        FlxG.switchState(LevelSelectorState.new);
						case "Continue":
							menuManager.disable();
							doOutroAnim(function():Void
							{
								FlxG.switchState(OverworldState.new);
							});
                }
            }}]);
        }
        
        menuManager.setMenuOptions(options);
    }
    
    function doAnim():Void{
        bg.scale.set(0, 0);

        bigText.visible = false;
        
        for(i in texts.members){
            i.visible = false;    
        }
        
        animManager = new CtEventManager();
        animManager.reset();
            
        animManager.addEvent(function():Void{
            animManager.startTransaction("bgZoom");
            
			FlxTween.tween(bg.scale, {x: 1, y: 1}, Constants.resultAnimTiming, {
				ease: FlxEase.quartOut,
				onUpdate: function(s):Void
				{
                bg.updateHitbox();
                bg.screenCenter();               
            }, onComplete: function(f):Void{
                animManager.finishTransaction("bgZoom");
            }});
        });
        
        animManager.addEvent(function():Void{
            animManager.startTransaction("bigText");
            bigText.visible = true;
            
			FlxTween.shake(bigText, Constants.resultAnimShakeIntensity * 2, Constants.resultAnimShakeTime, X);
            
			new FlxTimer().start(Constants.resultAnimTiming, function(f):Void
			{
                animManager.finishTransaction("bigText");
            });
        });    
            
        for(i in texts.members){
            animManager.addEvent(function():Void{
                animManager.startTransaction("txt_" + i.text + i.ID);
                i.visible = true;
                
				FlxTween.shake(i, Constants.resultAnimShakeIntensity, Constants.resultAnimShakeTime, X);
                
				new FlxTimer().start(Constants.resultAnimTiming, function(f):Void
				{
                    animManager.finishTransaction("txt_" + i.text + i.ID);
                });
            });    
        }
        
        animManager.addEvent(function():Void{
            menuManager.enable();
        });
    }  
	function doOutroAnim(?onComplete:Void->Void):Void
	{
		var spr = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.WHITE);
		spr.camera = camMenu;
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
}