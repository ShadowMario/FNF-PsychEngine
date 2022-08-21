package charter;

import charter.CharterNote;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import Section.SwagSection;
import lime.utils.Assets;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.FlxG;
import Song.SwagSong;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxSprite;
import flixel.FlxState;

class CharterSection {
    private var y:YoshiCrafterEngineCharter;
    private var id(get, default):Int;
    private var _id:Int = -1;
    private function get_id():Int {
        if (_id == -1)
            _id = y.charterSections.indexOf(this);
        return _id;
    }
    public function new(self:YoshiCrafterEngineCharter) {
        y = self;
    }
    public var songSection(get, null):SwagSection;
    function get_songSection():SwagSection {
        return y._song.notes[id];
    }
    public function refreshNotes() {
        for (index => value in notes) {
            value.kill();
            y.remove(value);
            value.destroy();
        }
        notes = [];
        for(n in songSection.sectionNotes) {
            var note = new CharterNote(n[0], Std.int(n[1] + (songSection.mustHitSection ? y._song.keyNumber : 0)));
            note.scale.x *= 0.5;
            note.scale.y *= 0.5;
            note.updateHitbox();
            note.y = (n[0] / (Conductor.crochet / 4)) * CharterNote.swagWidth;
            if (songSection.mustHitSection) {
                note.x = grid.x + ((n[1] + y._song.keyNumber) % (y._song.keyNumber * 2)) * (CharterNote.swagWidth / 2);
            } else {
                note.x = grid.x + (n[1] % (y._song.keyNumber * 2)) * (CharterNote.swagWidth / 2);
            }
            notes.push(note);
            y.add(note);
        }
    }
    public var notes:Array<CharterNote> = [];
    public var grid:FlxSprite;
}
class YoshiCrafterEngineCharter extends MusicBeatState {
    
    public var _song:SwagSong = {
        song: 'Test',
        notes: [],
        bpm: 150,
        needsVoices: true,
        player1: 'bf',
        player2: 'dad',
        speed: 1,
        validScore: false,
        keyNumber: 4,
        noteTypes: ["Friday Night Funkin':Default Note"],
        events: []
    };
	var swagWidth(get, null):Float;
	function get_swagWidth():Float {
		return CharterNote._swagWidth * widthRatio;
	}
	var widthRatio(get, null):Float;
	function get_widthRatio():Float {
		return Math.min(1, 5 / (_song.keyNumber == null ? 5 : _song.keyNumber));
	}
    
    var bg:FlxSprite;
    var gridBG:FlxSprite;

    var p1Icon:HealthIcon;
    var p2Icon:HealthIcon;

    var vocals:FlxSound;

    var strumLine:FlxSprite;

    var legend:FlxText;

    public var charterSections:Array<CharterSection> = [];

    public override function create() {
        super.create();

        if (FlxG.sound.music != null) FlxG.sound.music.pause();   

        if (PlayState._SONG != null)
            _song = PlayState._SONG;

        // Load music and vocals
        FlxG.sound.playMusic(Paths.modInst(_song.song, PlayState.songMod, PlayState.storyDifficulty));
        if (_song.needsVoices) {
            vocals = new FlxSound().loadEmbedded(Paths.modVoices(_song.song, PlayState.songMod, PlayState.storyDifficulty));
            vocals.play();
        }
        FlxG.sound.music.pause();
        if (vocals != null) vocals.pause();

        bg = new FlxSprite(0,0);
        bg.loadGraphic(Paths.image("menuDesat", "preload"));
        bg.color = 0xFF3E0091;
        bg.scrollFactor.set();
        add(bg);
        if (_song.keyNumber == null) _song.keyNumber = 4;


        for(i in 0...Math.ceil(FlxG.sound.music.length / (Conductor.crochet * 4))) {
            if (_song.notes[i] == null) {
                _song.notes[i] = {
                    lengthInSteps: 16,
                    bpm: _song.bpm,
                    changeBPM: false,
                    mustHitSection: true,
                    sectionNotes: [],
                    typeOfSection: 0,
                    altAnim: false
                };
            }
            var cs = new CharterSection(this);
            var g = FlxGridOverlay.create(Std.int(CharterNote.swagWidth / 2), Std.int(CharterNote.swagWidth / 2), Std.int(CharterNote.swagWidth / 2) * _song.keyNumber * 2, Std.int(CharterNote.swagWidth / 2) * 32, true, 0x44FFFFFF, 0x44000000);
            g.y = (Std.int(CharterNote.swagWidth / 2) * 16) * i;
            g.screenCenter(X);
            g.pixels.lock();
            for (i in 0...g.pixels.width) {
                var color:FlxColor = new FlxColor(0xCCFFFFFF);
                g.pixels.setPixel32(i, 0, color);
                g.pixels.setPixel32(i, 1, color);
            }
            g.pixels.unlock();
            cs.grid = g;
            add(g);
            charterSections[i] = cs;
            cs.refreshNotes();
        }

        p1Icon = new HealthIcon(_song.player1 == null ? "bf" : _song.player1);
        p1Icon.scale.x = p1Icon.scale.y = 0.5;
        p1Icon.x = charterSections[0].grid.x + charterSections[0].grid.width;
        p1Icon.scrollFactor.set();
        p1Icon.flipX = true;
        add(p1Icon);

        p2Icon = new HealthIcon(_song.player2 == null ? "dad" : _song.player2);
        p2Icon.scale.x = p2Icon.scale.y = 0.5;
        p2Icon.x = charterSections[0].grid.x - p2Icon.width;
        p2Icon.scrollFactor.set();
        add(p2Icon);

        var separator = new FlxSprite(0,0).makeGraphic(2, FlxG.height, 0xFFDEC6FF);
        separator.screenCenter();
        separator.scrollFactor.set();
        add(separator);

        strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(CharterNote.swagWidth / 2) * _song.keyNumber * 2, 2, 0xFFDEC6FF);
        strumLine.screenCenter(X);
        strumLine.scrollFactor.set();
        add(strumLine);

        legend = new FlxText(0,0,0, "Curstep : ");
        legend.setFormat(Paths.font("vcr.ttf"), Std.int(15), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        legend.antialiasing = true;
        legend.scrollFactor.set();
        add(legend);
    }

    public override function onFocusLost() {
        if (vocals != null && FlxG.sound.music.playing) {
            vocals.pause();
        }
    }

    public override function onFocus() {
        if (vocals != null && FlxG.sound.music.playing) {
            vocals.resume();
        }
    }
    public override function update(elapsed:Float) {
        super.update(elapsed);


        if (FlxControls.justReleased.ENTER) {
            FlxG.sound.music.stop();   
            if (vocals != null) {
                vocals.stop();
                vocals.destroy();
            }
            PlayState._SONG = _song;
            FlxG.switchState(new PlayState());
        }

        if (FlxG.mouse.wheel != 0 && !FlxG.sound.music.playing) {
            FlxG.sound.music.time -= FlxG.mouse.wheel * (Conductor.crochet / 4);
        }
        Conductor.songPosition = FlxG.sound.music.time % FlxG.sound.music.length;
        FlxG.camera.scroll.y = Math.max(0, Conductor.songPosition / (Conductor.crochet / 4) * CharterNote.swagWidth) - strumLine.y;
        legend.text = "Beat : " + Math.floor(Conductor.songPosition / Conductor.crochet) + "\r\nStep : " + Math.floor(Conductor.songPosition / (Conductor.crochet / 4)) + "\r\nSong position (ms) : " + Math.floor(Conductor.songPosition);

        

        if (FlxControls.justReleased.SPACE) {
            if (vocals != null) vocals.time = FlxG.sound.music.time;
            if (FlxG.sound.music.playing) {
                FlxG.sound.music.pause();
                if (vocals != null) vocals.pause();   
            } else {
                FlxG.sound.music.resume();
                if (vocals != null) vocals.resume();   
            }
        }

        if (vocals != null) {
            vocals.volume = FlxG.sound.volume;
        }
    }
}