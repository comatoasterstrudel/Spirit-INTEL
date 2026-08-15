package battle.ui.bottombar;

/**
 * Class to display the icon for a skill. Contained inside of an outline and over a background.
 */
class SkillIcon extends FlxSpriteGroup
{
	/**
	 * The background sprite to go behind the other sprites.
	 */
	public var bgSprite:CtSprite;

	/**
	 * The sprite that will change depedning on the skill. If blank, this sprite will be hidden.
	 */
    public var skillSprite:CtSprite;
	/**
	 * The outline to be shown above the other sprites
	 */
    public var outlineSprite:CtSprite;
    
	/**
	 * The skill this box is representing.
	 */
	public var currentSkill:SkillData;
    
	/**
	 * Is this icon displaying a real skill?
	 */
	public var enabled:Bool = false;
	
	/**
	 * The tween used to shake this box
	 */
	var shakeTween:FlxTween;

	/**
	 * Is this skill allowed to be used?
	 */
	public var allowed:Bool = false;

    public function new():Void{
        super();
        
		bgSprite = new CtSprite(0, 575, false).createFromImage(Constants.skillBackgroundGraphicPath);
		bgSprite.antialiasing = false;
		add(bgSprite);

		skillSprite = new CtSprite(0, 575, false).createColorBlock(40, 40, FlxColor.BLUE);
        skillSprite.antialiasing = false;
        add(skillSprite);
        
		outlineSprite = new CtSprite(0, 575, false).createFromImage(Constants.skillOutlineGraphicPath);
        outlineSprite.antialiasing = false;
        add(outlineSprite);        
		visible = false;
    }

	override function update(elapsed:Float):Void{
		super.update(elapsed);

		alignSprites();
	}

	/**
	 * Call this to update the sprites on this icon.
	 * @param enabled Should this icon display a skill? Otherwise this box will display as blank.
	 * @param allowed is this skill allowed to be used?
	 * @param skill The skill this should display.
	 */
	public function updateSkill(enabled:Bool, ?allowed:Bool = false, ?skill:SkillData):Void
	{
		this.allowed = allowed;
		resetShakeTween();

		this.enabled = enabled;

		if (enabled)
		{
			this.currentSkill = skill;

			bgSprite.color = FlxColor.WHITE;
            outlineSprite.color = FlxColor.WHITE;

            var path = Constants.skillIconGraphicPath + skill.iconGraphic + '.png';

			skillSprite.visible = true;
            
			if(allowed){
				for(spr in [outlineSprite, bgSprite, skillSprite]){
					spr.color = FlxColor.WHITE;
				}
			} else {
				for(spr in [outlineSprite, bgSprite, skillSprite]){
					spr.color = FlxColor.GRAY;
				}
			}

            if (Assets.exists(path))
            {
                skillSprite.createFromImage(path);
            }
            else
            {
                FlxG.log.error("Can't find skill icon graphic \"" + path + "\".");
                skillSprite.createColorBlock(40, 40, FlxColor.BLUE);
            }        
        } else {
			bgSprite.color = FlxColor.GRAY;
            outlineSprite.color = FlxColor.GRAY;
			skillSprite.visible = false;
        }
		visible = true;
		alignSprites();
    }

	/**
	 * Call this to set the positions and offset of the sprites
	 */
	public function alignSprites():Void{
		CtUtil.centerSpriteOnSprite(bgSprite, outlineSprite, true, true);
		CtUtil.centerSpriteOnSprite(skillSprite, outlineSprite, true, true);
		bgSprite.offset.set(outlineSprite.offset.x, outlineSprite.offset.y);
		skillSprite.offset.set(outlineSprite.offset.x, outlineSprite.offset.y);
	}

	/**
	 * Call this to shake this icon box
	 */
	public function shakeBox():Void{
		resetShakeTween();
		shakeTween = FlxTween.shake(outlineSprite, 0.1, .1, X);
	}

	/**
	 * Remove the shake effect
	 */
	public function resetShakeTween():Void{
		if(shakeTween != null){
			shakeTween.cancel();
			shakeTween.destroy();
		}
	}
}