
//Discord API
#if (!macro)
#if desktop
import backend.Discord;
#end
#end

//Psych
#if (!macro)
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end
#end

#if (!macro)
import backend.Paths;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.BaseStage;
import backend.Difficulty;
import backend.Mods;
#end

#if (!macro)
import objects.Alphabet;
import objects.BGSprite;
#end

#if (!macro)
import states.PlayState;
import states.LoadingState;
#end

//Flixel
#if (flixel >= "5.3.0")
#if (!macro)
import flixel.sound.FlxSound;
#else#if (!macro)
import flixel.system.FlxSound;
#end
#end
#end

#if (!macro)
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
#end

using StringTools;