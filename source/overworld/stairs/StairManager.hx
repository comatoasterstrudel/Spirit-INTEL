package overworld.stairs;

class StairManager extends FlxBasic
{
    var stairs:Array<StairTrigger> = [];
    var characters:Array<Character> = [];

    public function new():Void{
        super();
        stairs = [];
        characters = [];
    }

    override function update(elapsed:Float):Void{
        super.update(elapsed);

        for(character in characters){
            character.onStairs = false;

            for(stair in stairs){
                if(CtUtil.isSpriteFullyInside(character.hitbox, stair)){
                    character.onStairs = true;
                    character.stairsMode = stair.mode;
                    break;
                }
            }
        }
    }

    public function addStairs(stair:StairTrigger):Void{
        stairs.push(stair);
    }

    public function addCharacter(character:Character):Void{
        characters.push(character);
    }
}