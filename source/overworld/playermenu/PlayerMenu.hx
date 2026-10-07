package overworld.playermenu;

class PlayerMenu extends FlxSubState
{
    var bg:CtSprite;
    
    var camBg:CtCamera;
    var camUI:CtCamera;
    
    // pages

    var pageGroup:FlxSpriteGroup;
    var pages:Array<PlayerMenuPage> = [];
    var openPages:Array<PlayerMenuPage> = [];
    
    public var page_main:PlayerMenuPageMain;
    public var page_status:PlayerMenuPageStatus;
    public var page_unitselector:PlayerMenuPageUnitSelector;
    public var page_unitstatus:PlayerMenuPageUnitStatus;

    public var onStart = new FlxSignal();
    public var onExit = new FlxSignal();

    var doCameraPos:Bool = false;

    public function new():Void{
        super();
        
        initCameras();
         
        bg = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = .3;
        bg.camera = camBg;
        add(bg);
        
        initPages();
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        if(doCameraPos){
            camUI.scroll.x = 0;
            camUI.lerpManager.targetPosition.x = 0;
            doCameraPos = false;
        }
    }

    public function start():Void{
        new FlxTimer().start(0.05, function(f):Void{
            CtMenuManager.playUISound(Constants.sfx_ui_openMenu);
            addPage("main");
        });
        
        realignCamera(true);
        doCameraPos = true;

        onStart.dispatch();
    }
    
    function initCameras():Void{
        camBg = new CtCamera();
        camBg.bgColor.alpha = 0;
        FlxG.cameras.add(camBg, false);
        
        camUI = new CtCamera();
        camUI.bgColor.alpha = 0;
        camUI.lerpManager.lerpX = true;
        FlxG.cameras.add(camUI, false);
    }
    
    function initPages():Void{
        pageGroup = new FlxSpriteGroup();
        pageGroup.camera = camUI;
        add(pageGroup);
        
        page_main = new PlayerMenuPageMain(this);
        pageGroup.add(page_main);
        pages.push(page_main);
        
        page_status = new PlayerMenuPageStatus(this);
        pageGroup.add(page_status);
        pages.push(page_status);

        page_unitselector = new PlayerMenuPageUnitSelector(this);
        pageGroup.add(page_unitselector);
        pages.push(page_unitselector);

        page_unitstatus = new PlayerMenuPageUnitStatus(this);
        pageGroup.add(page_unitstatus);
        pages.push(page_unitstatus);
    }
    
    public function addPage(tag:String):Void{
        var page = getPageByTag(tag);

        if(openPages.length < 1){
            page.openPage(0);   
        } else {
            var lastActivePage = openPages[openPages.length - 1];
            page.openPage(Std.int(lastActivePage.bg.bgCenter.x + lastActivePage.bg.bgCenter.width + 100));   
        }
        
        openPages.push(page);
        
        setActivePage(page.tag);
        
        realignCamera();
    }
    
    public function removePage(tag:String):Void{
        var page = getPageByTag(tag);
        
        page.removeActivePage();
        page.closePage();
        openPages.remove(page);
        
        var lastActivePage = openPages[openPages.length - 1];
        if(lastActivePage != null) setActivePage(lastActivePage.tag);
        
        realignCamera();
    }
    
    function setActivePage(tag:String):Void{
        for(i in pages){
            if(i.tag == tag){
                i.setActivePage();
            } else {
                i.removeActivePage();
            }
        }    
    }
    
    function getPageByTag(tag:String):PlayerMenuPage
    {
        for(page in pages){
            if(page.tag == tag) return page;
        }
        
        return null;
    }
    
    function realignCamera(?snap:Bool = false):Void{
        if(openPages.length < 1) return;
        
        var xPos:Float = 0;
        
        var lastActivePage = openPages[openPages.length - 1];
        xPos = (lastActivePage.bg.bgCenter.x + (lastActivePage.bg.bgCenter.width / 2)) - (FlxG.width / 2);
        
        camUI.lerpManager.targetPosition.x = xPos;
        if(snap) camUI.lerpManager.snap();
    }

    override function close():Void{
        super.close();

        onExit.dispatch();
    }
}