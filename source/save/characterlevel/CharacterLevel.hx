package save.characterlevel;

class CharacterLevel
{
    public var name:String;
    public var type:CharacterLevelType;

    public var exp:Int = 0;
    
    public var expFloat:Float = 0;

    public function new(name:String, type:CharacterLevelType, ?exp:Int = 0):Void{
        this.name = name;
        this.type = type;
        this.exp = exp;
    }

    public function getLevel():Int
    {
        return getLevelFromExp(exp);
    }

    public function getCurrentLevelExp():Int
    {
        var finalExp = exp;

        for(level in 0...getLevel()){
            finalExp -= getExpForNextLevel(level);
        }

        return finalExp;
    }

    public function getNextlevelExp():Int
    {
        return getExpForNextLevel(getLevel()) - getCurrentLevelExp();
    }

    // LEVEL CURVE

    public static function getLevelFromExp(exp:Int):Int
    {
        var totalExp = exp;
        var level:Int = 0;

        var stillGoing:Bool = true;

        while(stillGoing){
            totalExp -= getExpForNextLevel(level);

            if(totalExp >= 0){
                level ++;
            } else {
                stillGoing = false;
            }
        }

        return level;
    }

    public static function getExpForNextLevel(level:Int):Int{
        var baseLvlPerExp:Int = Constants.baseLvlPerExp;

        var baseExp:Float = baseLvlPerExp * level;

        baseExp = baseExp * (Constants.levelExpScaling * (level / Constants.maxLevel));

        return Std.int(baseExp);
    }
}