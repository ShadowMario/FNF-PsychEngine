import flixel.math.FlxMath;
import openfl.geom.Rectangle;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

class BitmapDataPlus extends BitmapData {
    /**
     * Draws a line from `beginPos` to `endPos`
     * @param beginPos Point A of the line, where it'll begin
     * @param endPos Point B of the line, where it'll end.
     * @param color Color of the line
     * @param thickness Thickness of the line
     */
    public function drawLine(beginPos:FlxPoint, endPos:FlxPoint, color:FlxColor, thickness:Float = 2) {
        var loopLength = Math.ceil(Math.sqrt(Math.pow(beginPos.x - endPos.x, 2) + Math.pow(beginPos.y - endPos.y, 2)) * 1.5);
        if (thickness <= 0) return;
        for (i in 0...loopLength) {
            fillRect(new Rectangle(
                beginPos.x + ((beginPos.x - endPos.x) * (i / loopLength)) - Math.floor(thickness / 2),
                beginPos.y + ((beginPos.y - endPos.y) * (i / loopLength)) - Math.floor(thickness / 2),
                Math.ceil(thickness / 2),
                Math.ceil(thickness / 2)
            ), color);
        }
    }

    /**
     * Draws a line from `beginPos` to `endPos` that only overrides one specific color
     * @param beginPos Point A of the line, where it'll begin
     * @param endPos Point B of the line, where it'll end.
     * @param color Color of the line
     * @param replaces Color to replace
     * @param thickness Thickness of the line
     */
    public function drawLineReplacing(beginPos:FlxPoint, endPos:FlxPoint, color:FlxColor, replaces:FlxColor, thickness:Float = 2) {
        var loopLength = Math.ceil(Math.sqrt(Math.pow(beginPos.x - endPos.x, 2) + Math.pow(beginPos.y - endPos.y, 2)) * 1.5);
        if (thickness <= 0) return;
        for (i in 0...loopLength) {
            var pos = new FlxPoint(
                beginPos.x + ((beginPos.x - endPos.x) * (i / loopLength)) - Math.floor(thickness / 2),
                beginPos.y + ((beginPos.y - endPos.y) * (i / loopLength)) - Math.floor(thickness / 2)
            );
            if (getPixel32(Std.int(pos.x + (thickness / 2)), Std.int(pos.y + (thickness / 2))) != replaces) continue;
            fillRect(new Rectangle(
                pos.x, pos.y,
                Math.ceil(thickness),
                Math.ceil(thickness)
            ), color);
        }
    }


    /**
     * Draws a line from `beginPos` to `endPos` that overrides everything except one color.
     * @param beginPos Point A of the line, where it'll begin
     * @param endPos Point B of the line, where it'll end.
     * @param color Color of the line
     * @param ignore Color to ignore
     * @param thickness Thickness of the line
     */
    public function drawLineExceptOn(beginPos:FlxPoint, endPos:FlxPoint, color:FlxColor, ignore:FlxColor, thickness:Float = 2) {
        var loopLength = Math.ceil(Math.sqrt(Math.pow(beginPos.x - endPos.x, 2) + Math.pow(beginPos.y - endPos.y, 2)) * 1.5);
        if (thickness <= 0) return;
        for (i in 0...loopLength) {
            var pos = new FlxPoint(
                beginPos.x + ((beginPos.x - endPos.x) * (i / loopLength)) - Math.floor(thickness / 2),
                beginPos.y + ((beginPos.y - endPos.y) * (i / loopLength)) - Math.floor(thickness / 2)
            );
            if (getPixel32(Std.int(pos.x), Std.int(pos.y)) == ignore) continue;
            fillRect(new Rectangle(
                pos.x, pos.y,
                Math.ceil(thickness / 2),
                Math.ceil(thickness / 2)
            ), color);
        }
    }



    /**
     * Draws a circle from the center `centerPoint` with a radius of `radius`.
     * @param centerPoint Center of the circle
     * @param radius Radius of the circle
     * @param color Color of the circle
     * @param fill Whenever it should fill the circle or not
     * @param thickness How thick the circle's border will be (in pixels)
     * @param step Step (optional, defaults to 360)
     */
    public function drawCircle(centerPoint:FlxPoint, radius:Float, color:FlxColor, fill:Bool = false, thickness:Float = 2, step:Int = 360) {
        drawEllipse(centerPoint, radius * 2, radius * 2, color, fill, thickness, step);
    }

    /**
     * Draws an ellipse from the center `centerPoint` with a width of `width` and a height of `height`.
     * @param centerPoint Center of the circle
     * @param width Radius of the circle
     * @param height Radius of the circle
     * @param color Color of the circle
     * @param fill Whenever it should fill the circle or not
     * @param thickness How thick the circle's border will be (in pixels)
     * @param step Step (optional, automatically calculated if inferior to 1)
     */
    public function drawEllipse(centerPoint:FlxPoint, width:Float, height:Float, color:FlxColor, fill:Bool = false, thickness:Float = 2, ?step:Int = -1) {
        var circleVal = Math.PI * 2;
        if (step <= 0) {
            if (width > height)
                step = Math.ceil(width * 2 * Math.PI);
            else
                step = Math.ceil(height * 2 * Math.PI);
        };
        for (i in 0...step) {
            fillRect(new Rectangle(
                centerPoint.x + (Math.sin(i / step * circleVal) * (width / 2)) - Math.floor(thickness / 2),
                centerPoint.y + (Math.cos(i / step * circleVal) * (height / 2)) - Math.floor(thickness / 2),
                Math.ceil(thickness / 2),
                Math.ceil(thickness / 2)
            ), color);
        }
    }
}