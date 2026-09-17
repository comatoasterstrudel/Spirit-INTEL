function CTSCRIPT_SETNAME():String
{
	return "factory_intro";
}

var roomTrigger:Interactable;

var sprites:FlxSpriteGroup;
var spr_bgColor:CtSprite;
var spr_bg:CtSprite;
var spr_crowdBack:CtSprite;
var spr_robin:CtSprite;
var spr_crowdFront:CtSprite;

var leaving:Bool = false;

function create():Void{
    roomTrigger = getInteractableByTag("roomtrigger");
    roomTrigger.disabled = true;
    
	setupBg();

	OverworldState.lastTransitionTime = 3;

	new FlxTimer().start(3, function(f):Void
	{
		startDialogue(["factory/intro/dialogue_intro"], function():Void
		{
			leaving = true;
			roomTrigger.disabled = false;
		});   
	});
}

function setupBg():Void
{
	sprites = new FlxSpriteGroup();
	sprites.camera = camOverlay;
	add(sprites);

	spr_bgColor = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "factory_bgColor.png", 1.05);
	spr_bgColor.screenCenter();
	spr_bgColor.scrollFactor.set(0, 0);
	sprites.add(spr_bgColor);
	
	spr_bg = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "factory_bg.png", 1.05);
	spr_bg.screenCenter();
	spr_bg.scrollFactor.set(0.1, 0.1);
	sprites.add(spr_bg);

	spr_crowdBack = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "factory_crowdBack.png", 1.05);
	spr_crowdBack.screenCenter();
	spr_crowdBack.scrollFactor.set(0.8, 0.8);
	sprites.add(spr_crowdBack);

	spr_robin = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "factory_robin.png", 1.05);
	spr_robin.screenCenter();
	sprites.add(spr_robin);

	spr_crowdFront = new CtSprite().createFromImage(Constants.overworldCutsceneGraphicPath + "factory_crowdFront.png", 1.05);
	spr_crowdFront.screenCenter();
	spr_crowdFront.scrollFactor.set(1.2, 1.2);
	sprites.add(spr_crowdFront);
	camGame.visible = false;

	doBump();
	doScroll();
}

function doBump():Void
{
	if (leaving)
		return;

	new FlxTimer().start(FlxG.random.float(5, 11), function(f):Void
	{
		camOverlay.scroll.y += (FlxG.random.bool(50)) ? FlxG.random.float(5, 12) : FlxG.random.float(-12, -5);

		FlxTween.tween(camOverlay.scroll, {y: 0}, 1.2, {
			ease: FlxEase.elasticOut,
			onComplete: function(f):Void
			{
				doBump();
			}
		});
	});
}

function doScroll():Void
{
	var scrollamount:Float = 12;

	camOverlay.scroll.x = -scrollamount;

	FlxTween.tween(camOverlay.scroll, {x: scrollamount}, 5, {
		type: 4,
		ease: FlxEase.quadInOut
	});
}