package overworld.scrollingprops;
 
class ScrollingPropData extends CtJsonLoader
{
 	public var id:String;
    
    public var name:String;
    public var graphic:String;
    
	public var yStackingOffset:Int;

    public function new(id:String){
        this.id = id;
        
		super(Constants.scrollingPropDataPath + id + '.json', Constants.scrollingPropDataPath + 'factoryconveyorhorizontal.json');
        
        this.name = data.name;
        this.graphic = data.graphic;

		this.yStackingOffset = data.yStackingOffset ?? 0;
    }
}