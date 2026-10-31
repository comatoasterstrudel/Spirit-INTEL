package battle.stats;

class Stat
{
    public var name:String = "";
    
    public var min:Int;
    
    public var max:Int;
    
    public var value:Int = 0;
    
    public function new(name:String, ?start:Int, ?min:Int = -55, ?max:Int = -55){
        this.name = name;
        
        if(start != null) value = start;
        
        this.min = min;
        
        this.max = max;
    }
    
    public function changeValue(amount:Int){
        setValue(value + amount);
    }
    
    public function setValue(amount){
        value = amount;
        
        if(min != -55 && value < min) value = min;
        if(max != -55 && value > max) value = max;
    }

    public function getPercent():Float
    {
        if(max == -55) return 0;
        return value / max;
    }
}