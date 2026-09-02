package overworld.playermenu.pages.unitstatus;

class PlayerMenuPageUnitStatus extends PlayerMenuPage
{
    var curUnit:String = "";
    
    var nameText:CtText;
    var lvlText:CtText;
    
    var unitSprite:CtSprite;

    var hpBar:UnitSelectorBar;
    var mpBar:UnitSelectorBar;

    var biggerText:CtText;
    var statText:CtText;

    var skillSprites:Array<SkillIcon> = [];
    var skillText:CtText;
    var textBgMiddle:CtSprite;
    var textBgLeftEdge:CtSprite;
    var textBgRightEdge:CtSprite;
	
    var cursor:Cursor;
    var menuManager:CtMenuManager;

    public function new(playerMenu:PlayerMenu):Void{
        super(playerMenu, "unitstatus");
        makeBg(500, 500);

        nameText = new CtText(0, 0, "");
		nameText.setFormat(Constants.fontName, 60, FlxColor.BLACK);
		add(nameText);

        lvlText = new CtText(0, 0, "");
		lvlText.setFormat(Constants.fontName, 40, FlxColor.GRAY);
		add(lvlText);

        unitSprite = new CtSprite();
        unitSprite.antialiasing = false;
        unitSprite.color = 0xFFCDDAF9;
        unitSprite.alpha = .13;
        add(unitSprite);

        hpBar = new UnitSelectorBar(HP);
        add(hpBar);

        mpBar = new UnitSelectorBar(MP);
        add(mpBar);

        biggerText = new CtText(0, 0, "");
		biggerText.setFormat(Constants.fontName, 35, FlxColor.BLACK);
        biggerText.scale.y = .9;
		add(biggerText);

        statText = new CtText(0, 0, "");
		statText.setFormat(Constants.fontName, 35, FlxColor.BLACK);
        statText.scale.y = .9;
		add(statText);

        for(txt in [nameText, lvlText, biggerText, statText]){
            txt.setBorderStyle(SHADOW, 0xFFCDDAF9, 2, 5);
        }

        for(i in 0...Constants.unitMaxSkills){
            var skill = new SkillIcon();
            add(skill);
            skillSprites.push(skill);
        }

        var bgAlpha:Float = .8;

		textBgLeftEdge = new CtSprite().createFromImage(Constants.bottomBarTextEdge);
        textBgLeftEdge.alpha = bgAlpha;
        add(textBgLeftEdge);

        textBgRightEdge = new CtSprite().createFromImage(Constants.bottomBarTextEdge);
        textBgRightEdge.alpha = bgAlpha;
        textBgRightEdge.flipX = true;
        add(textBgRightEdge);

        textBgMiddle = new CtSprite().createFromImage(Constants.bottomBarTextMiddle);
        textBgMiddle.alpha = bgAlpha;
        add(textBgMiddle);

        skillText = new CtText(0, 0, "");
		skillText.setFormat(Constants.fontName, 30, FlxColor.BLACK);
		add(skillText);

        menuManager = new CtMenuManager();
		cursor = new Cursor(Constants.cursorArrowGraphic);
		add(menuManager.addCursor(cursor, 20, false, true));    
        
        menuManager.disable();
    }
    
    override function update(elapsed:Float):Void{
        super.update(elapsed);
        
        menuManager.update();

        positionStuff();

        if(CtControls.checkInput("cancel", JUSTPRESSED)){
            playerMenu.removePage("unitstatus");
        }
    }

    override function openPage(xPos:Int):Void{
        super.openPage(xPos); 
		
		//
    }
    
    override function setActivePage():Void{
        super.setActivePage();   
		
        new FlxTimer().start(.01, function(f):Void{
            menuManager.enable(true);
        });
    }
    
    override function removeActivePage():Void{
        super.removeActivePage(); 
		
		menuManager.disable();
    }
	
	public function setUnit(unit:String):Void{
        curUnit = unit;

        var data = new UnitData(unit);

        nameText.text = data.name;
        lvlText.text = "Lvl. " + Save.levelUnits.get(unit).getLevel();

        unitSprite.createFromImage(Constants.unitUiGraphicPath + data.uiGraphicAlly + ".png");

        var realUnit = new Unit(unit, null, FlxPoint.get(), true, Save.levelUnits.get(unit).getLevel(), true);

        hpBar.refreshValues(realUnit);
        mpBar.refreshValues(realUnit);

        biggerText.text = "EXP: " + Save.levelUnits.get(unit).getCurrentLevelExp() + "\nEXP TO NEXT LVL: " + Save.levelUnits.get(unit).getNextlevelExp();
        statText.text = "ATTACK: " + realUnit.attack.value + "\nS. ATTACK: " + realUnit.sattack.value + "\nSPEED: " + realUnit.speed.value;

        for(skill in skillSprites){
            skill.updateSkill(false);
        }

        var menuOptions:Array<CtMenuOption> = [];

        for(i in 0...realUnit.skills.length){
            skillSprites[i].updateSkill(true, realUnit.mp.value >= realUnit.skills[i].mpCost, realUnit.skills[i]);

            menuOptions.push({sprite: skillSprites[i].bgSprite, cursorDirection: DOWN, hoverFunction: function(f):Void{
                var skill = realUnit.skills[i];

                skillText.text = "[[GRAY]]" + skill.name + "[[GRAY]]  " + skill.description + "  [[BLUE]]MP: " + skill.mpCost + "[[BLUE]]";
                skillText.applyMarkup(skillText.text, [
                    new FlxTextFormatMarkerPair(new FlxTextFormat(Constants.color_mp), "[[BLUE]]"),
                    new FlxTextFormatMarkerPair(new FlxTextFormat(Constants.color_mp.getDarkened(.4)), "[[DARKBLUE]]"),
                    new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GRAY), "[[GRAY]]"),
                ]);

                skillText.scale.set(1, 1);
                skillText.updateHitbox();

                while(skillText.width >= bg.bgCenter.width - 20){
                    skillText.scale.x -= 0.01;
                    skillText.updateHitbox();
                }

                textBgMiddle.setGraphicSize(skillText.width, skillText.height + 20);
                textBgMiddle.updateHitbox();

                textBgLeftEdge.setGraphicSize(textBgLeftEdge.width, textBgMiddle.height);
                textBgLeftEdge.updateHitbox();

                textBgRightEdge.setGraphicSize(textBgRightEdge.width, textBgMiddle.height);
                textBgRightEdge.updateHitbox();
            }});
        }

        menuManager.setMenuOptions([menuOptions]);

        positionStuff();
	}

    function positionStuff():Void{
        nameText.setPosition(bg.bgCenter.x + 10, bg.bgCenter.y + 10);
        lvlText.setPosition(nameText.x + nameText.width + 10, nameText.y + nameText.height - lvlText.height);

        unitSprite.setPosition(bg.bgCenter.x + bg.bgCenter.width - unitSprite.width + 15, bg.bgCenter.y + bg.bgCenter.height - unitSprite.height + 20);

        hpBar.bar.setPosition(nameText.x, nameText.y + nameText.height + 20);
        hpBar.updatePosition();

        mpBar.bar.setPosition(hpBar.bar.x + hpBar.bar.width + 10, hpBar.bar.y);
        mpBar.updatePosition();

        biggerText.setPosition(nameText.x, hpBar.bar.y + hpBar.bar.height + 15);
        statText.setPosition(biggerText.x, biggerText.y + biggerText.height + 4);

        skillText.y = statText.y + statText.height + 20;
        CtUtil.centerSpriteOnSprite(skillText, bg.bgCenter, true, false);

        textBgMiddle.setPosition(skillText.x, skillText.y - 10);
        textBgLeftEdge.setPosition(skillText.x - textBgLeftEdge.width, textBgMiddle.y);
        textBgRightEdge.setPosition(skillText.x + skillText.width, textBgMiddle.y);

        var sprs:Array<FlxSprite> = [];

        for(skill in skillSprites){
            sprs.push(skill.outlineSprite);
        }

        CtUtil.centerGroup(sprs, 10, bg.bgCenter.x + bg.bgCenter.width / 2);
        
        for(skill in skillSprites){
            skill.outlineSprite.y = statText.y + statText.height + 80;
            skill.alignSprites();
        }
    }
}