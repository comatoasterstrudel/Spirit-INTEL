package overworld.lighting;

class LightSourceData extends CtJsonLoader 
{
    public var id:String;

    public var name:String;
    public var graphic:String;

    //flickering
    public var flickerChance:Float = 0; // how likely this light is to flicker per frame
    public var flickerGap:Float = 2; // how long until it can flicker again in seconds
    public var flickerSmoothing:Float = 0;
    public var flickerIntensity:Float = .5; // 1 = all the way off, .5 = half transparent
    public var flickerTime:Float = .1;
    
    public function new(id:String){
        this.id = id;
                
        super(Constants.lightSourceDataPath + id + '.json', Constants.lightSourceDataPath + 'test.json');

        this.name = data.name ?? "";
        this.graphic = data.graphic ?? "";

        this.flickerChance = data.flickerChance ?? 0;
        this.flickerGap = data.flickerGap ?? 2;
        this.flickerSmoothing = data.flickerSmoothing ?? 0;
        this.flickerIntensity = data.flickerIntensity ?? 0.5;
        this.flickerTime = data.flickerTime ?? .1;
    }
}