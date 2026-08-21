package overworld.props;

class PropData extends CtJsonLoader
{
 	public var id:String;
    
    public var name:String;
    public var graphic:String;
    
    public var hitboxX:Int; 
    public var hitboxY:Int;

    public var hitboxWidth:Int;
    public var hitboxHeight:Int;
    
	public var yStackingOffset:Int;

    public function new(id:String){
        this.id = id;
        
		super(Constants.propDataPath + id + '.json', Constants.propDataPath + 'lobbydesk.json');
        
        this.name = data.name;
        this.graphic = data.graphic;
        
        this.hitboxX = data.hitboxX ?? 0;
        this.hitboxY = data.hitboxY ?? 0;
        
        this.hitboxWidth = data.hitboxWidth;
        this.hitboxHeight = data.hitboxHeight;
		this.yStackingOffset = data.yStackingOffset ?? 0;
    }
}