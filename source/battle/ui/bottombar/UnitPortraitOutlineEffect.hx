package battle.ui.bottombar;

/*
    thanks 
    https://gist.github.com/AustinEast/d3892fdf6a6079366fffde071f0c2bae
*/
class UnitPortraitOutlineEffect extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform vec2 size;
        uniform vec4 color;

        void main()
        {
            vec4 sample = flixel_texture2D(bitmap, openfl_TextureCoordv);
            if (sample.a == 0.) {
                float w = size.x / openfl_TextureSize.x;
                float h = size.y / openfl_TextureSize.y;
                
                if (flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x + w, openfl_TextureCoordv.y)).a != 0.
                || flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x - w, openfl_TextureCoordv.y)).a != 0.
                || flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y + h)).a != 0.
                || flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y - h)).a != 0.)
                    sample = color;
            }
            gl_FragColor = sample;
        }')

	public function new()
	{
		super();
        updateValues();
	}

    public function updateValues(color:FlxColor = 0xFFFFFFFF, width:Float = 1, height:Float = 1):Void{
        this.color.value = [color.red, color.green, color.blue, color.alpha];
		this.size.value = [width, height];
    }
}