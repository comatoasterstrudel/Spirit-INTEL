package battle.status;



class StatusEffectInfoBox extends FlxSpriteGroup
{
    public var boxOutline:CtSprite;
    public var box:CtSprite;
    public var text:CtText;

    public var cursor:CtSprite;

    public function new():Void{
        super();

        box = new CtSprite().createColorBlock(200, 90, FlxColor.WHITE);

        boxOutline = new CtSprite().createColorBlock(Std.int(box.width + 4), Std.int(box.height + 4), FlxColor.BLACK);
        add(boxOutline);

        add(box);

        text = new CtText(0,0,"s");
        text.setFormat(Constants.fontName, 25, FlxColor.BLACK);
        add(text);
    }

    override function draw():Void{
        updatePositions();
        
        super.draw();
    }

    public function updateStatus(status:StatusEffect):Void{
        text.text = "[[COLOR]]" + status.data.name + "[[COLOR]]  " + status.data.description + '  [[GRAY]]${status.turns} turns left[[GRAY]]';

        text.applyMarkup(text.text, [
            new FlxTextFormatMarkerPair(new FlxTextFormat(status.data.color), "[[COLOR]]"),
            new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GRAY), "[[GRAY]]")
        ]);

        box.setGraphicSize(Std.int(text.width + 4), Std.int(text.height + 4));
        box.updateHitbox();

        boxOutline.setGraphicSize(Std.int(box.width + 4), Std.int(box.height + 4));
        boxOutline.updateHitbox();

        updatePositions();
    }

    function updatePositions():Void{
        CtUtil.centerSpriteOnSprite(box, cursor, true, false);
        box.y = cursor.y;

        while(box.x < 4){
            box.x += 1;
        }

        while(box.x + box.width > FlxG.width + 4){
            box.x -= 1;
        }

        CtUtil.centerSpriteOnSprite(boxOutline, box, true, true);
        CtUtil.centerSpriteOnSprite(text, box, true, true);
    }
}