package overworld.playermenu.pages.unitselector;

class UnitSelectorTab extends FlxSpriteGroup
{
    public var baseSprite:CtSprite;

    var unitIcon:CtSprite;
    var nameText:CtText;
    var levelText:CtText;

    var hpBar:UnitSelectorBar;
    var mpBar:UnitSelectorBar;

    public var bars:Array<UnitSelectorBar> = [];
    var barSprites:Array<FlxBar> = [];

    public var unit:String;    
    var page:PlayerMenuPage;
    public var id:Int;

    var unitData:UnitData;

    var sprites:Array<FlxSprite> = [];
    var cropEffects:Array<UnitSelectorCrop> = [];

    public var realUnit:Unit;

    public function new(unit:String, page:PlayerMenuPage, id:Int):Void{
        super();

        this.unit = unit;
        this.page = page;
        this.id = id;

        realUnit = new Unit(unit, null, FlxPoint.get(1,1), true, CharacterLevel.getLevelFromExp(Save.levelUnits.get(unit).exp), true);

        unitData = new UnitData(unit);

        baseSprite = new CtSprite().createColorBlock(Constants.playerMenuUnitSelectorWidth, Constants.playerMenuUnitSelectorHeight, FlxColor.BLUE);
        baseSprite.lerpManager.lerpY = true;
        baseSprite.lerpManager.lerpSpeed = 20;
        baseSprite.visible = false;
        #if showUnitSelectorBaseSprite
        baseSprite.visible = true;
        #end
        add(baseSprite);

        unitIcon = new CtSprite().createFromImage(Constants.unitGridGraphicPath + unitData.gridGraphic + ".png", 1.5);
        unitIcon.antialiasing = false;
        add(unitIcon);

        nameText = new CtText(0,0,unitData.name);
        nameText.setFormat(Constants.fontName, 40, FlxColor.BLACK);
        add(nameText);

        levelText = new CtText(0,0, "LVL " + CharacterLevel.getLevelFromExp(Save.levelUnits.get(unit).exp));
        levelText.setFormat(Constants.fontName, 30, FlxColor.GRAY);
        add(levelText);

        hpBar = new UnitSelectorBar(HP);
        hpBar.refreshValues(realUnit);
        add(hpBar);

        mpBar = new UnitSelectorBar(MP);
        mpBar.refreshValues(realUnit);
        add(mpBar);

        bars = [hpBar, mpBar];

        for(bar in bars){
            barSprites.push(bar.bar);
        }

        #if AAAA
        nameText.text = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH";
        #end

        while(nameText.width >= 380){
            nameText.scale.x -= 0.01;
            nameText.updateHitbox();
        }

        sprites = [unitIcon, nameText, levelText];

        for(bar in bars){
            sprites.push(bar.bar);
            sprites.push(bar.text);
            sprites.push(bar.overlay);
        }

        applyShaders();
    }

    override function draw():Void{
        updateCropEffects();

        super.draw();
    }
    
    function applyShaders():Void{
        var crop:Float = 50;

        for(sprite in sprites){
            var cropEffect = new UnitSelectorCrop(sprite, 0, FlxG.width, crop, FlxG.height - crop);
            sprite.shader = cropEffect;

            cropEffects.push(cropEffect);
        }
    }

    public function updatePositions(enabled:Bool):Void{
        baseSprite.x = page.bg.bgCenter.x + 65;

        unitIcon.setPosition(baseSprite.x, baseSprite.y);

        nameText.x = baseSprite.x + 60;
        CtUtil.centerSpriteOnSprite(nameText, unitIcon, false, true);

        levelText.setPosition(nameText.x + nameText.width + 15, nameText.y + nameText.height - levelText.height);

        CtUtil.centerGroup(cast barSprites, 20, baseSprite.x + baseSprite.width / 2);

        for(bar in bars){
            bar.y = baseSprite.y + 60;
            bar.updatePosition();    
        }
    }

    function updateCropEffects():Void{
        for(cropEffect in cropEffects) cropEffect.update();
    }
}