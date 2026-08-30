package overworld.playermenu.pages.main;

class PlayerMenuPageMain extends PlayerMenuPage
{
    var menuManager:CtMenuManager;
    var cursor:Cursor;
    
    var texts:Array<CtText> = [];
    
    var menuOptions:Array<Array<CtMenuOption>> = [];
	var polaroid:PlayerMenuPolaroid;
    
    public function new(playerMenu:PlayerMenu):Void{
        super(playerMenu, "main");
        
        initMenu();
        addOptions();
		polaroid = new PlayerMenuPolaroid(bg.bgCenter);
		add(polaroid);
    }
    
    override function update(elapsed:Float):Void{
        super.update(elapsed);
        
        menuManager.update();
    }
    
    function initMenu():Void{
        menuManager = new CtMenuManager();
		cursor = new Cursor(Constants.cursorArrowGraphic);
		add(menuManager.addCursor(cursor, 20, false));    
        
        menuManager.disable();
    }
    
    function addOptions():Void{
        addMenuOption("Status", function():Void{
           playerMenu.addPage("status");
        });
        
        addMenuOption("Spirits", function():Void{
           playerMenu.addPage("unitselector");
		}, Save.storyFlags.get("factory_scarymode").val_bool);
        
        addMenuOption("Item", function():Void{
           // 
		}, false);

		addMenuOption("Patches", function():Void
		{
			//
		}, false);
        
        menuManager.setMenuOptions(menuOptions);
    }
    
	function addMenuOption(text:String, onClick:Void->Void, ?unlocked:Bool = true):Void
	{
		var text = new CtText(0, 320 + (80 * texts.length), text);
		text.setFormat(Constants.fontName, 70, unlocked ? FlxColor.BLACK : 0xFFD4D1D1);
        add(text);
        
        texts.push(text);
        
        menuOptions.push([{sprite: text, cursorDirection: LEFT, clickFunction: function(f):Void{
					if (unlocked)
						onClick();
        }, cancelFunction: function(F):Void{
            removeActivePage();
            new FlxTimer().start(0.01, function(f):Void{
               playerMenu.close(); 
            });
        }}]);
    }
    
    override function openPage(xPos:Int):Void{
        super.openPage(xPos);
        
        for(text in texts){
            text.x = xPos + 50;
        }
        menuManager.changeSelection(0);
    }
    
    override function setActivePage():Void{
        super.setActivePage();
        
        menuManager.enable();
    }
    
    override function removeActivePage():Void{
        super.removeActivePage();
        
        menuManager.disable();
    }
}