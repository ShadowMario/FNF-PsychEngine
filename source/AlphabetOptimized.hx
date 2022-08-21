import flixel.FlxCamera;
import mod_support_stuff.AlphabetJson;
import haxe.Json;
import openfl.utils.Assets;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;
class AlphabetOptimized extends FlxSpriteGroup {
    public var frameOffset:Float = 0;
    public var doOptimisationStuff:Bool = true;
    public static inline var letters:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    public var textColor:FlxColor = 0xFFFFFFFF;
    public var textColorSequences:Map<Int, FlxColor> = null;

    public var outline:Bool = false;

    public static final showOnTopAnims = [
        "'", "*", "apostraphie", "start parentheses"
    ];
    public static final centerAnims = [
        "-", "bullet"
    ];
    public static final nonBoldLetters:Dynamic = {
        "_": "_",
        "#": "hashtag ",
        "$": "dollarsign ",
        "%": "%",
        "&": "&",
        "(": "(",
        ")": ")",
        "*": "*",
        "+": "+",
        "-": "-",
        "0": "0",
        "1": "1",
        "2": "2",
        "3": "3",
        "4": "4",
        "5": "5",
        "6": "6",
        "7": "7",
        "8": "8",
        "9": "9",
        ":": ":",
        ";": ";",
        "<": "<",
        ">": ">",
        "@": "@",
        "]": "]",
        "[": "[",
        "\\": "\\",
        "`": "apostraphie",
        "'": "apostraphie",
        ",": "comma",
        "↓": "down arrow",
        "\"": "start parentheses",
        "!": "exclamation point",
        "/": "forward slash",
        "❤️": "heart",
        "←": "left arrow",
        "×": "multiply x",
        "?": "question mark",
        "→": "right arrow",
        "↑": "up arrow",
        "|": "|",
        "~": "~",
        ".": "period",
        "•": "bullet",
    
        "😡": "angry faic", // so that ng emoticon can be used
    
        "A": "A capital",
        "B": "B capital",
        "C": "C capital",
        "D": "D capital",
        "E": "E capital",
        "F": "F capital",
        "G": "G capital",
        "H": "H capital",
        "I": "I capital",
        "J": "J capital",
        "K": "K capital",
        "L": "L capital",
        "M": "M capital",
        "N": "N capital",
        "O": "O capital",
        "P": "P capital",
        "Q": "Q capital",
        "R": "R capital",
        "S": "S capital",
        "T": "T capital",
        "U": "U capital",
        "V": "V capital",
        "W": "W capital",
        "X": "X capital",
        "Y": "Y capital",
        "Z": "Z capital",
    
        "a": "a lowercase",
        "b": "b lowercase",
        "c": "c lowercase",
        "d": "d lowercase",
        "e": "e lowercase",
        "f": "f lowercase",
        "g": "g lowercase",
        "h": "h lowercase",
        "i": "i lowercase",
        "j": "j lowercase",
        "k": "k lowercase",
        "l": "l lowercase",
        "m": "m lowercase",
        "n": "n lowercase",
        "o": "o lowercase",
        "p": "p lowercase",
        "q": "q lowercase",
        "r": "r lowercase",
        "s": "s lowercase",
        "t": "t lowercase",
        "u": "u lowercase",
        "v": "v lowercase",
        "w": "w lowercase",
        "x": "x lowercase",
        "y": "y lowercase",
        "z": "z lowercase",
    
        "é": "é lowercase",
        "è": "è lowercase",
        "ê": "ê lowercase"
    };

    public static final _letters:Array<Array<String>> = [
        ["A", "A bold"],
        ["B", "B bold"],
        ["C", "C bold"],
        ["D", "D bold"],
        ["E", "E bold"],
        ["F", "F bold"],
        ["G", "G bold"],
        ["H", "H bold"],
        ["I", "I bold"],
        ["J", "J bold"],
        ["K", "K bold"],
        ["L", "L bold"],
        ["M", "M bold"],
        ["N", "N bold"],
        ["O", "O bold"],
        ["P", "P bold"],
        ["Q", "Q bold"],
        ["R", "R bold"],
        ["S", "S bold"],
        ["T", "T bold"],
        ["U", "U bold"],
        ["V", "V bold"],
        ["W", "W bold"],
        ["X", "X bold"],
        ["Y", "Y bold"],
        ["Z", "Z bold"]
    ];
    public var text(default, set):String = "";

    private var __ready:Bool = false;
    public function set_text(t:String) {
        if (!__ready) return text = t;
        if (text != (text = t)) {
            calculateShit(false);
        }
        return text;
    }
    public var letterSprite:FlxSprite;
    public var letterShaders:Map<String, OutlineShader>; // cause openfl is dumb
    
    public var normalShader:FlxShader;

    public var isMenuItem:Bool = false;
    public var targetY:Int = 0;

    public var textSize:Float = 1;

    public var bold:Bool = false;
    public var correctWrap:Bool = true;

    public var __cacheWidth:Float = -1;

    public var maxWidth:Float = 0;
    public var cutPoint:Int = -1;
	/**
	 * If false, the Alphabet will go to the target Y without any lerp and set this to true.
	**/
	public var wentToTargetY:Bool = false;
    public var letterPos:Array<FlxPoint> = [];

    

	public static var json:AlphabetJson = null;
	public static var jsonLength:Int = -1;

    public var _boldAnims:Map<String, String> = [];

    var __letterAnims:Map<String, String> = [];
    var __boldLetterAnims:Map<String, String> = [];

    public override function get_width():Float {
        return __cacheWidth;
    }
    public function new(x:Float, y:Float, text:String, bold:Bool = true, scale:Float = 1) {
        super();
        this.x = x;
        this.y = y;
        this.text = text;
        this.bold = bold;
        this.textSize = scale;

        var jsonText = Assets.getText(Paths.getPath("images/alphabet.json", TEXT, "preload"));
		if (json == null || jsonLength != jsonText.length) {
			trace("json changed!!");
            try {
                json = Json.parse(jsonText);
            } catch(e) {
                trace(e.details());
            }
			jsonLength = jsonText.length;

            if (json == null) json = {
                automaticOutline: null,
                boldLetters: null,
                letters: null,
                centerLetters: null,
                topLetters: null
            };


            if (json.automaticOutline == null) json.automaticOutline = true;
            if (json.boldLetters == null) json.boldLetters = _letters;
            if (json.letters == null) json.letters = nonBoldLetters;
            if (json.centerLetters == null) json.centerLetters = centerAnims;
            if (json.topLetters == null) json.topLetters = showOnTopAnims;
            
		}

        letterSprite = new FlxSprite(0, 0);
        letterSprite.frames = Paths.getSparrowAtlas('alphabet');
        letterSprite.antialiasing = true;
        normalShader = letterSprite.shader;

        letterShaders = [];

        for(e in json.boldLetters) {
            var name = e[0];
            var anim = e[1];
            __boldLetterAnims[name] = anim;
            letterSprite.animation.addByPrefix(anim, anim, 24, true);
        }
        
        for(e in json.letters) {
            var name = e[0];
            var anim = e[1];
            __letterAnims[name] = anim;
            letterSprite.animation.addByPrefix(anim, anim, 24, true);
        }

        

        add(letterSprite);
        __ready = true;
        calculateShit(false);
    }

    var time:Float = 0;
    public override function update(elapsed:Float) {
        super.update(elapsed);
        time += elapsed;
        if (isMenuItem) {
            var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			var h:Float = FlxG.height;
			if (Std.isOfType(FlxG.state, PlayState))
				if (isMenuItem)
					h = PlayState.current.guiSize.y;
			var w:Float = FlxG.width;
			if (Std.isOfType(FlxG.state, PlayState))
				if (isMenuItem)
					w = PlayState.current.guiSize.x;

			if (wentToTargetY) {
				y = FlxMath.lerp(y, (scaledY * 120) + (h * 0.48), 0.16 * 60 * elapsed);
				x = FlxMath.lerp(x, (targetY * 20) + 90, 0.16 * 60 * elapsed);
			} else {
				x = (targetY * 20) + 90 - w;
				y = (scaledY * 120) + (h * 0.48);
				wentToTargetY = true;
			}
        }
    }
    public override function draw() {
        calculateShit(true);
    }

    var lastDrawLines = -1;
    public function calculateShit(draw:Bool) {
        // do not draw to save performance
        if (draw && doOptimisationStuff) {
            var inScreen = false;
                
            if (cameras != null && cameras.length > 0) {
                for(c in cameras) {
                    if (c.containsPoint(new FlxPoint(x, y), __cacheWidth, 70 * lastDrawLines * textSize)) {
                        inScreen = true;
                        break;
                    }
                }
            } else if (letterSprite.cameras != null && letterSprite.cameras.length > 0) {
                for(c in letterSprite.cameras) {
                    if (c.containsPoint(new FlxPoint(x, y), __cacheWidth, 70 * lastDrawLines * textSize)) {
                        inScreen = true;
                        break;
                    }
                }
            } else {
                @:privateAccess
                for(c in FlxCamera._defaultCameras) {
                    if (c.containsPoint(new FlxPoint(x, y), __cacheWidth, 70 * lastDrawLines * textSize)) {
                        inScreen = true;
                        break;
                    }
                }
            }

            if ((lastDrawLines > -1 && __cacheWidth > -1) && !inScreen) return; // do not draw when outside range
        }

        letterPos = [];
        if (text == null || text.length <= 0) {
            __cacheWidth = 0;
            lastDrawLines = 0;
            return;
        }
        var t = text;
        var w:Float = 0;
        var line:Int = 0;
        var widths:Array<Float> = [];

        for(i in 0...t.length) {
            if (cutPoint > -1 && i >= cutPoint) continue;
            var char = t.charAt(i);
            var animName:String = null;

            if (correctWrap && char == " " && maxWidth > 0) {
                if (w == 0) continue;
                var word = "";
                var i2 = i + 1;
                while(i2 < t.length && t.charAt(i2) != " ") {
                    word += t.charAt(i2);
                    i2++;
                }

                var wordWidth:Float = 0;
                

                for(i2 in 0...word.length) {
                    var char = word.charAt(i2);
                    animName = null;
                    if (bold) {
                        char = char.toUpperCase();
                        animName = __boldLetterAnims[char];
                    }
                    if (animName == null) animName = __letterAnims[char];
                    if (animName != null) {
                        letterSprite.animation.play(animName);
                        letterSprite.scale.set(textSize, textSize);
                        letterSprite.updateHitbox();
                        wordWidth += letterSprite.width;
                    } else {
                        wordWidth += 48 * textSize;
                    }
                }
                if (w + wordWidth + (32 * textSize) >= maxWidth) {
                    w = 0;
                    line++;
                    continue;
                }
            }

            var color = textColor;
            if (textColorSequences != null) {
                var lastK = -1;
                for(k=>e in textColorSequences) {
                    if (k > lastK && k <= i) {
                        lastK = k;
                        color = e;
                    }
                }
            }
            var forceOutline = false;
            if (bold) {
                char = char.toUpperCase();
                animName = __boldLetterAnims[char];
            }
            if (animName == null) {
                animName = __letterAnims[char];
                forceOutline = bold;
            }
            if (char == "\n") {
                line++;
                if (maxWidth <= 0) widths.push(w);
                w = 0;
                continue;
            }

            if (animName != null && animName.trim() != "" && char.trim() != "" && char != "\n") {
                letterSprite.animation.play(animName);
                if (letterSprite.animation.curAnim != null) {
                    letterSprite.animation.curAnim.curFrame = Std.int(time * letterSprite.animation.curAnim.frameRate) % letterSprite.animation.curAnim.frames.length;
                }
                if (bold && !forceOutline) {
                    letterSprite.colorTransform.redMultiplier = color.redFloat;
                    letterSprite.colorTransform.greenMultiplier = color.greenFloat;
                    letterSprite.colorTransform.blueMultiplier = color.blueFloat;
                    letterSprite.colorTransform.redOffset = 0;
                    letterSprite.colorTransform.greenOffset = 0;
                    letterSprite.colorTransform.blueOffset = 0;
                } else {
                    letterSprite.colorTransform.redMultiplier = 0;
                    letterSprite.colorTransform.greenMultiplier = 0;
                    letterSprite.colorTransform.blueMultiplier = 0;
                    letterSprite.colorTransform.redOffset = color.red;
                    letterSprite.colorTransform.greenOffset = color.green;
                    letterSprite.colorTransform.blueOffset = color.blue;
                }
                letterSprite.scale.set(textSize, textSize);
                letterSprite.updateHitbox();
                letterSprite.alpha = alpha;
                letterSprite.x = x + w;
                if (json.centerLetters.contains(animName)) {
                    letterSprite.y = y + (70 * textSize * 0.5) - (letterSprite.height / 2);
                } else if (json.topLetters.contains(animName)) {
                    letterSprite.y = y + (70 * textSize * line);
                } else {
                    letterSprite.y = y + ((70 * textSize) - letterSprite.height) + (70 * textSize * line);
                }
                

                letterPos[i] = new FlxPoint(letterSprite.x, letterSprite.y);
                if (draw) {
                    
                    if ((forceOutline || outline) && json.automaticOutline && Settings.engineSettings.data.alphabetOutline) {
                        var letterShader = letterShaders[animName];
                        if (letterShader == null) letterShader = letterShaders[animName] = new OutlineShader();
                        letterSprite.shader = letterShader;
                        var fr = letterSprite.frame.frame;
                        letterShader.setClip(fr.x / letterSprite.pixels.width, fr.y / letterSprite.pixels.height, fr.width / letterSprite.pixels.width, fr.height / letterSprite.pixels.height);
                        letterSprite.scale.x *= 1.5;
                        letterSprite.scale.y *= 1.5;
                        w += 10 * textSize;
                        if (!json.topLetters.contains(animName)) letterSprite.y -= 5 * textSize;
                    } else {
                        letterSprite.shader = normalShader;
                    }
                    letterSprite.draw();
                } else {
                    if (forceOutline || outline) {
                        w += 10 * textSize;
                    }
                }
                w += letterSprite.width;
                if (w >= maxWidth && maxWidth > 0) {
                    w = 0;
                    line++;
                }
                if (letterSprite.animation.curAnim != null) w += letterSprite.frames.frames[letterSprite.animation.curAnim.frames[0]].offset.x;
            } else {
                w += 48 * textSize;
            }
            
        }

        if (line > 0) {
            if (maxWidth > 0) {
                __cacheWidth = maxWidth;
            } else {
                var w:Float = 0;
                for (wi in widths) {
                    if (wi > w) w = wi;
                }
                __cacheWidth = w;
            }
        }
        else
            __cacheWidth = letterSprite.x + letterSprite.width - x;

        lastDrawLines = line + 1;
    }
}

class OutlineShader extends FlxFixedShader {
    @:glFragmentSource('#pragma header

    float diff = 7;
    int step = 3;
    float sin45 = sin(radians(45.0));
    uniform vec4 cuttingEdge;
    
    float motherfuckingAbs(float v) {
        if (v < 0)
            return -v;
        return v;
    }
    vec4 flixel_texture2D_safe(sampler2D bitmap, vec2 pos) {
        if (pos.x < cuttingEdge.x || pos.x > cuttingEdge.x + cuttingEdge.z || pos.y < cuttingEdge.y || pos.y > cuttingEdge.y + cuttingEdge.w)
             return vec4(0, 0, 0, 0);
        else
        if (pos.x < 0. || pos.x > 1. || pos.y < 0. || pos.y > 1.)
            return vec4(0, 0, 0, 0);
        else
            return flixel_texture2D(bitmap, pos);
    }
    
    void main() {
        vec2 newPos = vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y);
        newPos -= vec2(cuttingEdge.x + (cuttingEdge.z / 2.0), cuttingEdge.y + (cuttingEdge.w / 2.0));
        newPos *= vec2(1.5, 1.5);
        newPos += vec2(cuttingEdge.x + (cuttingEdge.z / 2.0), cuttingEdge.y + (cuttingEdge.w / 2.0));
    
    
        vec4 color = flixel_texture2D_safe(bitmap, newPos);
        float a = 0;
        for(int x = -int(diff); x < int(diff); x += step) {
            for(int y = -int(diff); y < int(diff); y += step) {
                vec2 offset = vec2(x / openfl_TextureSize.x, y / openfl_TextureSize.y);
                float angle = atan(offset.y, offset.x);
                offset = vec2(cos(angle) * (motherfuckingAbs(x) / openfl_TextureSize.x), sin(angle) * (motherfuckingAbs(y) / openfl_TextureSize.y));

                vec4 c1 = flixel_texture2D_safe(bitmap, newPos + offset);
                if (a < c1.a) a = c1.a;
            }
        }

        // disable for cool non intended shadow
        /*
        float a = 0;
        for(int i = 0; i < 8; ++i) {
            vec2 pos = vec2(0, 0);
            switch(i) {
                case 0:
                    pos = vec2(0, -diff);
                case 1:
                    pos = vec2((diff * sin45), (diff * -sin45));
                case 2:
                    pos = vec2(diff, 0);
                case 3:
                    pos = vec2((diff * sin45), (diff * sin45));
                case 4:
                    pos = vec2(0, diff);
                case 5:
                    pos = vec2((diff * -sin45), (diff * sin45));
                case 6:
                    pos = vec2(-diff, 0);
                case 7:
                    pos = vec2((diff * -sin45), (diff * -sin45));
            }
            vec4 c1 = flixel_texture2D_safe(bitmap, newPos + (pos / openfl_TextureSize));
            if (a < c1.a) {
                a = c1.a;
            }
        }
        */
    
        gl_FragColor = vec4(color.r, color.g, color.b, a);
    }')

    public function new() {
        super();
        this.cuttingEdge.value = [0, 0, 1, 1];
    }

    public function setClip(x:Float, y:Float, w:Float, h:Float) {
        this.cuttingEdge.value = [x, y, w, h];
    }
}