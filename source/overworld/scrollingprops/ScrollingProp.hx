package overworld.scrollingprops;

class ScrollingProp extends CtCroppedBackdrop
{
    public var data:ScrollingPropData;

    public var tag:String = "";
    
    public function new(tag:String, name:String, x:Int, y:Int, cropWidth:Int, cropHeight:Int):Void{
        data = Registry.get(ScrollingPropData, name);

        super(Constants.scrollingPropImagePath + data.graphic + ".png", x, y, cropWidth, cropHeight);

        this.tag = tag;
    }
} 