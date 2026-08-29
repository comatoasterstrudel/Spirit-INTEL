package overworld.stairs;

class StairTrigger extends Interactable
{
    public var mode:StairsMode;

    public function new(x:Int, y:Int, width:Int, height:Int, leftIsUp:Bool):Void{
        super();

        addManually(x, y, width, height);

        if(leftIsUp){
            mode = LEFTISUP;
        } else {
            mode = RIGHTISUP;
        }
    }
}