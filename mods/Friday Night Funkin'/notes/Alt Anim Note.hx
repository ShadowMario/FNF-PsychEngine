function onPlayerHit(noteData) {
    switch(noteData) {
        case 0:
            playBFsAnim("singLEFT-alt", true);
        case 1:
            playBFsAnim("singDOWN-alt", true);
        case 2:
            playBFsAnim("singUP-alt", true);
        case 3:
            playBFsAnim("singRIGHT-alt", true);
    }

}
function onDadHit(noteData) {
    switch(noteData) {
        case 0:
            playDadsAnim("singLEFT-alt", true);
        case 1:
            playDadsAnim("singDOWN-alt", true);
        case 2:
            playDadsAnim("singUP-alt", true);
        case 3:
            playDadsAnim("singRIGHT-alt", true);
    }
}