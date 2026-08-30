package overworld.stairs;

class StairTrigger extends Interactable
{
    public var mode:StairsMode;

    public function new(x:Int, y:Int, width:Int, height:Int, leftIsUp:Bool):Void{
        super();

        var widthAdded:Int = Std.int((16 * 1.75) * Constants.overworldPixelScale);

        width += widthAdded;
        x -= Std.int(widthAdded / 2);

        addManually(x, y, width, height);

        if(leftIsUp){
            mode = LEFTISUP;
        } else {
            mode = RIGHTISUP;
        }
    }
}