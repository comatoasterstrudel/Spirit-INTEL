package battle.ui.bottombar;

import flixel.text.FlxText.FlxTextFormat;

class BottomBar extends FlxSpriteGroup
{  
    var bottomCover:CtSprite;
    
	var unitPortrait:UnitPortrait;
        
	public var skillIcons:Array<SkillIcon> = [];
    
	public var endTurn:CtSprite;

	public var inspect:CtSprite;

	public var descriptionText:CtText;
	var textBgMiddle:CtSprite;
    var textBgLeftEdge:CtSprite;
    var textBgRightEdge:CtSprite;
	
	var curUnit:Unit;
	var lastUnit:Unit;

	public function new(style:String = "placeholder"):Void
	{
        super();
        
		bottomCover = new CtSprite().createFromImage(Constants.bottomBarGraphicPath + style + ".png");
		bottomCover.y = FlxG.height - bottomCover.height;
        bottomCover.antialiasing = false;
        add(bottomCover);
        
		unitPortrait = new UnitPortrait();
		add(unitPortrait);
        
        var skillOutlines:Array<FlxSprite> = [];
        
        for(i in 0...Constants.unitMaxSkills){
            var skillIcon = new SkillIcon();
            add(skillIcon);
            
            skillIcons.push(skillIcon);
            
            skillOutlines.push(skillIcon.outlineSprite);
        }
        
        CtUtil.centerGroup(skillOutlines, 20);
		inspect = new CtSprite(300, 575).createFromImage(Constants.inspectButtonGraphicPath);
		inspect.kill();
		add(inspect);
		
		endTurn = new CtSprite(1050, 567).createFromImage(Constants.endTurnButtonGraphicPath);
		endTurn.kill();
		add(endTurn);

		textBgLeftEdge = new CtSprite().createFromImage(Constants.bottomBarTextEdge);
        add(textBgLeftEdge);

        textBgRightEdge = new CtSprite().createFromImage(Constants.bottomBarTextEdge);
        textBgRightEdge.flipX = true;
        add(textBgRightEdge);

        textBgMiddle = new CtSprite().createFromImage(Constants.bottomBarTextMiddle);
        add(textBgMiddle);

		descriptionText = new CtText(0, 665, "", Constants.fontName, 35, false);
		descriptionText.setFormat(Constants.fontName, 35, FlxColor.BLACK, CENTER, SHADOW, FlxColor.GRAY);
		descriptionText.kill();
		add(descriptionText);
		updateCurrentUnit(null);
	}
    
	override function update(elapsed:Float):Void{
		super.update(elapsed);

		updateBgVisibility();
	}

    public function updateCurrentUnit(unit:Unit):Void{
        this.curUnit = unit;
        
		if (unit != null)
		{
			unitPortrait.visible = true;
			if(lastUnit == null || lastUnit.uniqueUnitID != curUnit.uniqueUnitID) unitPortrait.applyUnitGraphic(curUnit);
        
			for (i in 0...Constants.unitMaxSkills)
			{
				skillIcons[i].updateSkill(false);
			}

			for (i in 0...unit.skills.length)
			{
				skillIcons[i].updateSkill(true, unit.skills[i].mpCost <= unit.mp.value, unit.skills[i]);
			}
		}
		else
		{
			unitPortrait.visible = false;

			for (i in 0...Constants.unitMaxSkills)
			{
				skillIcons[i].updateSkill(false);
			}
		}

		lastUnit = this.curUnit;
	}

	public function addMenu():Void
	{
		inspect.revive();
		endTurn.revive();
		descriptionText.revive();
	}

	public function removeMenu():Void
	{
		inspect.kill();
		endTurn.kill();
		descriptionText.kill();
		descriptionText.visible = false;
	}

	public function updateText(text:String):Void
	{
		descriptionText.visible = true;
		descriptionText.text = text;
		descriptionText.applyMarkup(descriptionText.text, [
			new FlxTextFormatMarkerPair(new FlxTextFormat(Constants.color_mp), "[[BLUE]]"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(Constants.color_mp.getDarkened(.4)), "[[DARKBLUE]]"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GRAY), "[[GRAY]]"),
		]);
		descriptionText.screenCenter(X);
		descriptionText.y = 690 - descriptionText.height / 2;

		textBgMiddle.setGraphicSize(descriptionText.width, descriptionText.height + 20);
        textBgMiddle.updateHitbox();
        textBgMiddle.setPosition(descriptionText.x, descriptionText.y - 10);

        textBgLeftEdge.setGraphicSize(textBgLeftEdge.width, textBgMiddle.height);
        textBgLeftEdge.updateHitbox();
        textBgLeftEdge.setPosition(descriptionText.x - textBgLeftEdge.width, textBgMiddle.y);

        textBgRightEdge.setGraphicSize(textBgRightEdge.width, textBgMiddle.height);
        textBgRightEdge.updateHitbox();
        textBgRightEdge.setPosition(descriptionText.x + descriptionText.width, textBgMiddle.y);

		updateBgVisibility();
	}

	function updateBgVisibility():Void{
		for(bg in [textBgLeftEdge, textBgMiddle, textBgRightEdge]){
			bg.visible = (descriptionText.visible && descriptionText.alive);
		}
	}
}