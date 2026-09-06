function CTSCRIPT_SETNAME():String
{
	return "codeentry";
}

var code:Array<Int> = [];
var inputtedCode:Array<Int> = [];

var bg:CtSprite;

var numbers:FlxSpriteGroup;
var numberSprites:Array<CtText> = [];

var menuManager:CtMenuManager;

var inputAllowed:Bool = false;

var arrowDown:CtSprite;
var arrowUp:CtSprite;

var onFinish:Bool->Void;

function create():Void{
    initMenu();
}

function update(elapsed:Float):Void{
    if(menuManager != null) menuManager.update();

    if(inputAllowed){
        var changed:Bool = false;

        if(CtControls.checkInput("up", JUSTPRESSED)){
            inputtedCode[menuManager.curSelected] ++;
            changed = true;
            if(inputtedCode[menuManager.curSelected] > 9){
                inputtedCode[menuManager.curSelected] = 0;
            }
        }

        if(CtControls.checkInput("down", JUSTPRESSED)){
            inputtedCode[menuManager.curSelected] --;
            changed = true;
            if(inputtedCode[menuManager.curSelected] < 0){
                inputtedCode[menuManager.curSelected] = 9;
            }
        }

        if(changed){
            numberSprites[menuManager.curSelected].text = inputtedCode[menuManager.curSelected];
        }
    }
}

function setCode(newCode:Array<Int>):Void{
    code = newCode;
    inputtedCode = [];

    for(spr in numberSprites){
        numbers.remove(spr);
        spr.destroy();
        spr = null;
    }

    numberSprites = [];
    
    for(num in code){
        var text = new CtText();
        text.setFormat(Constants.fontName, 60, 0xFFFFFFFF);
        text.text = "0";
        text.antialiasing = false;
        numbers.add(text);

        text.screenCenter();
        numberSprites.push(text);

        inputtedCode.push(0);
    }

    var texts:Array<FlxSprite> = [];

    for(thing in numberSprites){
        texts.push(thing);
    }

    CtUtil.centerGroup(texts, 30, FlxG.width / 2);

    var menuOptions  = [[]];
    
    for(spr in numberSprites){
        menuOptions[0].push({sprite: spr, 
            hoverFunction: function(f):Void{
                f.alpha = 1;

                var spacing = 80;

                arrowDown.setPosition(f.x + 37 / 2 - arrowDown.width / 2, f.y + f.height / 2 - arrowDown.height / 2 - (spacing));
                arrowUp.setPosition(arrowDown.x, f.y + f.height / 2 - arrowDown.height / 2 + (spacing));
            }, nonHoverFunction: function(f):Void{
                f.alpha = .3;
            }, clickFunction: function(f):Void{
                end();
            }, cancelFunction: function(f):Void{
                closeMenu(true);
            }
        });
    }

    menuManager.setMenuOptions(menuOptions);
}

function openMenu(?newOnFinish:Bool->Void):Void{
    onFinish = newOnFinish;

    set_inCutscene(true);

    bg.revive();
    numbers.revive();

    new FlxTimer().start(0.1, function(F):Void{
        inputAllowed = true;

        menuManager.enable(true);

        arrowDown.revive();
        arrowUp.revive();
    });
}

function end():Void{
    inputAllowed = false;

    menuManager.disable();

    arrowDown.kill();
    arrowUp.kill();

    for(spr in numberSprites){
        spr.alpha = 1;
    }

    var correct:Bool = true;

    for(i in 0...code.length){
        if(code[i] != inputtedCode[i]){
            correct = false;
            break;
        }
    }

    new FlxTimer().start(1, function(f):Void{
        var color = 0xFF000000;

        if(correct){
            color = 0xFF27F53F;
        } else {
            color = 0xFFF52727;
        }

        for(spr in numberSprites){
            spr.color = color;
        }

        new FlxTimer().start(1.5, function(f):Void{
            if(onFinish != null){
                onFinish(correct);
            }
            closeMenu(false);
        });
    });
}

function closeMenu(changeCutscene:Bool):Void{
    if(changeCutscene){
        set_inCutscene(false);
    }

    bg.kill();
    numbers.kill();
    arrowDown.kill();
    arrowUp.kill();

    inputAllowed = false;
}

function initMenu():Void{
    bg = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFF000000);
    bg.alpha = .85;
    bg.camera = camUI;
    bg.kill();
    add(bg);

    numbers = new FlxSpriteGroup();
    numbers.camera = camUI;
    numbers.kill();
    add(numbers);

    menuManager = new CtMenuManager();

    arrowDown = new CtSprite().createFromImage(Constants.overworldMiscGraphicPath + "arrow.png");
    arrowDown.antialiasing = false;
    arrowDown.camera = camUI;
    arrowDown.kill();
    arrowDown.flipY = true;
    add(arrowDown);

    arrowUp = new CtSprite().createFromImage(Constants.overworldMiscGraphicPath + "arrow.png");
    arrowUp.antialiasing = false;
    arrowUp.camera = camUI;
    arrowUp.kill();
    add(arrowUp);
}