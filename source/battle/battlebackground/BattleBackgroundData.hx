package battle.battlebackground;

class BattleBackgroundData extends CtJsonLoader
{
    public var id:String;
    
    public var name:String;
    
	public var uiStyle:String;
    
    public var sprites:Array<BattleBackgroundSpriteInfo> = [];
    
    public var gridBgAlpha:Float;

    public function new(id:String){
        this.id = id;
        
        super(Constants.battleBackgroundDataPath + id + '.json', Constants.battleBackgroundDataPath + 'placeholder.json');
        
        this.name = data.name;
        
		this.uiStyle = data.uiStyle ?? "placeholder";
        
        this.gridBgAlpha = data.gridBgAlpha == null ? 1 : data.gridBgAlpha;

        sprites = data.sprites.map(function(item)
		{            
            return {
				tag: item.tag ?? "",
                type: item.type ?? "color",
                x: item.x ?? 0,
                y: item.y ?? 0,
                scrollX: item.scrollX == null ? 1 : item.scrollX,
                scrollY: item.scrollY == null ? 1 : item.scrollY,
                scaleX: item.scaleX == null ? 1 : item.scaleX,
                scaleY: item.scaleY == null ? 1 : item.scaleY,
                color: item.color ?? [255, 255, 255, 255],
                colorWidth: item.colorWidth ?? 1,
                colorHeight: item.colorHeight ?? 1,
                graphic: item.graphic ?? "",
                alpha: item.alpha ?? 1,
            };
        });
    }
}