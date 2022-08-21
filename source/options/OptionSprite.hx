package options;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class OptionSprite extends FlxSpriteGroup {
    public var name:String = "";
    public var desc:String = "";
    public var value:String = "";
    public var _nameAlphabet:AlphabetOptimized;
    public var _descAlphabet:AlphabetOptimized;
    public var _valueAlphabet:AlphabetOptimized;
    public var _icon:FlxSprite;
    public var optionWidth:Int = FlxG.width - 200;
    public var onCreate:OptionSprite->Void = null;
    public var onUpdate:OptionSprite->Void = null;
    public var onSelect:OptionSprite->Void = null;
    public var onEnter:OptionSprite->Void = null;
    public var onLeft:OptionSprite->Void = null;
    public function new(option:FunkinOption) {
        super();
        name = option.name;
        desc = option.desc;
        value = option.value;
        _nameAlphabet = new AlphabetOptimized(150, 0, option.name, true, 0.75);
        add(_nameAlphabet);
        _descAlphabet = new AlphabetOptimized(155, 60, option.desc, false, 1/3);
        _descAlphabet.maxWidth = FlxG.width - 310;
        add(_descAlphabet);
        _icon = new FlxSprite(40, 0);
        if (option.img != null)
            _icon.loadGraphic(option.img);
        else
            _icon.makeGraphic(100, 100, 0);
        
        _icon.setGraphicSize(100, 100);
        _icon.updateHitbox();
        _icon.antialiasing = true;
        add(_icon);
        _valueAlphabet = new AlphabetOptimized(100, 20, option.value, false, 0.6);
        _valueAlphabet.outline = true;
        add(_valueAlphabet);
        onCreate = option.onCreate;
        onSelect = option.onSelect;
        onUpdate = option.onUpdate;
        onEnter = option.onEnter;
        onLeft = option.onLeft;
        if (onCreate != null) onCreate(this);
    }

    public function check(bool:Bool) {
        if (bool) {
            value = "On";
            _valueAlphabet.textColor = 0xFF44FF44;
        } else {
            value = "Off";
            _valueAlphabet.textColor = 0xFFFF4444;
        }
        return bool;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        _nameAlphabet.text = name;
        _descAlphabet.text = desc;
        _valueAlphabet.text = value;
        _valueAlphabet.x = x + (optionWidth) - _valueAlphabet.width;
    }
}