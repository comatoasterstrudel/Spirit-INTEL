package battle.ui.turnorder;

class TurnOrderDisplay extends FlxSpriteGroup
{
	public var topBar:TopBar;

	public var upperBar:CtSprite;
	var upperBarDark:CtSprite;

	var incomingCalls:CtSprite;

    var iconAmount:Int;
    
    var icons:Array<TurnOrderIcon> = [];
    
    var aliveIcons:Array<FlxSprite> = [];
    
    public function new(gridSize:FlxPoint):Void{
        super();
        
		upperBar = new CtSprite().createFromImage(Constants.turnOrderDisplayUpperBarGraphicPath);
		upperBar.setGraphicSize(Constants.turnOrderDisplayStartingX, upperBar.height);
		upperBar.updateHitbox();
		upperBar.x = 0;
		add(upperBar);
        
		upperBarDark = new CtSprite(Constants.turnOrderDisplayStartingX).createFromImage(Constants.turnOrderDisplayUpperBarDarkGraphicPath);
		upperBarDark.color = 0xFFA9A9A9;
		upperBarDark.setGraphicSize(FlxG.width - Constants.turnOrderDisplayStartingX, upperBar.height);
		upperBarDark.updateHitbox();
		add(upperBarDark);

		topBar = new TopBar(this);
		add(topBar);
        
        iconAmount = Std.int((gridSize.x * gridSize.y) * 2);
        
        for(i in 0...iconAmount){
            var icon = new TurnOrderIcon();
            add(icon);
            
            icon.kill();
            
            icons.push(icon);
        }

		updateTurnOrderDisplay([]);
		topBar.updateCurrentUnit(null);
    }
    
    public function updateTurnOrderDisplay(turnOrder:Array<Unit>):Void{
        for(icon in icons){
            icon.kill();
        }
        
        aliveIcons = [];
        
        for(i in 0...turnOrder.length){
            icons[i].revive();
            icons[i].updateTurnOrderIcon(turnOrder[i]);
            
            aliveIcons.push(icons[i].bg);
        }
        
		for (i in icons)
		{
			if (i.alive)
			{
				i.resize(1);
			}
		}

		var beyondX:Bool = true;

		while (beyondX)
		{
			var xpos = positionIcons();

			if (xpos > FlxG.width)
			{
				beyondX = true;

				for (i in icons)
				{
					if (i.alive)
					{
						i.resize(i.scaleFactor - .001);
					}
				}
			}
			else
			{
				beyondX = false;
			}
		}

		if(turnOrder.length > 0){
			upperBarDark.color = 0xFFA9A9A9;
			upperBarDark.createFromImage(Constants.turnOrderDisplayUpperBarDarkGraphicPath);
			upperBarDark.setGraphicSize(FlxG.width - Constants.turnOrderDisplayStartingX, upperBar.height);
			upperBarDark.updateHitbox();
		} else {
			upperBarDark.color = FlxColor.WHITE;
			upperBarDark.createFromImage(Constants.turnOrderDisplayUpperBarGraphicPath);
			upperBarDark.setGraphicSize(FlxG.width - Constants.turnOrderDisplayStartingX, upperBar.height);
			upperBarDark.updateHitbox();
		}
	}

	function positionIcons():Float
	{
		var xpos = Constants.turnOrderDisplayStartingX;

		for (i in aliveIcons)
		{
			i.x = xpos;
			xpos += i.width;
		}

		return xpos;
    }

	public function updateCurrentTurn(unit:Unit):Void
	{
		for (icon in icons)
		{
			if (!icon.alive)
				continue;

			icon.updateCurrentTurn(unit);
		}
	}
}