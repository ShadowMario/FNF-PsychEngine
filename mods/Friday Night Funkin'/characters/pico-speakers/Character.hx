import flixel.util.FlxSort;

var danced = false;
var chart = null;

function create() {
    character.frames = Paths.getCharacter("pico-speakers");

    character.animation.addByIndices("shoot1", "Pico shoot 1", [for (i in 0...4) i], "", 24, false);
    character.animation.addByIndices("shoot2", "Pico shoot 2", [for (i in 0...4) i], "", 24, false);
    character.animation.addByIndices("shoot3", "Pico shoot 3", [for (i in 0...4) i], "", 24, false);
    character.animation.addByIndices("shoot4", "Pico shoot 4", [for (i in 0...4) i], "", 24, false);
    character.animation.addByIndices("shoot1-idle", "Pico shoot 1", [for (i in 4...25) i], "", 24, true);
    character.animation.addByIndices("shoot2-idle", "Pico shoot 2", [for (i in 4...25) i], "", 24, true);
    character.animation.addByIndices("shoot3-idle", "Pico shoot 3", [for (i in 4...25) i], "", 24, true);
    character.animation.addByIndices("shoot4-idle", "Pico shoot 4", [for (i in 4...25) i], "", 24, true);

    character.addOffset("shoot1", 0, 0);
    character.addOffset("shoot2", -1, -128);
    character.addOffset("shoot3", 412, -64);
    character.addOffset("shoot4", 439, -19);

    character.addOffset("shoot1-idle", 0, 0);
    character.addOffset("shoot2-idle", -1, -128);
    character.addOffset("shoot3-idle", 412, -64);
    character.addOffset("shoot4-idle", 439, -19);

    character.playAnim("shoot1");

    chart = Paths.parseJson("stress/picospeaker");

    for(e in chart.song.notes) {
        e.sectionNotes.sort(function(n1, n2) {
            return FlxSort.byValues(FlxSort.ASCENDING, n1[0], n2[0]);
        });
    }
}

function update(elapsed) {
    if (StringTools.startsWith(character.animation.curAnim.name, "shoot") && !StringTools.endsWith(character.animation.curAnim.name, "-idle") && character.animation.curAnim.finished) {
        character.playAnim(character.animation.curAnim.name + "-idle");
    }

    doShoot();
    doSpawn();
}

var h = -1;
var e = -1;
function doShoot() {
    var e = Math.floor(Conductor.songPosition / (Conductor.crochet * 4));
    if (e < 0) return;
    if (chart == null) return;
    if (chart.song == null) return;
    if (chart.song.notes[e] == null) return;
    for (note in chart.song.notes[e].sectionNotes) {
        if (note[0] <= Conductor.songPosition && !(note[0] <= h || note[1] == e)) {
            switch(note[1]) {
                case 0:
                    var r = FlxG.random.int(1, 2);
                    character.playAnim("shoot" + Std.string(r), true);
                case 3:
                    var r = FlxG.random.int(3, 4);
                    character.playAnim("shoot" + Std.string(r), true);
            }
            character.lastNoteHitTime = Conductor.songPosition;
            h = Conductor.songPosition;
            e = note[1];
        }
    }
}

var hSpawn = -1;
var eSpawn = -1;
function doSpawn() {
    if (global["spawnTankmen"] == null) return;
    var e = Math.floor((Conductor.songPosition + 1500) / (Conductor.crochet * 4));
    if (e < 0) return;
    if (chart == null) return;
    if (chart.song == null) return;
    if (chart.song.notes[e] == null) return;
    for (note in chart.song.notes[e].sectionNotes) {
        if (note[0] < Conductor.songPosition + 1500 && !(note[0] <= hSpawn || note[1] == eSpawn)) {
            
            if (FlxG.random.bool(25)) { // 10% chance chance
                global["spawnTankmen"]();
            }

            character.lastNoteHitTime = Conductor.songPosition;
            hSpawn = Conductor.songPosition + 1500;
            eSpawn = note[1];
        }
    }
}

function dance() {
    // character.playAnim("idle");
}

function onAnim(animName) {

}