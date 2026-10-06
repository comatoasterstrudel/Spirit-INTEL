package battle.tutorial;

class TutorialZoomer extends FlxSpriteGroup
{
    var baseicon:CtSprite;
    var icon:CtSprite;
    var bars:Array<CtSprite> = [];
    var edges:Array<CtSprite> = [];

    public function new():Void{
        super();

        baseicon = new CtSprite().createColorBlock(1,1,FlxColor.WHITE);
        baseicon.visible = false;
        add(baseicon);

        icon = new CtSprite().createColorBlock(1,1,FlxColor.WHITE);
        icon.visible = false;
        add(icon);

        for (i in 0...4)
        {
            var bar = new CtSprite().createColorBlock(1, 1, FlxColor.BLACK);
            add(bar);
            bars.push(bar);
        }

        for(i in 0...4)
        {
            var edge = new CtSprite().createFromImage(Constants.tutorialZoomerPath);
            edge.antialiasing = false;
            add(edge);
            edges.push(edge);

            switch(i){
                case 1: //top right
                    edge.flipX = true;
                case 2: // bottom left
                    edge.flipY = true;
                case 3: // bottom right
                    edge.flipX = true;
                    edge.flipY = true;
            }
        }

        alpha = 0;
    }

    public function goHere(x:Int, y:Int, width:Int, height:Int, time:Float, ?onComplete:Void->Void):Void{
        var preVol:Float = FlxG.sound.music.volume;

        FlxG.sound.music.volume = preVol / 2;
        
        visible = true;
        alpha = .7;

        icon.setPosition(x, y);
        icon.setGraphicSize(width, height);
        icon.updateHitbox();

        baseicon.setPosition(icon.x, icon.y);
        baseicon.setGraphicSize(icon.width, icon.height);
        baseicon.updateHitbox();

        CtSound.play(Constants.sfx_tutorialappear);

        for(i in 0...bars.length - 1){
            var bar = bars[i];

            switch (i)
            {
                case 0:
                    bar.setGraphicSize((FlxG.width), (Math.ceil((FlxG.height - icon.height) / 2)));
                    bar.updateHitbox();
                case 1:
                    bar.setGraphicSize((Math.ceil((FlxG.width - icon.width) / 2)), (FlxG.height));
                    bar.updateHitbox();
                case 2:
                    bar.setGraphicSize((FlxG.width), (Math.ceil((FlxG.height - icon.height) / 2)));
                    bar.updateHitbox();
                case 3:
                    bar.setGraphicSize((Math.ceil((FlxG.width - icon.width) / 2)), (FlxG.height));
                    bar.updateHitbox();
            }
        }

        new FlxTimer().start(time, function(f):Void{
            FlxTween.tween(FlxG.sound.music, {volume: preVol}, .75);
            FlxTween.tween(icon.scale, {x:icon.width + 70, y: icon.height + 70}, .75);
            FlxTween.tween(this, {alpha: 0}, .75, {onComplete: function(f):Void{
                visible = false;
                if(onComplete != null){
                    onComplete();
                }
            }});
        });
    }

    override public function draw()
	{        
        baseicon.visible = false;
        baseicon.alpha = 0;

        icon.visible = false;
        icon.alpha = 0;
        icon.updateHitbox();
        CtUtil.centerSpriteOnSprite(icon, baseicon, true, true);

        for (i in 0...bars.length)
        {
            bars[i].alpha = alpha;

            switch (i)
            {
                case 0: //top
                    bars[i].setGraphicSize(FlxG.width, icon.y );
                    bars[i].updateHitbox();
                    bars[i].setPosition(FlxG.width / 2 - bars[i].width / 2, icon.y - bars[i].height);
                case 1: //left
                    bars[i].setGraphicSize(icon.x, icon.height);
                    bars[i].updateHitbox();
                    bars[i].setPosition(icon.x - bars[i].width, icon.y);
                case 2: // bottom
                    bars[i].setGraphicSize(FlxG.width, (FlxG.height - (icon.y + icon.height)) );
                    bars[i].updateHitbox();
                    bars[i].setPosition(FlxG.width / 2 - bars[i].width / 2, icon.y + icon.height);
                case 3: // right
                    bars[i].setGraphicSize((FlxG.width - (icon.width + icon.x)), icon.height);
                    bars[i].updateHitbox();
                    bars[i].setPosition(icon.x + icon.width, icon.y);
            }
        }  

        for (i in 0...edges.length)
        {
            edges[i].alpha = alpha;
            var edge = edges[i];
            switch (i)
            {
                case 0: //top left
                    edge.setPosition(icon.x, icon.y);
                case 1: //top right
                    edge.setPosition(icon.x + icon.width - edge.width, icon.y);
                case 2: // bottom left
                    edge.setPosition(icon.x, icon.y + icon.height - edge.height);
                case 3: // bottom right
                    edge.setPosition(icon.x + icon.width - edge.width, icon.y + icon.height - edge.height);
            }
        }  

		super.draw();
	}
}