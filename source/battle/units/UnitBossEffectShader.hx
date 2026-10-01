package battle.units;

class UnitBossEffectShader extends FlxShader
{
	@:glFragmentSource("
    #pragma header

    #define iResolution vec3(openfl_TextureSize, 0.)
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    
    uniform float progress;
    uniform vec2 textureSize;
    
    void main() {
        vec4 originalPixel = flixel_texture2D(bitmap, openfl_TextureCoordv);
        
        if(originalPixel.a > 0.0){
            gl_FragColor = vec4(1.0, 0.0, 0.0, originalPixel.a);
        }
    }
    ")

    public function new()
	{
		super();
	}
}