package overworld.tilemap;

import overworld.footstep.FootstepData;

class TilesetData extends CtJsonLoader
{
	public var id:String;

    public var name:String;
    
    public var graphic:String;
    
    public var collisions:Array<String>;
    
    public var footsteps:Array<FootstepData>;

    public function new(id:String){
        this.id = id;
        
		super(Constants.tilesetDataPath + id + '.json', Constants.tilesetDataPath + 'placeholder.json');
        
        var usethis:Array<String> = [];
        
        this.name = data.name;
        this.graphic = data.graphic ?? "placeholder";
        this.collisions = data.collisions ?? usethis;

        if(data.footsteps == null){
            this.footsteps = [];
        } else {
            this.footsteps = data.footsteps.map(function(item)
            {
                return {
                    tiles: item.tiles ?? [],
                    graphics: item.graphics ?? [],
                };
            });
        }
    }
}
        