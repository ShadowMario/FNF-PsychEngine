package flxanimate.animate;

import flixel.FlxG;
import flxanimate.data.AnimationData;

class FlxSymbol
{
    public var timeline(default, null):Timeline;

    public var length(default, null):Int;

    public var name(default, null):String;

    public var labels(default, null):Map<String, FlxLabel>;

    var _labels:Array<String>;
    
    public var layers(default, null):Array<String>;

    @:allow(flxanimate.FlxAnimate)
    var _layers:Array<String>;
    
    public var curFrame:Int;
    
    var _tick:Float;
    
    @:allow(flxanimate.animate.FlxAnim)
    function new(name:String, timeline:Timeline)
    {
        layers = [];
        _layers = [];
        labels = [];
        _labels = [];
        curFrame = 0;
        for (layer in timeline.L)
		{
            parseLayer(layer);
        }
        this.timeline = timeline;
        this.name = name;
    }

    function parseLayer(layer:Layers)
    {
        layers.push(layer.LN);
        _layers.push(layer.LN);
        for (fr in layer.FR)
        {
            if (fr.N != null)
            {
                labels.set(fr.N, new FlxLabel(fr.N, fr.I));
                _labels.push(fr.N);
            }
            if (length < fr.I + fr.DU - 1)
                length = fr.I + fr.DU - 1;
        }
    }
    public function hideLayer(layer:String)
    {
        if (_layers.indexOf(layer) == -1)
            FlxG.log.error((layers.indexOf(layer) != -1) ? 'Layer "$layer" is already hidden!' :'There is no layer called "$layer"!');
        _layers.remove(layer);
    }
    public function showLayer(layer:String)
    {
        if (layers.indexOf(layer) == -1)
        {
            FlxG.log.error('There is no layer called "$layer"!');
            return;
        }
        if (_layers.indexOf(layer) != -1)
        {
            FlxG.log.error('Layer "$layer" is not hidden!');
            return;
        }
        _layers.push(layer);
    }
    public function addCallbackTo(label:String, callback:()->Void)
    {
        if (!labels.exists(label))
        {
            FlxG.log.error('there is not label called "$label"!');
            return;
        }
        var label = labels.get(label);
        
        if (label.callbacks.indexOf(callback) != -1)
        {
            FlxG.log.error("this callback already exists!");
            return;
        }
        label.callbacks.push(callback);
    }
    public function removeCallbackFrom(label:String, callback:()->Void)
    {
        if (!labels.exists(label))
        {
            FlxG.log.error('there is not label called "$label"!');
            return;
        }
        var label = labels.get(label);
        
        if (label.callbacks.indexOf(callback) == -1)
        {
            FlxG.log.error("this callback doesn't exist!");
        }
        label.callbacks.remove(callback);
    }
    public function removeAllCallbacksFrom(label:String)
    {
        if (!labels.exists(label))
        {
            FlxG.log.error('there is not label called "$label"!');
            return;
        }
        labels.get(label).removeCallbacks();
    }
    public function getNextToFrameLabel(label:String):FlxLabel
    {
        var good:Bool = false;
        for (_label in _labels)
        {
            if (good)
                return labels.get(_label);
            if (_label == label)
                good = true;
        }
        
        FlxG.log.error('"$label" doesnt exist! Maybe you misspelled it?');
        return null;
    }
    public function frameControl(frame:Int, loopType:LoopType)
    {
        if (frame < 0)
		{
			if ([loop, "loop"].indexOf(loopType) != -1)
				frame += (length > 0) ? length - 1 : frame;
			else
			{
				frame = 0;
			}
			
		}
		else if (frame > length - 1)
		{
			if ([loop, "loop"].indexOf(loopType) != -1)
			{
				frame -= (length > 0) ? length - 1 : frame;
			}
			else
			{
				frame = length - 1;
			}
		}

        return frame;
    }

    public function update(framerate:Float, reversed:Bool, loopType:LoopType)
    {
        _tick += FlxG.elapsed;
        var delay = 1 / framerate;

        while (_tick > delay)
        {
            curFrame = frameControl(curFrame + ((reversed) ? -1 : 1), loopType);
            _tick -= delay;
        }
    }
    @:allow(flxanimate.FlxAnimate)
    function prepareFrame(layer:Layers, frame:Int)
    {
        var i = 0;
        var curFrame = layer.FR[i];
        while ((curFrame.I + curFrame.DU - 1) < frame)
        {
            i++;
            curFrame = layer.FR[i];
            if (curFrame == null) return curFrame;
        }
        
        return curFrame;
    }
    public static function prepareMatrix(m3d:OneOfTwo<Array<Float>, Matrix3D>, pos:TransformationPoint)
	{
		if (m3d == null || m3d == [])
			m3d = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
        if (!(m3d is Array))
            m3d = [for (i in Reflect.fields(m3d)) Reflect.field(m3d, i)];

        if (pos == null)
            pos = {x: 0, y: 0};
		return new flixel.math.FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12] + pos.x, m3d[13] + pos.y);
	}
}