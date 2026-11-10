package overworld.lighting;

class LightSourceData extends CtJsonLoader 
{
    public var id:String;

    public var name:String;
    public var graphic:String;

    public function new(id:String){
        this.id = id;
                
        super(Constants.lightSourceDataPath + id + '.json', Constants.lightSourceDataPath + 'test.json');

        this.name = data.name ?? "";
        this.graphic = data.graphic ?? "";
    }
}