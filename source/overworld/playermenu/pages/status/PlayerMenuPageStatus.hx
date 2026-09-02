package overworld.playermenu.pages.status;

class PlayerMenuPageStatus extends PlayerMenuPage
{
	var nameplate:CtSprite;
	var statusText:CtText;
	var robinAura:CtSprite;
	var biggerText:CtText; 
    
	var lastText:String = "";

    public function new(playerMenu:PlayerMenu):Void{
        super(playerMenu, "status");
        makeBg(450, 500);
		robinAura = new CtSprite().createFromImage(Constants.playerMenuStatusRobinAuraPath);
		add(robinAura);
		nameplate = new CtSprite().createFromImage(Constants.playerMenuStatusNamePlatePath);
		add(nameplate);
		statusText = new CtText(0, 0, "(STATUS)");
		statusText.setFormat(Constants.fontName, 30, FlxColor.BLACK);
		add(statusText);
		biggerText = new CtText(0, 0, "");
		biggerText.setFormat(Constants.fontName, 40, FlxColor.BLACK);
		add(biggerText);
		for (txt in [statusText, biggerText])
		{
			txt.setBorderStyle(SHADOW, 0xFFCDDAF9, 2, 5);
		}
    }
    
    override function update(elapsed:Float):Void{
        super.update(elapsed);
        
        if(CtControls.checkInput("cancel", JUSTPRESSED)){
            playerMenu.removePage("status");
        }        
		configText();
    }

    override function openPage(xPos:Int):Void{
        super.openPage(xPos); 
		nameplate.setPosition(bg.bgCenter.x + 10, bg.bgCenter.y + 10);
		statusText.setPosition(nameplate.x + nameplate.width + 20, nameplate.y + nameplate.height - 150);
		robinAura.setPosition((bg.bgCenter.x + bg.bgCenter.width - robinAura.width) + 45, (bg.bgCenter.y + bg.bgCenter.height - robinAura.height) + 32);
		configText();
    }
    
    override function setActivePage():Void{
        super.setActivePage();        
    }
    
    override function removeActivePage():Void{
        super.removeActivePage();        
    }
	function configText():Void
	{
		var levelText:String = "LVL: " + Save.levelRobin.getLevel() + "\n";
		var expText:String = "EXP: " + Save.levelRobin.getCurrentLevelExp() + "\n";
		var nextLevelText:String = "EXP TO NEXT LVL: " + Save.levelRobin.getNextlevelExp() + "\n";
		var timeText:String = "TIME: " + FlxStringUtil.formatTime(Save.playtime, false) + "\n";

		var textToReplace:String = levelText + expText + nextLevelText + timeText;

		if(textToReplace == lastText) return;

		lastText = textToReplace;

		biggerText.text = textToReplace;
		biggerText.setPosition(bg.bgCenter.x, bg.bgCenter.y + bg.bgCenter.height - biggerText.height);
		
		while(biggerText.width > bg.bgCenter.width){
			biggerText.scale.x -= 0.05;
			biggerText.updateHitbox();
			biggerText.setPosition(bg.bgCenter.x, bg.bgCenter.y + bg.bgCenter.height - biggerText.height);
		}
	}
}