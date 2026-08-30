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
    
    var page_main:PlayerMenuPageMain;
    var page_status:PlayerMenuPageStatus;
    var page_unitselector:PlayerMenuPageUnitSelector;

    public function new():Void{
        super();
        
        initCameras();
        
        bg = new CtSprite().createColorBlock(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = .8;
        bg.camera = camBg;
        add(bg);
        
        initPages();
        
        new FlxTimer().start(0.05, function(f):Void{
            addPage("main");
        });
        
        realignCamera(true);
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
        setActivePage(lastActivePage.tag);
        
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
        if(snap) camUI.scroll.x = xPos;
    }
}