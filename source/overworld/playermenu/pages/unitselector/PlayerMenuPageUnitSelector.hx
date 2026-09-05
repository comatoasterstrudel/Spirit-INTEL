package overworld.playermenu.pages.unitselector;

class PlayerMenuPageUnitSelector extends PlayerMenuPage
{
    var tabs:FlxSpriteGroup;
    var tabArray:Array<UnitSelectorTab> = [];

    var menuManager:CtMenuManager;
    var cursor:Cursor;

    public function new(playerMenu:PlayerMenu):Void{
        super(playerMenu, "unitselector");
        
        this.makeBg(500, 600);

        tabs = new FlxSpriteGroup();
        add(tabs);

        var unlockedUnits = Unit.getListOfUnlockedUnits();

        #if fillUnitSelector
        unlockedUnits = ["chair", "chair", "chair", "chair", "chair", "chair", "chair", "chair", "chair"];
        #end

        var counter:Int = 0;

        for(unit in unlockedUnits){
            var tab = new UnitSelectorTab(unit, this, counter);
            tabs.add(tab);

            tabArray.push(tab);

            counter ++;
        }

        initMenu();
    }
    
    override function update(elapsed:Float):Void{
        super.update(elapsed);

        updateTabPositions();

        menuManager.update();
    }

    override function openPage(xPos:Int):Void{
        super.openPage(xPos); 
		
		updateTabPositions(true);

        for(tab in tabArray){
            for(bar in tab.bars){
                bar.refreshValues(tab.realUnit);
            }
        }
    }
    
    override function setActivePage():Void{
        super.setActivePage();   
		
        new FlxTimer().start(.01, function(f):Void{
            menuManager.enable();
        });
    }
    
    override function removeActivePage():Void{
        super.removeActivePage(); 
		
		menuManager.disable();
    }
    
    function initMenu():Void{
        menuManager = new CtMenuManager();
		cursor = new Cursor(Constants.cursorArrowGraphic);
		add(menuManager.addCursor(cursor, 20, false, true));    
        
        menuManager.disable();

        var menuOptions:Array<Array<CtMenuOption>> = [];

        for(tab in tabArray){
            menuOptions.push([{sprite: tab.baseSprite, cursorDirection: LEFT, 
                cancelFunction: function(f):Void{
                    playerMenu.removePage("unitselector");
                }, 
                clickFunction: function(f):Void{
                    playerMenu.page_unitstatus.setUnit(tab.unit);
                    playerMenu.addPage("unitstatus");
                }                
            }]);
        }

        menuManager.setMenuOptions(menuOptions);
    }

    function updateTabPositions(snap:Bool = false):Void{
        var counter:Int = 0;

        for(tab in tabArray){
            var target = counter - menuManager.curRack;
            tab.baseSprite.lerpManager.targetPosition.y = (target * FlxG.height / 6) + FlxG.height / 2 - tab.baseSprite.height / 2;

            if(snap){
                tab.baseSprite.lerpManager.snap();
            }

            tab.updatePositions(menuManager.curRack == tab.id);

            counter ++;
        }
    }
}