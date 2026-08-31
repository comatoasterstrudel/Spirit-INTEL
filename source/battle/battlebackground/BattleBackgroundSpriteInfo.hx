package battle.battlebackground;

typedef BattleBackgroundSpriteInfo =
{
    var tag:String;
    
    var type:String; // either graphic or color
    
    var x:Int;
    var y:Int;

    var scrollX:Float;
    var scrollY:Float;
    
    var scaleX:Float;
    var scaleY:Float;
    
    var color:Array<Int>;
    var colorWidth:Int;
    var colorHeight:Int;
    
    var graphic:String;

    var alpha:Float;
}