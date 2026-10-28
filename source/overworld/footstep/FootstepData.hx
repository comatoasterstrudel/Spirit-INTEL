package overworld.footstep;

class FootstepData extends CtJsonLoader
{
    var id:String;
    
    public var name:String;
    public var graphics:Array<String>;

    public function new(id:String){
        this.id = id;
        
        super(Constants.footstepDataPath + id + '.json', Constants.footstepDataPath + 'factorysnow.json');
        
        this.name = data.name ?? "";
        this.graphics = data.graphics ?? cast [];
    }
}