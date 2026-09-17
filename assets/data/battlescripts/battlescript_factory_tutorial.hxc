function CTSCRIPT_SETNAME():String
{
	return "factory_tutorial";
}

/**
 * 0: On the first turn, display a message telling the player about the grids
 * 1: When the next allied units turn starts, start the message telling the player to select a skill
 * 2: Tell the player to select the enemy on the grid
 * 3: "great!!" then tell the player that the enemy will act
 */
var tutorialProgress:Int = 0;

var unit_manager:Unit;

var dialogueBox:CtDialogueBox;

var lastHp:Int = 0;

var bgLine:CtSprite;

function create(){
    set_disableInspectButton(true);
    set_disableEndTurnButton(true);

    unit_manager = getUnitByTag("manager");

    dialogueBox = get_dialogueBox();

    bgLine = get_bgLine();

    PlayState.preventBattleEnding = true;
}

function update(elapsed:Float){
    //
}

function onAdvanceTurn():Void{
    switch(tutorialProgress){
        case 0:
            PlayState.battleFrozen = true;

            new FlxTimer().start(1, function(f):Void{
                startDialogue(["factory/hallway/tutorial/dialogue_tut_0"], function():Void{
                    // zoom in on grids

                    startDialogue(["factory/hallway/tutorial/dialogue_tut_1"], function():Void{
                        placeUnit("partyhat", allyGrid, FlxPoint.get(1, 1), true);
                        calculateTurnOrder();

                        PlayState.preventBattleEnding = false;

                        new FlxTimer().start(1.5, function(f):Void{
                            tutorialProgress = 1;

                            PlayState.battleFrozen = false;
                            advanceTurn(0);
                        });
                    });

                    dialogueBox.onEvent.add(function(event:String):Void
                    {
                        if (event == "shake")
                        {
                            camDialogue.shake(0.02, .2, null, true, 0x01);
                        }
                    });
                });
            });
        case 3:
            PlayState.battleFrozen = true;

            var advance:Bool = unit_manager.hp.value < unit_manager.maxHp.value;

            if(advance){
                lastHp = unit_manager.hp.value;

                startDialogue(["factory/hallway/tutorial/dialogue_tut_5"], function():Void{
                    // zoom in on turn order

                    startDialogue(["factory/hallway/tutorial/dialogue_tut_6"], function():Void{
                        tutorialProgress = 4;

                        PlayState.battleFrozen = false;
                        advanceTurn(1);
                    });
                });   
            } else {
                startDialogue(["factory/hallway/tutorial/dialogue_tut_nonono"], function():Void{
                    tutorialProgress = -999;
                    PlayState.battleFrozen = false;
                    advanceTurn(0);
                });
            }
        case 4:
            tutorialProgress = 5;
        case 5:
            PlayState.battleFrozen = true;
            startDialogue(["factory/hallway/tutorial/dialogue_tut_7"], function():Void{
                tutorialProgress = 6;

                set_disableInspectButton(false);

                PlayState.battleFrozen = false;
                advanceTurn(1);
            });
        case 7:
            PlayState.battleFrozen = true;

            var advance = (unit_manager.hp.value < lastHp);

            if(advance){
                lastHp = unit_manager.hp.value;

                startDialogue(["factory/hallway/tutorial/dialogue_tut_10"], function():Void{
                    // zoom in on mp

                    startDialogue(["factory/hallway/tutorial/dialogue_tut_11"], function():Void{
                        tutorialProgress = 8;

                        PlayState.battleFrozen = false;
                        advanceTurn(1);
                    });
                });   
            } else {
                startDialogue(["factory/hallway/tutorial/dialogue_tut_miss2"], function():Void{
                    tutorialProgress = -9999;
                    PlayState.battleFrozen = false;
                    advanceTurn(0);
                });
            }
        case 8:
            tutorialProgress = 9;
        case 9:
            PlayState.battleFrozen = true;
            startDialogue(["factory/hallway/tutorial/dialogue_tut_12"], function():Void{
                tutorialProgress = 10;

                set_disableEndTurnButton(false);

                PlayState.battleFrozen = false;
                advanceTurn(1);
            });
        case 11:
            PlayState.battleFrozen = true;

            var advance = (unit_manager.hp.value < lastHp);

            if(advance){
                lastHp = unit_manager.hp.value;

                startDialogue(["factory/hallway/tutorial/dialogue_tut_15"], function():Void{
                    tutorialProgress = 12;

                    PlayState.battleFrozen = false;
                    advanceTurn(1);
                });   
            } else {
                startDialogue(["factory/hallway/tutorial/dialogue_tut_miss3"], function():Void{
                    tutorialProgress = 12;

                    PlayState.battleFrozen = false;
                    advanceTurn(1);
                });
            }
        case 12:
            tutorialProgress = 13;
        case 13:
            PlayState.battleFrozen = true;
            doEndScene();
        case -999: // odd
            tutorialProgress = 3;
        case -9999:
            tutorialProgress = 7;
    }
}

function onStartPlayerTurn():Void{
    switch(tutorialProgress){
        case 1:
            menuManagerPlayerUI.disable();

            startDialogue(["factory/hallway/tutorial/dialogue_tut_2"], function():Void{

                // zoom in on skills

                startDialogue(["factory/hallway/tutorial/dialogue_tut_3"], function():Void{
                    tutorialProgress = 2;

                    menuManagerPlayerUI.enable();
                });
            });
        case 6:
            menuManagerPlayerUI.disable();

            startDialogue(["factory/hallway/tutorial/dialogue_tut_8"], function():Void{
                // zoom in on inspect btton

                startDialogue(["factory/hallway/tutorial/dialogue_tut_9"], function():Void{
                    tutorialProgress = 7;

                    menuManagerPlayerUI.enable();
                });
            });
        case 10:
            menuManagerPlayerUI.disable();

            startDialogue(["factory/hallway/tutorial/dialogue_tut_13"], function():Void{
                // zoom in on end turn btton

                startDialogue(["factory/hallway/tutorial/dialogue_tut_14"], function():Void{
                    tutorialProgress = 11;

                    menuManagerPlayerUI.enable();
                });
            });
    }
}

function onAddGridSelector():Void{
    switch(tutorialProgress){
        case 2:
            menuManagerGridSelector.disable();

            startDialogue(["factory/hallway/tutorial/dialogue_tut_4"], function():Void{
                tutorialProgress = 3;

                menuManagerGridSelector.enable();
            }); 
    }
}

var laurinGrid:Grid;
var gridBg:GridBackground;

var larinGun:CtSprite;

function doEndScene():Void
{
    startDialogue(["factory/hallway/tutorial/dialogue_tut_16"], function():Void{
        for (ui in [get_bottomBar(), get_turnOrderDisplay()])
        {
            FlxTween.tween(ui, {alpha: 0}, 3);
        }

        FlxG.sound.music.fadeOut(3);

        new FlxTimer().start(1, function(f):Void{
            startDialogue(["factory/hallway/tutorial/dialogue_tut_17"], function():Void{
                new FlxTimer().start(3, function(f):Void{
                    var gridSize = FlxPoint.get(1,1);

                    laurinGrid = new Grid(gridSize, FlxPoint.get(FlxG.width - 175, (bgLine.y + bgLine.height / 2) - (Grid.calculateGridSize(FlxPoint.get(1, 1)).y / 2)));
		            laurinGrid.camera = camGame;

                    gridBg = new GridBackground(laurinGrid);
                    gridBg.camera = camGame;
                    add(gridBg);

                    add(laurinGrid);

                    CtSound.play(Constants.sfxPath + "gridplacebig.ogg");

                    new FlxTimer().start(2, function(f):Void{
                        startDialogue(["factory/hallway/tutorial/dialogue_tut_18"], function():Void{
                            laurinGun = new CtSprite().createFromImage(Constants.battleMiscGraphicPath + "lauringun.png");
                            CtUtil.centerSpriteOnSprite(laurinGun, laurinGrid.spaces[0].baseSprite, true, true);
                            laurinGun.x += 200;
                            laurinGun.antialiasing = false;
                            laurinGun.camera = camGame;
                            add(laurinGun);

                            FlxTween.tween(laurinGun, {x: laurinGun.x - 200}, 3, {onComplete: function(f):Void{
                                var thing = new CtSprite().createColorBlock(FlxG.width, FlxG.height, 0xFFFFFFFF);
                                thing.camera = camUI;
                                thing.alpha = 0;
                                add(thing);

                                CtSound.play(Constants.sfxPath + "gunreload.ogg");

                                FlxTween.tween(thing, {alpha: 1}, 3, {onComplete: function(f):Void{
                                    OverworldState.roomName = "factory_hallway";
                                    goBackToOverworld();
                                }});
                            }});
                        });
                    });
                });
            }); 
        });
    }); 
}