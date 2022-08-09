package;

import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.utils.Assets;
import openfl.events.Event;

using StringTools;

// Made by Gtnv (Endev) Me
class DateTime extends TextField
{
    private var days:String;
    private var month:String;
    private var seconds:String;

    public function new(x:Float = 10.0, y:Float = 10.0, colorString:String)
    {
        super();

        this.x = x;
        this.y = y;

        selectable = false;
        mouseEnabled = false;

        defaultTextFormat = new TextFormat("_sans", 12, Std.parseInt(colorString));

        addEventListener(Event.ENTER_FRAME, onDate);

        width = 150;
        height = 70;
    }

    private function onDate(none)
    {
        var ts:String;
        var e:Int = 10;
        var now:Date = Date.now();

        if (now.getHours() <= e)
            hours = '0' + Std.string(now.getHours());
        else
            hours = Std.string(now.getHours());

        if (now.getMinutes() <= e)
            minutes = '0' + Std.string(now.getMinutes());
        else
            minutes = Std.string(now.getMinutes());

        /*if (now.getSeconds() <= e) // this broke ngl
            seconds = '0' + Std.string(now.getSeconds());
        else
            seconds = Std.string(now.getMinutes());*/

        // copied from DateTools.hx lol
        if (now.getHours() >= e + 1) ts = 'PM'; else ts = 'AM';

        // days = Calendar.DAYS_NAME[now.getDay()];
        // month = Calendar.MONTH_NAME[now.getMonth()];

        days = Calendar.days_name_map[now.getDay()]; // or Calendar.days_name_map.get(now.getDay());
        month = Calendar.month_name_map[now.getMonth()]; // or Calendar.month_name_map.get(now.getMonth());

        if (visible)
        {
            // Swag
            text = Std.string('\nTime: ' + hours + ':' + minutes /*+ ':' + seconds*/ + ' ' + ts + '\nDate: ' + month + ' ' + now.getDate() + ', ' + now.getFullYear() + '\nDay: ' + days);
        }
    }

    var hours:String;
    var minutes:String;
}