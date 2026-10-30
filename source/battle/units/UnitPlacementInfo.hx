package battle.units;


typedef UnitPlacementInfo =
{
    var unitID:String; 
    var grid:Grid;
    var position:FlxPoint;
    var controllable:Bool;
    var level:Int;
    var ?doAnim:Null<Bool>;
    var ?placedByPlayer:Null<Bool>; 
    var ?tag:Null<String>;
}