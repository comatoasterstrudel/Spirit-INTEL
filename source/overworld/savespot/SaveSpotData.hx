package overworld.savespot;

class SaveSpotData extends CtJsonLoader
{
    var id:String;
    
    public var name:String;
    public var graphic:String;
	public var bgName:String;
    public var sound:String;

    public function new(id:String){
        this.id = id;
        
        super(Constants.saveSpotDataPath + id + '.json', Constants.saveSpotDataPath + 'test.json');
        
        this.name = data.name;
        this.graphic = data.graphic;
		this.bgName = data.bgName;
        this.sound = data.sound ?? "";
    }
}