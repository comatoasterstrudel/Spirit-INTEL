package;

class GameStatus
{
    public static function isPrologueDemo():Bool
    {
        #if prologueDemo
        return true;
        #end

        return false;
    }
}