package overworld.character;

class Player extends Character{
	var interactableHitbox:CtSprite;

	public var interaction = new FlxTypedSignal<CtSprite->Void>();
    
	public var lockMovement:Bool = false;
	
	public var ignoreCollision:Bool = false;
	public function new(name:String)
	{
		super(name, "player");
		interactableHitbox = new CtSprite();
		interactableHitbox.kill();
		hitbox.immovable = false;
		#if showInteractionBox
		FlxG.state.add(interactableHitbox);
		#end
	}

	override function update(elapsed:Float):Void
	{
		var pressedInteract:Bool = CtControls.checkInput("accept", JUSTPRESSED);

		if (pressedInteract)
		{
			doInteraction();
			interactableHitbox.update(elapsed);
		}
		
		super.update(elapsed);

		if (pressedInteract)
		{
			finishInteraction();
		}
	}

	function doInteraction():Void
	{
		var range:Int = Std.int(16 * Constants.overworldPixelScale);
		var trueRange:Int = Std.int(range / 2);

		var horizontal:Bool = (facing == LEFT || facing == RIGHT);
		
		interactableHitbox.revive();
		interactableHitbox.createColorBlock(horizontal ? range : 1, horizontal ? 1 : range, FlxColor.GREEN);
		CtUtil.centerSpriteOnSprite(interactableHitbox, hitbox, true, true);
		switch (facing)
		{
			case DOWN:
				interactableHitbox.y += trueRange;
			case UP:
				interactableHitbox.y -= trueRange;
			case LEFT:
				interactableHitbox.x -= trueRange;
			case RIGHT:
				interactableHitbox.x += trueRange;
			default: //
		}
		interactableHitbox.y += 3;
	}

	function finishInteraction():Void
	{
		interaction.dispatch(interactableHitbox);
		interactableHitbox.kill();
		#if showInteractionBox
		interactableHitbox.camera = camera;
		interactableHitbox.revive();
		#end
	}
    
    override function doMovement(){
		if (lockMovement)
		{
			super.doMovement();
			return;
		}
		
		var left = canMove() && CtControls.checkInput("left", PRESSED);
		var right = canMove() && CtControls.checkInput("right", PRESSED);
		var up = canMove() && CtControls.checkInput("up", PRESSED);
		var down = canMove() && CtControls.checkInput("down", PRESSED);

        if(up && down){
            up = down = false;    
        }
        
        if(left && right){
            left = right = false;
        }
        
        if(left && !right && !up && !down){
            status = MOVE_LEFT;    
        } else if(right && !left && !up && !down){
            status = MOVE_RIGHT;
        } else if(up && !down && !left && !right){
            status = MOVE_UP;
        } else if(down && !left && !right && !up){
            status = MOVE_DOWN;
        } else if(left && up && !down && !right){
            status = MOVE_LEFT_UP;
        } else if(left && down && !up && !right){
            status = MOVE_LEFT_DOWN;
        } else if(right && up && !down && !left){
            status = MOVE_RIGHT_UP;
        } else if(right && down && !up && !left){
            status = MOVE_RIGHT_DOWN;
        } else {
            status = IDLE;
        }
        
        super.doMovement();
    }
	function canMove():Bool
	{
		return !OverworldState.inCutscene;
	}
}