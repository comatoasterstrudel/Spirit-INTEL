package overworld.footstep;

class FootstepSprite extends CtSprite
{
    public var footstep:FootstepData;
    public var tile:FlxTile;
    public var character:Character;
    public var grp:FlxTypedSpriteGroup<FootstepSprite>;

    public var fixedPos:FlxPoint;

    public function new(footstep:FootstepData, tile:FlxTile, character:Character, grp:FlxTypedSpriteGroup<FootstepSprite>):Void{
        super();

        this.footstep = footstep;
        this.tile = tile;
        this.character = character;
        this.grp = grp;

        this.fixedPos = getFixedPosition(character);

        createFromImage(Constants.footstepGraphicPath + (footstep.graphics[FlxG.random.int(0, footstep.graphics.length - 1)]) + ".png", Constants.overworldPixelScale);
		CtUtil.centerSpriteOnSprite(this, character, true, false);
		y = character.y + character.height - height;
		setPosition(CtUtil.roundToMultiple(x, Constants.overworldPixelScale), CtUtil.roundToMultiple(y, Constants.overworldPixelScale));
		antialiasing = false;
		switch(character.facing){
			case LEFT:
				angle = 90;
			case RIGHT:
				angle = 270;
			case UP:
				angle = 180;
			default:
				//
		}
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        if(character.moving){
            alpha -= (elapsed / 2);

            if(alpha <= 0){
                grp.remove(this, true);
                destroy();
            }
        }
    }

    public static function getFixedPosition(character:Character):FlxPoint{
        var ogPos = character.getGridSpace();
        return FlxPoint.get(Std.int(ogPos.x), Std.int(ogPos.y));
    }
}