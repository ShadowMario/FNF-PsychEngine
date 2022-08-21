package mod_support_stuff;

import flixel.graphics.frames.FlxAtlasFrames;

typedef MenuOption = {
	var name:String; // 'story mode'
	var onSelect:Void->Void; // function() {}
	var frames:FlxAtlasFrames; // Paths.getSparrowAtlas
	var idle:String; // 'story mode basic'
	@:optional var idleFPS:Null<Int>; // 24
	var selected:String; // 'story mode white'
	@:optional var selectedFPS:Null<Int>; // 24
    @:optional var direct:Null<Bool>; // true if it does the action directly like the "donate" button
}

class MenuOptions {
    public var members:Array<MenuOption> = [];
    public function new(?anims:Array<MenuOption>) {
        if (anims != null) members = anims;
    }

    public function add(name:String, onSelect:Void->Void, frames:FlxAtlasFrames, idle:String, selected:String):MenuOption {
        var obj:MenuOption = {
            name: name,
            onSelect: onSelect,
            frames: frames,
            idle: idle,
            selected: selected
        };
        members.push(obj);
        return obj;
    }

    public function remove(name:String) {
        for (e in members) {
            if (e.name.toLowerCase() == name.toLowerCase()) {
                members.remove(e);
                break;
            }
        }
    }

    public function _add(option:MenuOption) {
        members.push(option);
    }

    public function _insert(index:Int, option:MenuOption) {
        members.insert(index, option);
    }

    public function insert(index:Int, name:String, onSelect:Void->Void, frames:FlxAtlasFrames, idle:String, selected:String) {
        members.insert(index, {
            name: name,
            onSelect: onSelect,
            frames: frames,
            idle: idle,
            selected: selected
        });
    }

    public var length(get, null):Int;
    private function get_length() {return members.length;};
}