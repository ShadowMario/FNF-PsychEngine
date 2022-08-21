import lime.math.Rectangle;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

typedef GraphData = {
    var number:Float;
    var color:FlxColor;
}

class FreeplayGraph {
    public static function generate(data:Array<GraphData>, width:Int = 305, height:Int = 100, thickness:Int = 10) {
        var total:Float = 0;
        for (g in data) total += g.number;

        var maxAngle = Math.PI * 2;
        var bData = new BitmapDataPlus(width, height + thickness, true, 0x00000000);
        var center = new FlxPoint(Math.floor((width / 2) + 1), Math.floor((height / 2) + 1));
        bData.drawEllipse(center, width - 2, height - 2, FlxColor.BLACK, false, 4);
        bData.floodFill(Std.int(center.x), Std.int(center.y), FlxColor.BLACK);
        var current:Float = 0;
        var colorToReplace:FlxColor = FlxColor.BLACK;
        for (g in data) {
            if (g.number <= 0) continue;
            var newColor = g.color;
            newColor.redFloat = newColor.redFloat * 0.8;
            newColor.greenFloat = newColor.greenFloat * 0.8;
            newColor.blueFloat = newColor.blueFloat * 0.8;

            if (newColor == g.color)
                newColor = FlxColor.WHITE;

            var pos = new FlxPoint(center.x + (Math.sin(current / total * maxAngle) * ((width + 2) / 2)), center.y + (Math.cos(current / total * maxAngle) * ((height + 2) / 2)));
            bData.drawLine(center, pos, newColor, 2);
            
            var pos2 = new FlxPoint(
                center.x + 2,
                center.y - (height / 4));
            if (pos2.x > center.x && (pos2.x < pos.x || pos.x <= center.x || pos.y > center.y)) bData.floodFill(Std.int(pos2.x), Std.int(pos2.y), g.color);
            colorToReplace = g.color;

            current += g.number;

            
        }
        for (x in 0...bData.width) {
            for (y in Std.int(bData.height / 3)...bData.height) {
                if (bData.getPixel32(x, y) == FlxColor.TRANSPARENT && bData.getPixel32(x, y - 1) != FlxColor.TRANSPARENT) {
                    var newColor:FlxColor = bData.getPixel32(x, y - 1);
                    newColor.redFloat = newColor.redFloat * 0.8;
                    newColor.greenFloat = newColor.greenFloat * 0.8;
                    newColor.blueFloat = newColor.blueFloat * 0.8;
                    bData.fillRect(new openfl.geom.Rectangle(x, y, 1, thickness), newColor);
                    break;
                }
            }
        }
        
        return bData;
    }
}