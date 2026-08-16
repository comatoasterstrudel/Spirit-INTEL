package overworld.door;

class DoorData extends CtJsonLoader
{
    var id:String;
    
    public var name:String;
    public var graphic:String;
    
    public var openUpSound:String;
    public var openDownSound:String;
    public var lockSound:String;

    public function new(id:String){
        this.id = id;
        
        super(Constants.doorDataPath + id + '.json', Constants.doorDataPath + 'placeholder.json');
        
        this.name = data.name;
        this.graphic = data.graphic;
        
        this.openUpSound = data.openUpSound ?? "";
        this.openDownSound = data.openDownSound ?? "";
        this.lockSound = data.lockSound ?? "";
    }
}