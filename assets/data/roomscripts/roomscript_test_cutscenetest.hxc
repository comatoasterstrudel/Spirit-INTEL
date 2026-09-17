function CTSCRIPT_SETNAME():String
{
	return "test_cutscenetest";
}

var cutsceneRan:Bool = false;

var character_coworkerA:Character;
var character_coworkerC:Character;
var character_player:Character;

function create():Void{
    character_coworkerA = getCharacterByTag("coworkerA");
    character_coworkerC = getCharacterByTag("coworkerC");
    character_player = getCharacterByTag("player");
}

function update(elapsed:Float):Void{
   //
}

function cutsceneStart():Void{
    if(cutsceneRan) return;
    
    set_inCutscene(true);
    set_unbindCamera(true);

    cutsceneRan = true;
    
    var ogCameraY = camGame.scroll.y;
    
	FlxTween.tween(camGame.scroll, {y: 190}, 1, {startDelay: .7});
    
	character_coworkerA.moveToGridSpace(-1, 7, function():Void
	{
		character_coworkerA.move(character_player.x, -1, function():Void
		{
            character_coworkerA.facing = DOWN;
			startDialogue(["test/testcutscene/dialogue_1"], function():Void
			{
                character_coworkerA.facing = UP;
                new FlxTimer().start(.3, function(f):Void{
                    character_coworkerA.facing = LEFT;
                    new FlxTimer().start(.3, function(f):Void{
                        character_coworkerA.facing = RIGHT;
                        
                        new FlxTimer().start(.3, function(f):Void{
                            character_coworkerA.facing = DOWN;
                            
                            new FlxTimer().start(1, function(f):Void{
								startDialogue(["test/testcutscene/dialogue_2"], function():Void
								{
                                    var tran = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFFFFFFFF);
                                    tran.camera = camUI;
                                    tran.alpha = 0;
                                    tran.lerpManager.lerpAlpha = true;
                                    tran.lerpManager.lerpSpeed = 10;
                                    tran.lerpManager.targetAlpha = 1;
                                    add(tran);
                                    
                                    new FlxTimer().start(0.5, function(f):Void{
                                        tran.lerpManager.targetAlpha = 0;
                                        character_coworkerA.kill();
                                        character_coworkerC.positionCharacter(character_coworkerA.x, character_coworkerA.y);
                                        
                                        new FlxTimer().start(1, function(f):Void{
											startDialogue(["test/testcutscene/dialogue_3"], function():Void
											{
                                                FlxTween.tween(camGame.scroll, {y: ogCameraY}, 2, {ease: FlxEase.quartOut});

												character_coworkerC.moveToGridSpace(9, -2, function():Void
												{
                                                    set_inCutscene(false);
                                                    set_unbindCamera(false);
                                               });
                                            });
                                        });
                                    });
                                });
                            });
                        });
                    });
                });
            });
        });
    });
}