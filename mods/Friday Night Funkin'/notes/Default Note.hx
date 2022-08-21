
import("Date");

// there's nothing here, its handled via source code
var now = Date.now();
if (now.getMonth() == 3 && now.getDate() == 1 && PlayState.song.keyNumber == 4) {
    trace("April fools!");
    var oldGenerate = generateStaticArrow;
    var oldCreate = create;
    var oldPlayerHit = onPlayerHit;
    var oldDadHit = onDadHit;
    
    function create() {
        if (note.noteData % 4 == 1) {


            var e = Math.floor(note.noteData / 4) * 4;
            note.noteData = e + 2;
            oldCreate();
            note.noteData = e + 1;
        } else if (note.noteData % 4 == 2) {
            var e = Math.floor(note.noteData / 4) * 4;
            note.noteData = e + 1;
            oldCreate();
            note.noteData = e + 2;
        } else {
            oldCreate();
        }
    }
    
    function generateStaticArrow(arrow, i, player) {
        if (i == 1) oldGenerate(arrow, 2, player);
        else if (i == 2) oldGenerate(arrow, 1, player);
        else oldGenerate(arrow, i, player);
    }
    
    function onPlayerHit(data) {
        if (data % 4 == 1) oldPlayerHit(2);
        else if (data % 4 == 2) oldPlayerHit(1);
        else oldPlayerHit(data);
    }
    
    function onDadHit(data) {
        if (data % 4 == 1) oldDadHit(2);
        else if (data % 4 == 2) oldDadHit(1);
        else oldDadHit(data);
    }
}
