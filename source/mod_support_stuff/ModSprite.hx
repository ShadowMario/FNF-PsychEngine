package mod_support_stuff;

import Script.DummyScript;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxCamera;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import Script.HScript;
import flixel.FlxSprite;

class ModSprite extends FlxSprite {
    public var _mod:String = Settings.engineSettings.data.selectedMod;
    public var _scriptName:String = "main";
    public var script:Script = null;
    public var args:Array<Any> = [];

    public function get(key:String) {
        return script.getVariable(key);
    }

    public function set(key:String, val:Dynamic):Dynamic {
        script.setVariable(key, val);
        return val;
    }

    // WILL NEED TO BE IN "Your Mod/sprites/"
    public override function new(x:Float, y:Float, name:String, ?mod:String, ?args:Array<Any>) {
        super(x, y);
        if (args == null) args = [];
        if (name != null) _scriptName = name;
        if (mod != null) _mod = mod;

        var path = '${Paths.modsPath}/$_mod/sprites/$_scriptName';

        script = Script.create(path);
        if (script == null) script = new DummyScript();
        ModSupport.setScriptDefaultVars(script, mod, {});
        script.setScriptObject(this);
        script.setVariable("sprite", this);
        script.loadFile(path);
        var a:Array<Dynamic> = [x, y];
        for(e in args) a.push(e);
        script.executeFunc("new", a);
        script.executeFunc("create", a);
    }

    public override function draw() {
        if (script.executeFunc("draw") != false) {
            super.draw();
        }
    }

    public override function getGraphicMidpoint(?point:FlxPoint):FlxPoint {
        var v:FlxPoint = script.executeFunc("getGraphicMidpoint", [point]);
        if (v != null) return v;
        return super.getGraphicMidpoint(point);
    }

    public override function getRotatedBounds(?newRect:FlxRect):FlxRect {
        var v:FlxRect = script.executeFunc("getRotatedBounds", [newRect]);
        if (v != null) return v;
        return super.getRotatedBounds(newRect);
    }

    public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
        var v:FlxRect = script.executeFunc("getScreenBounds", [newRect, camera]);
        if (v != null) return v;
        return super.getScreenBounds(newRect, camera);
    }

    public override function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool {
        var v:Null<Bool> = script.executeFunc("pixelsOverlapPoint", [point, Mask, Camera]);
        if (v != null) return v;
        return super.pixelsOverlapPoint(point, Mask, Camera);
    }

    public override function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, width:Int = 0, height:Int = 0, unique:Bool = false, ?Key:String):FlxSprite {
        if (script.executeFunc("draw", [graphic, animated, width, height, unique, Key]) != false) {
            super.loadGraphic(graphic, animated, width, height, unique, Key);
        }
        return this;
    }

    public override function destroy() {
        script.executeFunc("destroy");
        super.destroy();
    }

    public override function update(elapsed:Float) {
        script.executeFunc("update", [elapsed]);
        super.update(elapsed);
        script.executeFunc("updatePost", [elapsed]);
    }
}