package battle.victoryscreen;

class VictoryScreenUnitLevelUi extends FlxSpriteGroup
{
    var units:Array<String> = [];

    public var bg_topLeft:CtSprite;
    public var bg_top:CtSprite;
    public var bg_topRight:CtSprite;
    public var bg_midLeft:CtSprite;
    public var bg:CtSprite;
    public var bg_midRight:CtSprite;
    public var bg_bottomLeft:CtSprite;
    public var bg_bottom:CtSprite;
    public var bg_bottomRight:CtSprite;

    var doodles:FlxSpriteGroup;

    var doodleTopLeft:CtSprite;
    var doodleBottomRight:CtSprite;

    var unitCells:Array<VictoryScreenUnitLevelCell> = [];

    public var wide:Int = 0;
    public var tall:Int = 0;

    var victoryScreen:VictoryScreen;

    public function new(units:Array<String>, victoryScreen:VictoryScreen):Void{
        super();

        this.units = units;
        this.victoryScreen = victoryScreen;

        addSprites();
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        updateBg();
    }

    function addSprites():Void{
        wide = Std.int(FlxMath.bound((units.length > 2 ? 3 : units.length), 1));
        tall = Std.int(FlxMath.bound(Math.ceil(units.length / 3), 1));

        setupBg();
        
        doodles = new FlxSpriteGroup();
        add(doodles);

        for(unit in units){
            var unitCell = new VictoryScreenUnitLevelCell(unit, victoryScreen);
            add(unitCell);

            unitCells.push(unitCell);
        }

        var setsofthree:Array<Array<CtSprite>> = [];

        var xPos:Int = 0;
        var yPos:Int = 0;

        for(i in 0...unitCells.length){
            if(setsofthree[yPos] == null) setsofthree[yPos] = [];

            setsofthree[yPos].push(unitCells[i].baseSprite);

            xPos ++;

            if(xPos > 2){
                xPos = 0;
                yPos ++;
            }
        }

        for(i in 0...setsofthree.length){
            CtUtil.centerGroup(cast setsofthree[i], 35, bg.x + bg.width / 2);
            for(base in setsofthree[i]){
                base.y = (bg.y + (Constants.vsUnitLevelUiCellHeight * i)) + 10;
            }
        }

        for(unit in unitCells){
            unit.updateSpritePositions();
        }
    }

    function setupBg():Void{
        bg_topLeft = new CtSprite().createFromImage(Constants.vsUnitLevelUiBgCornerPath);
        bg_topLeft.alpha = 0;
        bg_topLeft.antialiasing = false;
        add(bg_topLeft);

        bg_topRight = new CtSprite().createFromImage(Constants.vsUnitLevelUiBgCornerPath);
        bg_topRight.alpha = 0;
        bg_topRight.flipX = true;
        bg_topRight.antialiasing = false;
        add(bg_topRight);

        bg_bottomLeft = new CtSprite().createFromImage(Constants.vsUnitLevelUiBgCornerPath);
        bg_bottomLeft.alpha = 0;
        bg_bottomLeft.flipY = true;
        bg_bottomLeft.antialiasing = false;
        add(bg_bottomLeft);

        bg_bottomRight = new CtSprite().createFromImage(Constants.vsUnitLevelUiBgCornerPath);
        bg_bottomRight.alpha = 0;
        bg_bottomRight.flipX = true;
        bg_bottomRight.flipY = true;
        bg_bottomRight.antialiasing = false;
        add(bg_bottomRight);

        bg_top = new CtSprite().createColorBlock(10,10,FlxColor.WHITE);
        bg_top.alpha = 0;
        add(bg_top);
        
        bg_midLeft = new CtSprite().createColorBlock(10,10,FlxColor.WHITE);
        bg_midLeft.alpha = 0;
        add(bg_midLeft);

        bg_midRight = new CtSprite().createColorBlock(10,10,FlxColor.WHITE);
        bg_midRight.alpha = 0;
        add(bg_midRight);

        bg_bottom = new CtSprite().createColorBlock(10,10,FlxColor.WHITE);
        bg_bottom.alpha = 0;
        add(bg_bottom);

        bg = new CtSprite().createColorBlock(Std.int(Constants.vsUnitLevelUiCellWidth * wide), Std.int(Constants.vsUnitLevelUiCellHeight * tall), FlxColor.WHITE);
        bg.screenCenter(X);
        bg.y = FlxG.height - bg.height - 50;
        bg.alpha = 0;
        add(bg);

        updateBg();
    }

    function updateBg():Void{
        bg_topLeft.setPosition(bg.x - bg_topLeft.width, bg.y - bg_topLeft.height);
        bg_topLeft.alpha = bg.alpha;

        bg_top.setGraphicSize(bg.width, bg_topLeft.height);
        bg_top.updateHitbox();
        bg_top.setPosition(bg_topLeft.x + bg_topLeft.width, bg_topLeft.y);
        bg_top.alpha = bg.alpha;

        bg_topRight.setPosition(bg_top.x + bg_top.width, bg_top.y);
        bg_topRight.alpha = bg.alpha;

        bg_midLeft.setGraphicSize(bg_topLeft.width, bg.height);
        bg_midLeft.updateHitbox();
        bg_midLeft.setPosition(bg_topLeft.x, bg_topLeft.y + bg_topLeft.height);
        bg_midLeft.alpha = bg.alpha;

        bg_midRight.setGraphicSize(bg_topLeft.width, bg.height);
        bg_midRight.updateHitbox();
        bg_midRight.setPosition(bg_topRight.x, bg_topLeft.y + bg_topLeft.height);
        bg_midRight.alpha = bg.alpha;

        bg_bottomLeft.setPosition(bg_topLeft.x, bg.y + bg.height);
        bg_bottomLeft.alpha = bg.alpha;

        bg_bottom.setGraphicSize(bg.width, bg_bottomLeft.height);
        bg_bottom.updateHitbox();
        bg_bottom.setPosition(bg_bottomLeft.x + bg_bottomLeft.width, bg_bottomLeft.y);
        bg_bottom.alpha = bg.alpha;

        bg_bottomRight.setPosition(bg_bottom.x + bg_bottom.width, bg_bottom.y);
        bg_bottomRight.alpha = bg.alpha;
    }

    public function doFadeIn():Void{
        if(units.length <= 0) return;
        
        bg.scale.set(0.01,0.01);
        
        FlxTween.tween(bg, {alpha: 1}, .6);
        FlxTween.tween(bg.scale, {x:1 , y:1}, .6, {ease: FlxEase.quartOut, onUpdate: function(f):Void{
            bg.updateHitbox();
            bg.screenCenter(X);
            bg.y = FlxG.height - bg.height - 50;
        }});

        new FlxTimer().start(0.6, function(f):Void{
            addDoodles();

            for(unit in unitCells){
                unit.doFadeIn();
            }
        });
    }

    public function doFadeOut():Void{
        if(units.length <= 0) return;

        FlxTween.tween(this, {alpha: 0}, .5);
    }

    function addDoodles():Void{
        var paths = [];

        for(i in 0...4){
            paths.push(Constants.vsBoxDoodlesPath + (i + 1) + ".png");
        }

        var thecolor = 0xFFF4F4F4;

        doodleTopLeft = new CtSprite();
        doodleTopLeft.alpha = 0;
        doodleTopLeft.color = thecolor;
        doodleTopLeft.antialiasing = false;
        doodles.add(doodleTopLeft);

        doodleBottomRight = new CtSprite();
        doodleBottomRight.alpha = 0;
        doodleBottomRight.angle = 180;
        doodleBottomRight.color = thecolor;
        doodleBottomRight.antialiasing = false;
        doodles.add(doodleBottomRight);

        var doodles = [doodleTopLeft, doodleBottomRight];

        for(i in 0...2){
            var selectedPath:String = paths[FlxG.random.int(0, paths.length - 1)];

            paths.remove(selectedPath);

            doodles[i].createFromImage(selectedPath);

            if(units.length > 0){
                while(doodles[i].width >= (bg.width / 1.6)){
                    doodles[i].scale.x -= 0.01;
                    doodles[i].updateHitbox();
                }

                while(doodles[i].height >= (bg.height / 1.6)){
                    doodles[i].scale.y -= 0.01;
                    doodles[i].updateHitbox();
                }
            }
        }

        doodleTopLeft.setPosition(bg.x, bg.y);
        doodleBottomRight.setPosition(bg.x + bg.width - doodleBottomRight.width, bg.y + bg.height - doodleBottomRight.height);

        for(doodle in doodles){
            FlxTween.tween(doodle, {alpha: 1}, 2);
        }
    }
}