package overworld.playermenu.polaroid;

class PlayerMenuPolaroid extends FlxSpriteGroup
{
    var bordershadow:CtSprite;
    var bg:CtSprite;
    var pola:CtSprite;
    var border:CtSprite;
    
    var bgCenter:CtSprite;
    
    var hScript:CtScript;
    
    public function new(bgCenter:CtSprite):Void{
        super();
        
        this.bgCenter;
        
        bordershadow = new CtSprite().createFromImage(Constants.playerMenuPolaroidBorderShadowPath);
        bordershadow.antialiasing = false;
        bordershadow.alpha = .5;
        add(bordershadow);
        
        bg = new CtSprite().createFromImage(getBgPath());
        bg.antialiasing = false;
        add(bg);
        
        pola = new CtSprite().createFromImage(getPolaPath());
        pola.antialiasing = false;
        add(pola);
        
        border = new CtSprite().createFromImage(Constants.playerMenuPolaroidBorderPath);
        border.antialiasing = false;
        add(border);
        
        CtUtil.centerSpriteOnSprite(border, bgCenter, true, false);
        
		border.y = bgCenter.y + 50;
        
        for(spr in [bordershadow, bg, pola]){
            spr.setPosition(border.x, border.y);
        }
        
        bordershadow.y += 10;
    }
    
    function getBgPath():String
    {
        var customBg:String = Constants.playerMenuPolaroidBgPath + OverworldState.roomData.polaroidBg + ".png";

        if(Assets.exists(customBg)){
            return customBg;    
        }

        var specificBg:String = Constants.playerMenuPolaroidBgPath + (OverworldState.roomName.split("_")[0]) + ".png";
        
        if(Assets.exists(specificBg)){
            return specificBg;    
        }
        
        return Constants.playerMenuPolaroidBgPath + "placeholder.png";
    }
    
    function getPolaPath():String
    {
        hScript = new CtScript(Constants.playerMenuPolaroidScriptPath);
        return Constants.playerMenuPolaroidImgPath + hScript.executeFunction("getPath") + ".png";
    }
}