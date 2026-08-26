package overworld.character;

/**
 * Class used to represent a character in the overworld
 */
class Character extends CtSprite
{
	public var hitbox:CtSprite;

    var status:CharacterStatus = IDLE;
    
	public var id:String;
	public var data:CharacterData;

	var previousPosition:FlxPoint = new FlxPoint();
	
	public var moving:Bool = false;
	
	public var noclip:Bool = false;
	
	var autoMovementTarget:FlxPoint = new FlxPoint();
	var autoMovementStartPosition:FlxPoint = new FlxPoint();
	var autoMovementActive:Bool = false;
	var autoMovementComplete:Void->Void;
	var autoMovementDoX:Bool = false;
	var autoMovementDoY:Bool = false;

	public var tag:String = "";

	public var lockAnims:Bool = false;

	public var movementSpeed:Float = 1;
	
	public var animationPrefix:String = "";
	
	public function new(id:String, tag:String):Void
	{
        super();
        
		this.id = id;
		this.tag = tag;

		initCharacterAnimations(id);

		facing = DOWN;
		hitbox = new CtSprite().createColorBlock(Std.int(width / 1.5), Std.int(height / 2), FlxColor.RED);
		hitbox.visible = false;
		hitbox.immovable = true;
		this.noclip = data.noclip;
		centerSpriteOnHitbox();
    }
    
	override function update(elapsed:Float)
	{
		doMovement();

		hitbox.update(elapsed);
		super.update(elapsed);
		handleAutoMovement();
    }

	override function draw():Void
	{
		centerSpriteOnHitbox();

		super.draw();
	}

	public function centerSpriteOnHitbox(doPixelSnapping:Bool = true):Void
	{
		CtUtil.centerSpriteOnSprite(this, hitbox, true, false);
		y = hitbox.y + hitbox.height - height;

		if(doPixelSnapping){
			x = CtUtil.roundToMultiple(x, Constants.overworldPixelScale);
			y = CtUtil.roundToMultiple(y, Constants.overworldPixelScale);
		}
	}
	
	public function initCharacterAnimations(name:String):Void
	{
		animation.destroyAnimations();

		data = new CharacterData(name);
		
		if (data.fromAseprite)
		{
			frames = FlxAtlasFrames.fromTexturePackerJson(Constants.characterGraphicPath + data.graphic + ".png",
				Constants.characterGraphicPath + data.graphic + ".json", false);
		}
		else
		{
			createFromSparrow(Constants.characterGraphicPath + data.graphic + ".png", Constants.characterGraphicPath + data.graphic + ".xml");
		}
		
		for (anim in data.anims)
		{
			animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.looped, anim.flipX, anim.flipY);
		}

		scale.set(Constants.overworldPixelScale, Constants.overworldPixelScale);
		updateHitbox();

		antialiasing = false;
	}

	public function changeAnimationPrefix(prefix:String):Void
	{
		this.animationPrefix = prefix;
		handleCharacterAnimations();
	}
	
	function handleCharacterAnimations():Void
	{
		var direction:String = switch (facing)
		{
			case LEFT: "left";
			case RIGHT: "right";
			case UP: "up";
			case DOWN: "down";
			default: "down";
		};
		moving = ((hitbox.velocity.x != 0 || hitbox.velocity.y != 0)
			&& (hitbox.x != previousPosition.x || hitbox.y != previousPosition.y));
		var type:String = moving ? "walk" : "idle";

		var animName = animationPrefix + type + "_" + direction;

		if (animation.exists(animName))
			animation.play(animName, false);
		else
		{
			if (type == "walk")
				type = "idle";

			animName = animationPrefix + type + "_" + direction;

			if (animation.exists(animName))
				animation.play(animName, false);
		}
		previousPosition.set(hitbox.x, hitbox.y);
	}
    
    function doMovement():Void{
		var speed = Constants.characterSpeed * movementSpeed;
		var diagonalSpeed = Constants.characterSpeedDiagonal * movementSpeed;
        
        switch(status){
            case MOVE_LEFT:
				hitbox.velocity.set(-speed, 0);
				facing = LEFT;
            case MOVE_RIGHT:
				hitbox.velocity.set(speed, 0);
				facing = RIGHT;
            case MOVE_UP:
				hitbox.velocity.set(0, -speed);
				facing = UP;
            case MOVE_DOWN:
				hitbox.velocity.set(0, speed);
				facing = DOWN;
            case MOVE_LEFT_UP:
				hitbox.velocity.set(-diagonalSpeed, -diagonalSpeed);
				facing = UP;
            case MOVE_LEFT_DOWN:
				hitbox.velocity.set(-diagonalSpeed, diagonalSpeed);
				facing = DOWN;
            case MOVE_RIGHT_UP:
				hitbox.velocity.set(diagonalSpeed, -diagonalSpeed);
				facing = UP;
            case MOVE_RIGHT_DOWN:
				hitbox.velocity.set(diagonalSpeed, diagonalSpeed);
				facing = DOWN;
            default:
				hitbox.velocity.set(0, 0);
        }
		if (!lockAnims)
			handleCharacterAnimations();
	}

	function handleAutoMovement():Void
	{
		if (!autoMovementActive)
			return;

		if (autoMovementTarget.x != x && autoMovementDoX)
		{
			if (autoMovementTarget.x < autoMovementStartPosition.x)
			{ // ypure moving to the left
				if (x <= autoMovementTarget.x) // done
				{
					positionCharacter(autoMovementTarget.x, y);
					status = IDLE;
				}
				else
				{
					status = MOVE_LEFT;
				}
			}
			else
			{ // youre moving to the right
				if (x >= autoMovementTarget.x) // done
				{
					positionCharacter(autoMovementTarget.x, y);
					status = IDLE;
				}
				else
				{
					status = MOVE_RIGHT;
				}
			}
		}
		else if (autoMovementTarget.y != y && autoMovementDoY)
		{
			if (autoMovementTarget.y > autoMovementStartPosition.y)
			{ // ypure moving DOWN
				if (y >= autoMovementTarget.y) // done
				{
					positionCharacter(x, autoMovementTarget.y);
					status = IDLE;
				}
				else
				{
					status = MOVE_DOWN;
				}
			}
			else
			{ // youre moving UP
				if (y <= autoMovementTarget.y) // done
				{
					positionCharacter(x, autoMovementTarget.y);
					status = IDLE;
				}
				else
				{
					status = MOVE_UP;
				}
			}
		}

		if ((autoMovementTarget.x == x || !autoMovementDoX) && (autoMovementTarget.y == y || !autoMovementDoY))
		{
			autoMovementActive = false;
			autoMovementTarget.set(-1, -1);
			status = IDLE;
			if (autoMovementComplete != null)
			{
				autoMovementComplete();
			}
		}
	}

	public function positionCharacter(x:Float, y:Float):Void
	{
		setPosition(x, y);
		CtUtil.centerSpriteOnSprite(hitbox, this, true, false);
		hitbox.y = y + height - hitbox.height;
	}
	public function positionCharacterByGrid(x:Float, y:Float):Void
	{
		positionCharacter(((x * Constants.overworldPixelScale) * 16), ((y * Constants.overworldPixelScale) * 16));
	}
	
	public function move(x:Float = -1, y:Float = -1, ?onComplete:Void->Void):Void
	{
		var moveX:Bool = x != -1;
		var moveY:Bool = y != -1;

		autoMovementStartPosition.set(hitbox.x, hitbox.y);
		autoMovementTarget.set(moveX ? x : this.x, moveY ? y : this.y);
		autoMovementActive = true;

		autoMovementComplete = onComplete;
		autoMovementDoX = moveX;
		autoMovementDoY = moveY;

		if (!autoMovementDoX && !autoMovementDoY)
		{
			autoMovementActive = false;

			if (autoMovementComplete != null)
			{
				autoMovementComplete();
			}
		}
	}

	public function moveToGridSpace(x:Float = -1, y:Float = -1, ?onComplete:Void->Void):Void
	{
		var moveX:Bool = x != -1;
		var moveY:Bool = y != -1;

		var trueX:Float = x;
		var trueY:Float = y;

		if (moveX)
			trueX = (x * Constants.overworldPixelScale) * 16;
		if (moveY)
			trueY = (y * Constants.overworldPixelScale) * 16;

		move(trueX, trueY, onComplete);
	}

	override function kill():Void
	{
		super.kill();
		hitbox.kill();
	}

	override function revive():Void
	{
		super.revive();
		hitbox.revive();
	}
}